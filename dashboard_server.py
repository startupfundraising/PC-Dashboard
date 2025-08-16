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
LOG_FILE = '/home/alex/PC-Dashboard/logs/dashboard.log'

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
    # N8N Scripts
    'n8n-status': {
        'cmd': 'cd /home/alex/projects/active/N8N && docker-compose -f docker-compose.local.yml ps',
        'description': 'Check N8N container status'
    },
    'n8n-start': {
        'cmd': 'cd /home/alex/projects/active/N8N && docker-compose -f docker-compose.local.yml up -d',
        'description': 'Start N8N containers'
    },
    'n8n-stop': {
        'cmd': 'cd /home/alex/projects/active/N8N && docker-compose -f docker-compose.local.yml down',
        'description': 'Stop N8N containers'
    },
    'n8n-restart': {
        'cmd': 'cd /home/alex/projects/active/N8N && docker-compose -f docker-compose.local.yml restart',
        'description': 'Restart N8N containers'
    },
    'n8n-logs': {
        'cmd': 'cd /home/alex/projects/active/N8N && docker-compose -f docker-compose.local.yml logs --tail=100',
        'description': 'View N8N logs'
    },
    'n8n-sync-from-prod': {
        'cmd': 'cd /home/alex/projects/active/N8N && ./scripts/refresh_local_from_prod.sh',
        'description': 'Sync workflows from production'
    },
    'n8n-backup': {
        'cmd': 'cd /home/alex/projects/active/N8N && ./backup_to_dropbox.sh',
        'description': 'Backup N8N to Dropbox'
    },
    'n8n-refresh-local': {
        'cmd': 'cd /home/alex/projects/active/N8N && ./scripts/refresh_local_from_prod.sh',
        'description': 'Refresh local N8N from production'
    },
    
    # Git Operations
    'git-status-all': {
        'cmd': '''for dir in /home/alex/projects/active/*/; do 
            if [ -d "$dir/.git" ]; then 
                echo "=== $(basename "$dir") ===" && 
                cd "$dir" && 
                git status -s && 
                echo ""; 
            fi; 
        done''',
        'description': 'Check git status of all projects'
    },
    'git-pull-all': {
        'cmd': '''for dir in /home/alex/projects/active/*/; do 
            if [ -d "$dir/.git" ]; then 
                echo "=== Pulling $(basename "$dir") ===" && 
                cd "$dir" && 
                git pull && 
                echo ""; 
            fi; 
        done''',
        'description': 'Pull all git repositories'
    },
    'git-push-all': {
        'cmd': '''for dir in /home/alex/projects/active/*/; do 
            if [ -d "$dir/.git" ]; then 
                echo "=== $(basename "$dir") ===" && 
                cd "$dir" && 
                if [ -n "$(git status --porcelain)" ]; then 
                    git add . && 
                    git commit -m "Auto-commit from dashboard" && 
                    git push && 
                    echo "Pushed changes"; 
                else 
                    echo "No changes to push"; 
                fi && 
                echo ""; 
            fi; 
        done''',
        'description': 'Push all pending changes'
    },
    'git-commit-all': {
        'cmd': '''for dir in /home/alex/projects/active/*/; do 
            if [ -d "$dir/.git" ]; then 
                cd "$dir" && 
                if [ -n "$(git status --porcelain)" ]; then 
                    echo "=== Committing $(basename "$dir") ===" && 
                    git add . && 
                    git commit -m "Quick commit from dashboard - $(date +%Y-%m-%d_%H:%M)" && 
                    echo "Committed"; 
                fi; 
            fi; 
        done''',
        'description': 'Quick commit all changes'
    },
    
    # System Management
    'system-health': {
        'cmd': 'echo "=== CPU ===" && top -bn1 | head -5 && echo -e "\\n=== Memory ===" && free -h && echo -e "\\n=== Disk ===" && df -h /',
        'description': 'Check system health'
    },
    'disk-usage': {
        'cmd': 'df -h && echo -e "\\n=== Large Directories ===" && du -h --max-depth=1 /home/alex/projects 2>/dev/null | sort -rh | head -10',
        'description': 'Check disk usage'
    },
    'docker-cleanup': {
        'cmd': 'docker system prune -af --volumes && echo "Docker cleanup complete"',
        'description': 'Clean up Docker resources'
    },
    'system-update': {
        'cmd': 'sudo apt update && sudo apt list --upgradable',
        'description': 'Check for system updates'
    },
    
    # Quick Actions
    'backup-all': {
        'cmd': 'cd /home/alex/PC-Dashboard/scripts && ./backup_all.sh',
        'description': 'Backup all projects'
    },
    'morning-sync': {
        'cmd': 'cd /home/alex/PC-Dashboard/scripts && ./morning_sync.sh',
        'description': 'Morning sync routine'
    },
    'evening-backup': {
        'cmd': 'cd /home/alex/PC-Dashboard/scripts && ./evening_backup.sh',
        'description': 'Evening backup routine'
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
        
        logging.info(f"Running script: {script_name}")
        
        try:
            # Check if it's a script file that needs to exist
            if cmd.startswith('cd') and './scripts/' in cmd:
                # Extract script path
                parts = cmd.split('&&')
                if len(parts) > 1:
                    script_path = parts[1].strip()
                    full_path = f"/home/alex/PC-Dashboard/scripts/{script_path.split('/')[-1]}"
                    
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
            
            output = result.stdout
            if result.stderr and result.returncode != 0:
                output += f"\nError: {result.stderr}"
            
            success = result.returncode == 0
            
            logging.info(f"Script {script_name} completed with code {result.returncode}")
            
            return {
                'success': success,
                'output': output,
                'message': f"{script_name} completed successfully" if success else f"{script_name} failed"
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
        os.makedirs('/home/alex/PC-Dashboard/scripts', exist_ok=True)
        
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