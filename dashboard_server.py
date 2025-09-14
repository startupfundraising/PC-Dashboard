#!/usr/bin/env python3
"""
Cross-Platform Dashboard Server
Handles script execution and provides API endpoints for the dashboard
Auto-detects environment and loads appropriate configuration
"""

import os
import subprocess
import json
import logging
import re
import shlex
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse
from datetime import datetime
import traceback
from pathlib import Path

# Import configuration system
from config import config

# Setup logging using configuration
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(config.get_log_file()),
        logging.StreamHandler()
    ]
)

# Get platform-aware script mappings from configuration
SCRIPT_MAPPINGS = config.get_script_mappings()

class DashboardHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        """Handle GET requests"""
        path = urlparse(self.path).path
        
        # CORS headers
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', 'http://localhost:8888')
        
        if path == '/status':
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps({'status': 'online', 'time': str(datetime.now())}).encode())
            
        elif path == '/logs':
            self.send_header('Content-Type', 'text/plain')
            self.end_headers()
            try:
                with open(config.get_log_file(), 'r') as f:
                    # Get last 100 lines
                    lines = f.readlines()
                    self.wfile.write(''.join(lines[-100:]).encode())
            except:
                self.wfile.write(b'No logs available')
                
        elif path.startswith('/run/'):
            script_name = path[5:]  # Remove '/run/' prefix
            self.send_header('Content-Type', 'application/json')
            self.end_headers()

            # Validate script name
            if not self.is_valid_script_name(script_name):
                self.wfile.write(json.dumps({
                    'success': False,
                    'error': f'Invalid script name: {script_name}'
                }).encode())
                return

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
                with open(config.get_index_file(), 'r') as f:
                    self.wfile.write(f.read().encode())
            except:
                self.wfile.write(b'<h1>Error loading dashboard</h1>')
        else:
            self.send_header('Content-Type', 'text/plain')
            self.end_headers()
            self.wfile.write(f'{config.platform.title()} Dashboard Server Running'.encode())
    
    def do_OPTIONS(self):
        """Handle OPTIONS requests for CORS"""
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', 'http://localhost:8888')
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
        if config.is_testing_mode() and is_dangerous:
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
        
        # Final security check on command
        if not self.is_safe_command(cmd):
            logging.warning(f"⛔ BLOCKED: Unsafe command detected in {script_name}: {cmd}")
            return {
                'success': False,
                'error': 'BLOCKED: Command contains unsafe patterns',
                'message': 'This command was blocked for security reasons'
            }

        logging.info(f"Running script: {script_name}")

        try:
            # Check if it's a script file that needs to exist
            if cmd.startswith('cd') and './scripts/' in cmd:
                # Extract script path
                parts = cmd.split('&&')
                if len(parts) > 1:
                    script_path = parts[1].strip()
                    full_path = f"{config.scripts_path}/{script_path.split('/')[-1]}"
                    
                    # Create script if it doesn't exist
                    if not os.path.exists(full_path):
                        self.create_default_script(full_path, script_name)
            
            # Run the command with enhanced security
            # Use shell=False when possible for better security
            if self.can_use_shell_false(cmd):
                # Parse command safely
                cmd_parts = shlex.split(cmd)
                result = subprocess.run(
                    cmd_parts,
                    capture_output=True,
                    text=True,
                    timeout=60,
                    cwd=config.dashboard_path
                )
            else:
                # Fall back to shell=True but with restricted environment
                restricted_env = os.environ.copy()
                restricted_env['PATH'] = '/usr/local/bin:/usr/bin:/bin'

                result = subprocess.run(
                    cmd,
                    shell=True,
                    capture_output=True,
                    text=True,
                    timeout=60,
                    env=restricted_env,
                    cwd=config.dashboard_path
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
            content = f'''#!/bin/bash
# Load environment and common functions
source "$(dirname "$0")/lib/common.sh"

echo "Starting backup..."
echo "Backing up projects to Dropbox..."

# Add your backup logic here
# Example: tar -czf backup.tar.gz $BASE_PATH/projects/

echo "Backup complete!"
'''
        elif 'sync' in script_name:
            content = f'''#!/bin/bash
# Load environment and common functions
source "$(dirname "$0")/lib/common.sh"

echo "Starting sync..."

# Pull all git repos
for dir in $BASE_PATH/projects/*/; do
    if [ -d "$dir/.git" ]; then
        echo "Syncing $(basename "$dir")..."
        cd "$dir" && git pull
    fi
done

echo "Sync complete!"
'''
        else:
            content = f'''#!/bin/bash
# Load environment and common functions
source "$(dirname "$0")/lib/common.sh"

echo "Running {script_name}..."
# Add your script logic here
echo "Complete!"
'''
        
        with open(path, 'w') as f:
            f.write(content)
        
        os.chmod(path, 0o755)
        logging.info(f"Created default script: {path}")
    
    def is_valid_script_name(self, script_name):
        """Validate script name to prevent injection attacks"""
        # Only allow alphanumeric, hyphens, and underscores
        if not re.match(r'^[a-zA-Z0-9_-]+$', script_name):
            return False

        # Prevent directory traversal
        if '..' in script_name or '/' in script_name or '\\' in script_name:
            return False

        return True

    def is_safe_command(self, cmd):
        """Check if command is safe to execute"""
        # Block dangerous patterns
        dangerous_patterns = [
            r'\|\s*rm\s',  # Pipe to rm command
            r'\|\s*dd\s',  # Pipe to dd command
            r'\>\s*/dev/',  # Redirect to device files
            r'sudo\s+(?!systemctl)',  # Sudo except for systemctl
            r'\$\(.*\)',  # Command substitution
            r'`.*`',  # Backtick command substitution
            r'\;\s*(rm|dd|mkfs|format)',  # Chained dangerous commands
        ]

        for pattern in dangerous_patterns:
            if re.search(pattern, cmd, re.IGNORECASE):
                return False

        return True

    def can_use_shell_false(self, cmd):
        """Check if we can safely use shell=False for this command"""
        # If command contains shell operators, we need shell=True
        shell_operators = ['&&', '||', '|', '>', '<', ';', '&']
        for op in shell_operators:
            if op in cmd:
                return False
        return True

    def log_message(self, format, *args):
        """Override to suppress default logging"""
        return

def main():
    """Start the dashboard server"""
    try:
        # Print configuration info
        print(f"\n🚀 {config.platform.title()} Dashboard Server")
        print(f"📋 Configuration: {config}")
        print(f"🧪 Testing Mode: {'ACTIVE' if config.is_testing_mode() else 'INACTIVE'}")
        
        server = HTTPServer((config.host, config.port), DashboardHandler)
        logging.info(f"Dashboard server starting on {config.host}:{config.port}")
        print(f"\n🌐 Server running on http://{config.host}:{config.port}")
        print("📋 Open index.html in your browser to access the dashboard")
        print("Press Ctrl+C to stop\n")
        
        server.serve_forever()
        
    except KeyboardInterrupt:
        print("\n⏹️  Server stopped")
        logging.info("Server stopped by user")
    except Exception as e:
        logging.error(f"Server error: {str(e)}")
        print(f"❌ Error: {str(e)}")
        print(f"💡 Tip: Check if .env file exists and is properly configured")

if __name__ == '__main__':
    main()