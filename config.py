#!/usr/bin/env python3
"""
Dashboard Configuration System
Auto-detects environment and loads appropriate settings
"""

import os
import platform
import sys
from pathlib import Path
from dotenv import load_dotenv

class DashboardConfig:
    def __init__(self):
        # Auto-detect environment
        self.platform = self._detect_platform()
        
        # Load environment variables
        self._load_environment()
        
        # Set up paths
        self._setup_paths()
    
    def _detect_platform(self):
        """Auto-detect platform (mac, pc, linux)"""
        system = platform.system().lower()
        
        if system == 'darwin':
            return 'mac'
        elif system == 'linux':
            # Check if we're in WSL
            if os.path.exists('/proc/version'):
                with open('/proc/version', 'r') as f:
                    if 'microsoft' in f.read().lower():
                        return 'pc'  # WSL
            return 'linux'
        elif system == 'windows':
            return 'windows'
        else:
            return 'unknown'
    
    def _load_environment(self):
        """Load environment variables from .env file"""
        env_path = Path(__file__).parent / '.env'
        
        if env_path.exists():
            load_dotenv(env_path)
        else:
            print(f"⚠️  No .env file found at {env_path}")
            print("Creating from template...")
            self._create_default_env()
            load_dotenv(env_path)
    
    def _create_default_env(self):
        """Create a default .env file based on detected platform"""
        env_path = Path(__file__).parent / '.env'
        
        if self.platform == 'mac':
            username = os.environ.get('USER', 'alexander')
            base_path = f'/Users/{username}'
            default_config = f'''# Mac Dashboard Configuration
PLATFORM=mac
BASE_PATH={base_path}
DASHBOARD_PATH={base_path}/Mac-Dashboard
N8N_PATH={base_path}/projects/N8N
LOG_PATH={base_path}/Mac-Dashboard/logs
SCRIPTS_PATH={base_path}/Mac-Dashboard/scripts

# Web Server
HOST=localhost
PORT=8888

# Platform-specific commands
LAUNCH_CLAUDE_CMD=cd ~ && claude
OPEN_LOCAL_CMD=open -a Local
'''
        else:  # PC/Linux/WSL
            username = os.environ.get('USER', 'alex')
            base_path = f'/home/{username}'
            default_config = f'''# PC Dashboard Configuration
PLATFORM=pc
BASE_PATH={base_path}
DASHBOARD_PATH={base_path}/projects/active/PC-Dashboard
N8N_PATH={base_path}/projects/active/N8N
LOG_PATH={base_path}/projects/active/PC-Dashboard/logs
SCRIPTS_PATH={base_path}/projects/active/PC-Dashboard/scripts

# Web Server
HOST=localhost
PORT=8888

# Platform-specific commands
LAUNCH_CLAUDE_CMD=/mnt/c/Windows/System32/cmd.exe /c "start wsl -d U2 bash -c \\"cd ~ && claude\\""
OPEN_LOCAL_CMD=DISPLAY=:0 /opt/Local/Local
'''
        
        with open(env_path, 'w') as f:
            f.write(default_config)
        
        print(f"✅ Created default .env file for {self.platform}")
    
    def _setup_paths(self):
        """Setup path variables from environment"""
        self.base_path = os.getenv('BASE_PATH', '/tmp')
        self.dashboard_path = os.getenv('DASHBOARD_PATH', f'{self.base_path}/Dashboard')
        self.n8n_path = os.getenv('N8N_PATH', f'{self.base_path}/N8N')
        self.log_path = os.getenv('LOG_PATH', f'{self.dashboard_path}/logs')
        self.scripts_path = os.getenv('SCRIPTS_PATH', f'{self.dashboard_path}/scripts')
        
        # Web server settings
        self.host = os.getenv('HOST', 'localhost')
        self.port = int(os.getenv('PORT', '8888'))
        
        # Platform-specific commands
        self.launch_claude_cmd = os.getenv('LAUNCH_CLAUDE_CMD', 'claude')
        self.open_local_cmd = os.getenv('OPEN_LOCAL_CMD', 'echo "Local not configured"')
        
        # Ensure directories exist
        self._ensure_directories()
    
    def _ensure_directories(self):
        """Create necessary directories"""
        for path in [self.log_path, self.scripts_path]:
            Path(path).mkdir(parents=True, exist_ok=True)
    
    def get_script_mappings(self):
        """Return platform-aware script mappings"""
        return {
            # N8N Scripts - Daily Operations
            f'n8n-{self.platform}-to-github': {
                'cmd': f'cd {self.n8n_path} && bash scripts/{self.platform}_push_to_github.sh',
                'description': f'Push {self.platform} N8N workflows to GitHub'
            },
            f'n8n-github-to-{self.platform}': {
                'cmd': f'cd {self.n8n_path} && bash scripts/{self.platform}_pull_from_github.sh',
                'description': f'Pull N8N workflows from GitHub to {self.platform}'
            },
            
            # N8N Scripts - GitHub Sync
            'n8n-live-to-github': {
                'cmd': f'cd {self.n8n_path} && bash scripts/sync_live_to_git.sh',
                'description': 'Push production N8N workflows to GitHub'
            },
            'n8n-github-to-live': {
                'cmd': f'cd {self.n8n_path} && bash scripts/hetzner_pull_from_github.sh',
                'description': 'Deploy workflows from GitHub to production'
            },
            
            # N8N Scripts - Caution (Full sync operations)
            f'n8n-live-to-{self.platform}': {
                'cmd': f'bash {self.scripts_path}/n8n_live_to_{self.platform}.sh',
                'description': f'Pull from production to {self.platform} via GitHub'
            },
            f'n8n-{self.platform}-to-live': {
                'cmd': f'bash {self.scripts_path}/n8n_{self.platform}_to_live.sh',
                'description': f'Deploy {self.platform} to production via GitHub'
            },
            
            # Admin Scripts
            'edit-dashboard': {
                'cmd': f'bash {self.scripts_path}/edit_dashboard.sh',
                'description': 'Open Claude Code with dashboard context'
            },
            'launch-claude-code': {
                'cmd': self.launch_claude_cmd,
                'description': 'Launch Claude Code in new terminal window'
            },
            'open-local': {
                'cmd': self.open_local_cmd,
                'description': 'Open Local WordPress program'
            }
        }
    
    def get_log_file(self):
        """Return the main log file path"""
        return f'{self.log_path}/dashboard.log'
    
    def get_index_file(self):
        """Return the index.html file path"""
        return f'{self.dashboard_path}/index.html'
    
    def is_testing_mode(self):
        """Check if testing mode is active"""
        return Path(f'{self.dashboard_path}/.testing_mode').exists()
    
    def __str__(self):
        return f"DashboardConfig(platform={self.platform}, dashboard_path={self.dashboard_path})"

# Global config instance
config = DashboardConfig()