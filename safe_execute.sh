#!/bin/bash
# Safe execution wrapper for sensitive scripts
# Prevents automated execution by Claude Code or other tools

SCRIPT_NAME="$1"
shift
SCRIPT_ARGS="$@"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# List of dangerous scripts that require approval
DANGEROUS_SCRIPTS=(
    "n8n_pc_to_live"
    "n8n_live_to_pc"
    "pc_push_to_github"
    "sync_live_to_git"
    "deploy"
    "production"
)

is_dangerous_script() {
    local script="$1"
    for dangerous in "${DANGEROUS_SCRIPTS[@]}"; do
        if [[ "$script" == *"$dangerous"* ]]; then
            return 0
        fi
    done
    return 1
}

check_claude_code_session() {
    # Check if running under Claude Code
    if [ -n "$CLAUDE_CODE_SESSION" ] || [ -n "$CLAUDE_CODE" ] || [ -n "$ANTHROPIC_SESSION" ]; then
        echo -e "${RED}⛔ BLOCKED: Claude Code detected${NC}"
        echo "This script cannot be run automatically by Claude Code"
        echo "Please run it manually in a terminal if needed"
        return 1
    fi
    
    # Check parent process for automation tools
    local parent_cmd=$(ps -o comm= -p $PPID 2>/dev/null)
    if [[ "$parent_cmd" =~ (python|node|expect|automation) ]]; then
        echo -e "${RED}⛔ BLOCKED: Automation detected (parent: $parent_cmd)${NC}"
        echo "This script must be run manually"
        return 1
    fi
    
    return 0
}

check_testing_mode() {
    if [ -f "/home/alex/PC-Dashboard/.testing_mode" ]; then
        echo -e "${YELLOW}⚠️  TESTING MODE ACTIVE${NC}"
        echo "Remove /home/alex/PC-Dashboard/.testing_mode to enable script execution"
        return 1
    fi
    return 0
}

require_human_confirmation() {
    local script="$1"
    
    # Check if TTY is available
    if [ ! -t 0 ] || [ ! -t 1 ]; then
        echo -e "${RED}⛔ BLOCKED: Interactive terminal required${NC}"
        echo "This script cannot be run in a non-interactive environment"
        return 1
    fi
    
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}🚨 SENSITIVE OPERATION WARNING 🚨${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "Script: ${RED}$script${NC}"
    echo -e "This script will modify ${RED}PRODUCTION${NC} systems!"
    echo ""
    
    # Generate random code for confirmation
    local random_code=$((RANDOM % 9000 + 1000))
    echo -e "Verification code: ${GREEN}$random_code${NC}"
    echo ""
    
    # Record start time
    local start_time=$(date +%s)
    
    # Read confirmation code from TTY (prevents piped input)
    read -p "Enter the verification code to confirm: " -r user_code < /dev/tty
    
    if [ "$user_code" != "$random_code" ]; then
        echo -e "${RED}❌ Code mismatch. Operation cancelled.${NC}"
        return 1
    fi
    
    # Check if response was too fast (likely automated)
    local end_time=$(date +%s)
    local elapsed=$((end_time - start_time))
    
    if [ $elapsed -lt 3 ]; then
        echo -e "${RED}❌ Response too fast. Please read the warning carefully.${NC}"
        return 1
    fi
    
    # Final confirmation
    echo ""
    read -p "Type 'EXECUTE' to proceed or anything else to cancel: " -r final_confirm < /dev/tty
    
    if [ "$final_confirm" != "EXECUTE" ]; then
        echo -e "${RED}❌ Operation cancelled.${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✅ Authorization confirmed${NC}"
    return 0
}

log_execution() {
    local script="$1"
    local status="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_file="/home/alex/PC-Dashboard/logs/script_executions.log"
    
    echo "$timestamp | $status | $script | User: $(whoami) | TTY: $(tty 2>/dev/null || echo 'none')" >> "$log_file"
    
    # Also log to system logger
    logger "PC-DASHBOARD: $status execution of $script by $(whoami)"
}

# Main execution flow
main() {
    if [ -z "$SCRIPT_NAME" ]; then
        echo "Usage: $0 <script_path> [args...]"
        exit 1
    fi
    
    if ! [ -f "$SCRIPT_NAME" ]; then
        echo -e "${RED}Error: Script not found: $SCRIPT_NAME${NC}"
        exit 1
    fi
    
    # Check if this is a dangerous script
    if is_dangerous_script "$SCRIPT_NAME"; then
        echo -e "${YELLOW}Dangerous script detected - applying safety checks...${NC}"
        
        # Layer 1: Check for Claude Code session
        if ! check_claude_code_session; then
            log_execution "$SCRIPT_NAME" "BLOCKED_CLAUDE"
            exit 1
        fi
        
        # Layer 2: Check testing mode
        if ! check_testing_mode; then
            log_execution "$SCRIPT_NAME" "BLOCKED_TESTING"
            exit 1
        fi
        
        # Layer 3: Require human confirmation
        if ! require_human_confirmation "$SCRIPT_NAME"; then
            log_execution "$SCRIPT_NAME" "BLOCKED_CONFIRMATION"
            exit 1
        fi
        
        log_execution "$SCRIPT_NAME" "AUTHORIZED"
    else
        echo -e "${GREEN}Safe script - executing...${NC}"
        log_execution "$SCRIPT_NAME" "SAFE_EXECUTION"
    fi
    
    # Execute the script
    echo -e "${GREEN}Executing: $SCRIPT_NAME $SCRIPT_ARGS${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    bash "$SCRIPT_NAME" $SCRIPT_ARGS
    exit_code=$?
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}✅ Script completed successfully${NC}"
    else
        echo -e "${RED}❌ Script failed with exit code: $exit_code${NC}"
    fi
    
    log_execution "$SCRIPT_NAME" "COMPLETED_$exit_code"
    exit $exit_code
}

# Export a marker that Claude Code can detect
export CLAUDE_CODE_SESSION="${CLAUDE_CODE_SESSION:-$(ps aux | grep -q 'claude\|anthropic' && echo '1' || echo '')}"

main