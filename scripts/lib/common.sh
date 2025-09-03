#!/bin/bash
#
# Common Dashboard Functions Library
# Source this file in all dashboard scripts for shared functionality
#

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to load environment variables
load_env() {
    local script_dir="$(dirname "${BASH_SOURCE[0]}")"
    local dashboard_dir="$(cd "$script_dir/../.." && pwd)"
    local env_file="$dashboard_dir/.env"
    
    if [[ -f "$env_file" ]]; then
        # Export environment variables from .env file
        set -o allexport
        source "$env_file"
        set +o allexport
        
        echo -e "${GREEN}✅ Loaded environment from: $env_file${NC}"
    else
        echo -e "${RED}❌ Error: .env file not found at: $env_file${NC}"
        echo "Please run 'python3 config.py' to create it, or copy from .env.template"
        return 1
    fi
}

# Function to detect if running in interactive mode
is_interactive() {
    [[ $- == *i* ]] && [[ -t 0 ]]
}

# Function to check if testing mode is active
is_testing_mode() {
    [[ -f "$DASHBOARD_PATH/.testing_mode" ]]
}

# Function to log script execution
log_execution() {
    local script="$1"
    local status="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_file="$LOG_PATH/script_executions.log"
    
    # Ensure log directory exists
    mkdir -p "$LOG_PATH"
    
    echo "$timestamp | $status | $script | User: $(whoami) | TTY: $(tty 2>/dev/null || echo 'none')" >> "$log_file"
    
    # Also log to system logger if available
    if command -v logger &> /dev/null; then
        logger "DASHBOARD: $status execution of $script by $(whoami)"
    fi
}

# Function to require human confirmation for dangerous operations
require_human_confirmation() {
    local script="$1"
    local operation="$2"
    
    if ! is_interactive; then
        echo -e "${RED}❌ This script requires interactive mode for safety${NC}"
        echo "Run this script in a terminal where you can provide input"
        log_execution "$script" "BLOCKED_NON_INTERACTIVE"
        return 1
    fi
    
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}⚠️  APPROVAL REQUIRED ⚠️${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}Operation: $operation${NC}"
    echo -e "${RED}Script: $script${NC}"
    echo ""
    echo -e "${YELLOW}This operation may affect production systems!${NC}"
    echo ""
    
    while true; do
        echo -e "${BLUE}Do you want to proceed? (yes/no): ${NC}"
        read -r response
        
        case $response in
            [Yy]|[Yy][Ee][Ss])
                echo -e "${GREEN}✅ Authorization confirmed${NC}"
                log_execution "$script" "APPROVED"
                return 0
                ;;
            [Nn]|[Nn][Oo])
                echo -e "${RED}❌ Operation cancelled by user${NC}"
                log_execution "$script" "CANCELLED"
                return 1
                ;;
            *)
                echo -e "${YELLOW}Please answer yes or no${NC}"
                ;;
        esac
    done
}

# Function to show testing mode warning
show_testing_mode_warning() {
    if is_testing_mode; then
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${YELLOW}🧪 TESTING MODE ACTIVE${NC}"
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${YELLOW}This script will run in SIMULATION mode${NC}"
        echo -e "${YELLOW}No real changes will be made to production systems${NC}"
        echo -e "${YELLOW}Remove $DASHBOARD_PATH/.testing_mode to enable real execution${NC}"
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        return 0
    fi
    return 1
}

# Function to execute commands with testing mode support
safe_execute() {
    local cmd="$1"
    local description="$2"
    
    if is_testing_mode; then
        echo -e "${YELLOW}[TEST MODE] Would execute: $description${NC}"
        echo -e "${BLUE}Command: $cmd${NC}"
        return 0
    else
        echo -e "${GREEN}Executing: $description${NC}"
        echo -e "${BLUE}Command: $cmd${NC}"
        eval "$cmd"
        return $?
    fi
}

# Function to check if dangerous patterns are in script name
is_dangerous_script() {
    local script_name="$1"
    local dangerous_patterns=("push" "pull" "deploy" "live" "production" "sync" "github")
    
    for pattern in "${dangerous_patterns[@]}"; do
        if [[ "$script_name" == *"$pattern"* ]]; then
            return 0
        fi
    done
    return 1
}

# Function to setup script safety checks
setup_safety_checks() {
    local script_name="$(basename "$0")"
    
    # Load environment first
    if ! load_env; then
        exit 1
    fi
    
    # Show testing mode warning
    show_testing_mode_warning
    
    # Check if dangerous script and require confirmation
    if is_dangerous_script "$script_name" && ! is_testing_mode; then
        if ! require_human_confirmation "$script_name" "Execute potentially dangerous script"; then
            exit 1
        fi
    fi
    
    # Log script start
    log_execution "$script_name" "STARTED"
}

# Function to cleanup and log script end
cleanup_script() {
    local script_name="$(basename "$0")"
    local exit_code="$1"
    
    if [[ "$exit_code" -eq 0 ]]; then
        log_execution "$script_name" "COMPLETED"
        echo -e "${GREEN}✅ Script completed successfully${NC}"
    else
        log_execution "$script_name" "FAILED"
        echo -e "${RED}❌ Script failed with exit code: $exit_code${NC}"
    fi
}

# Function to print environment info (useful for debugging)
print_env_info() {
    echo -e "${BLUE}Environment Information:${NC}"
    echo "Platform: $PLATFORM"
    echo "Base Path: $BASE_PATH"
    echo "Dashboard Path: $DASHBOARD_PATH"
    echo "N8N Path: $N8N_PATH"
    echo "Testing Mode: $(is_testing_mode && echo "ACTIVE" || echo "INACTIVE")"
    echo "Interactive Mode: $(is_interactive && echo "YES" || echo "NO")"
    echo ""
}

# Auto-setup when sourced (can be disabled by setting SKIP_AUTO_SETUP=1)
if [[ "${BASH_SOURCE[0]}" != "${0}" && -z "$SKIP_AUTO_SETUP" ]]; then
    # Only auto-setup if script is being sourced and not run directly
    setup_safety_checks
fi