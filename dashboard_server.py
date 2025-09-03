#!/usr/bin/env python3
"""
PC Dashboard Server
Handles script execution and provides API endpoints for the dashboard
"""

import os
import subprocess
import json
import logging
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse
from datetime import datetime
import traceback

# Configuration
PORT = 8888
HOST = 'localhost'
LOG_FILE = '/home/alex/projects/active/PC-Dashboard/logs/dashboard.log'

# Ensure log directory exists
os.makedirs(os.path.dirname(LOG_FILE), exist_ok=True)

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(LOG_FILE),
        logging.StreamHandler()
    ]
)

# Script mappings - linking to existing project scripts
SCRIPT_MAPPINGS = {
    # N8N Scripts - Daily Operations
    'n8n-pc-to-github': {
        'cmd': 'cd /home/alex/projects/active/N8N && bash scripts/pc_push_to_github.sh',
        'description': 'Push local N8N workflows to GitHub'
    },
    'n8n-github-to-pc': {
        'cmd': 'cd /home/alex/projects/active/N8N && bash scripts/pc_pull_from_github.sh',
        'description': 'Pull N8N workflows from GitHub to local'
    },
    
    # N8N Scripts - GitHub Sync
    'n8n-live-to-github': {
        'cmd': 'cd /home/alex/projects/active/N8N && bash scripts/sync_live_to_git.sh',
        'description': 'Push production N8N workflows to GitHub'
    },
    'n8n-github-to-live': {
        'cmd': 'cd /home/alex/projects/active/N8N && bash scripts/hetzner_pull_from_github.sh',
        'description': 'Deploy workflows from GitHub to production'
    },
    
    # N8N Scripts - Caution (Full sync operations)
    'n8n-live-to-pc': {
        'cmd': 'bash /home/alex/projects/active/PC-Dashboard/scripts/n8n_live_to_pc.sh',
        'description': 'Pull from production to local via GitHub'
    },
    'n8n-pc-to-live': {
        'cmd': 'bash /home/alex/projects/active/PC-Dashboard/scripts/n8n_pc_to_live.sh',
        'description': 'Deploy local to production via GitHub'
    },
    
    # Admin Scripts
    'edit-dashboard': {
        'cmd': 'bash /home/alex/projects/active/PC-Dashboard/scripts/edit_dashboard.sh',
        'description': 'Open Claude Code with dashboard context'
    },
    'launch-claude-code': {
        'cmd': '/mnt/c/Windows/System32/cmd.exe /c "start wsl -d U2 bash -c \\"cd ~ && claude\\""',
        'description': 'Launch Claude Code in new terminal window'
    },
    'open-local': {
        'cmd': 'DISPLAY=:0 /opt/Local/Local',
        'description': 'Open Local WordPress program'
    }
}

class DashboardHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        """Handle GET requests"""
        path = urlparse(self.path).path
        
        # CORS headers
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        
        if path == '/status':
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps({'status': 'online', 'time': str(datetime.now())}).encode())
            
        elif path == '/logs':
            self.send_header('Content-Type', 'text/plain')
            self.end_headers()
            try:
                with open(LOG_FILE, 'r') as f:
                    # Get last 100 lines
                    lines = f.readlines()
                    self.wfile.write(''.join(lines[-100:]).encode())
            except:
                self.wfile.write(b'No logs available')
                
        elif path.startswith('/run/'):
            script_name = path[5:]  # Remove '/run/' prefix
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            
            if script_name in SCRIPT_MAPPINGS:
                result = self.run_script(script_name)
                self.wfile.write(json.dumps(result).encode())
            else:
                self.wfile.write(json.dumps({
                    'success': False,
                    'error': f'Unknown script: {script_name}'
                }).encode())
        elif path == '/' or path == '/index.html':
            self.send_header('Content-Type', 'text/html')
            self.end_headers()
            try:
                with open('/home/alex/projects/active/PC-Dashboard/index.html', 'r') as f:
                    self.wfile.write(f.read().encode())
            except:
                self.wfile.write(b'<h1>Error loading dashboard</h1>')
        else:
            self.send_header('Content-Type', 'text/plain')
            self.end_headers()
            self.wfile.write(b'PC Dashboard Server Running')
    
    def do_OPTIONS(self):
        """Handle OPTIONS requests for CORS"""
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()
    
    def run_script(self, script_name):
        """Execute a script and return the result"""
        script_info = SCRIPT_MAPPINGS[script_name]
        cmd = script_info['cmd']
        
        # Safety check - log who's calling this
        user_agent = self.headers.get('User-Agent', '')
        referer = self.headers.get('Referer', '')
        
        # Log execution attempt with context
        logging.info(f"Script execution request: {script_name}")
        logging.info(f"User-Agent: {user_agent}")
        logging.info(f"Referer: {referer}")
        
        # Check if this looks like it's coming from a browser vs command line
        if not referer and 'curl' in user_agent.lower():
            logging.warning(f"⚠️ Command line execution attempt detected for: {script_name}")
        
        # SAFETY CHECK: Detect dangerous scripts
        dangerous_patterns = ['push', 'pull', 'deploy', 'live', 'production', 'sync', 'github']
        is_dangerous = any(pattern in script_name.lower() for pattern in dangerous_patterns)
        
        # Check testing mode (only log for dangerous scripts)
        if os.path.exists('/home/alex/projects/active/PC-Dashboard/.testing_mode') and is_dangerous:
            logging.info(f"ℹ️ Testing mode active - dangerous script {script_name} will run in test mode")
        
        # Block automation attempts on dangerous scripts (unless from browser)
        if is_dangerous:
            # Check for signs of automation
            if 'claude' in user_agent.lower() or not referer:
                logging.warning(f"⛔ BLOCKED: Dangerous script from automation - {script_name}")
                return {
                    'success': False,
                    'error': 'BLOCKED: This script requires manual execution through the dashboard',
                    'message': 'For safety, this script cannot be run via automation'
                }
        
        logging.info(f"Running script: {script_name}")
        
        try:
            # Check if it's a script file that needs to exist
            if cmd.startswith('cd') and './scripts/' in cmd:
                # Extract script path
                parts = cmd.split('&&')
                if len(parts) > 1:
                    script_path = parts[1].strip()
                    full_path = f"/home/alex/projects/active/PC-Dashboard/scripts/{script_path.split('/')[-1]}"
                    
                    # Create script if it doesn't exist
                    if not os.path.exists(full_path):
                        self.create_default_script(full_path, script_name)
            
            # Run the command
            result = subprocess.run(
                cmd,
                shell=True,
                capture_output=True,
                text=True,
                timeout=60
            )
            
            output = result.stdout if result.stdout else ""
            if result.stderr:
                output += f"\nSTDERR: {result.stderr}"
            
            success = result.returncode == 0
            
            logging.info(f"Script {script_name} completed with code {result.returncode}")
            
            # Always return some output, even if empty
            if not output:
                output = f"Command executed: {cmd}\nReturn code: {result.returncode}"
            
            return {
                'success': success,
                'output': output,
                'message': f"{script_name} completed successfully" if success else f"{script_name} failed with code {result.returncode}"
            }
            
        except subprocess.TimeoutExpired:
            logging.error(f"Script {script_name} timed out")
            return {
                'success': False,
                'error': 'Script timed out after 60 seconds'
            }
        except Exception as e:
            logging.error(f"Error running script {script_name}: {str(e)}")
            logging.error(traceback.format_exc())
            return {
                'success': False,
                'error': str(e)
            }
    
    def create_default_script(self, path, script_name):
        """Create a default script if it doesn't exist"""
        os.makedirs(os.path.dirname(path), exist_ok=True)
        
        # Default script content based on name
        if 'backup' in script_name:
            content = '''#!/bin/bash
echo "Starting backup..."
echo "Backing up projects to Dropbox..."

# Add your backup logic here
# Example: tar -czf backup.tar.gz /home/alex/projects/active/

echo "Backup complete!"
'''
        elif 'sync' in script_name:
            content = '''#!/bin/bash
echo "Starting sync..."

# Pull all git repos
for dir in /home/alex/projects/active/*/; do
    if [ -d "$dir/.git" ]; then
        echo "Syncing $(basename "$dir")..."
        cd "$dir" && git pull
    fi
done

echo "Sync complete!"
'''
        else:
            content = f'''#!/bin/bash
echo "Running {script_name}..."
# Add your script logic here
echo "Complete!"
'''
        
        with open(path, 'w') as f:
            f.write(content)
        
        os.chmod(path, 0o755)
        logging.info(f"Created default script: {path}")
    
    def log_message(self, format, *args):
        """Override to suppress default logging"""
        return

def main():
    """Start the dashboard server"""
    try:
        # Create scripts directory if it doesn't exist
        os.makedirs('/home/alex/projects/active/PC-Dashboard/scripts', exist_ok=True)
        
        server = HTTPServer((HOST, PORT), DashboardHandler)
        logging.info(f"Dashboard server starting on {HOST}:{PORT}")
        print(f"\n🚀 PC Dashboard Server running on http://{HOST}:{PORT}")
        print("📋 Open index.html in your browser to access the dashboard")
        print("Press Ctrl+C to stop\n")
        
        server.serve_forever()
        
    except KeyboardInterrupt:
        print("\n⏹️  Server stopped")
        logging.info("Server stopped by user")
    except Exception as e:
        logging.error(f"Server error: {str(e)}")
        print(f"❌ Error: {str(e)}")

if __name__ == '__main__':
    main()