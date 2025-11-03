#!/bin/bash

# Logging System for Launchify
# Captures all output to both terminal and log file

# Log directory setup
LOG_DIR="$HOME/.launchify/logs"
LOG_FILE=""
LOGGING_ENABLED=false

# Initialize logging system
init_logging() {
    local project_name=$1
    
    # Create log directory if it doesn't exist
    mkdir -p "$LOG_DIR"
    
    # Generate timestamped log filename
    local timestamp=$(date +%Y-%m-%d_%H-%M-%S)
    LOG_FILE="$LOG_DIR/${project_name}_${timestamp}.log"
    
    # Start logging
    exec > >(tee -a "$LOG_FILE")
    exec 2>&1
    
    LOGGING_ENABLED=true
    
    # Write log header
    echo "=========================================="
    echo "LAUNCHIFY SETUP LOG"
    echo "=========================================="
    echo "Project: $project_name"
    echo "Date: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "User: $(whoami)"
    echo "Working Directory: $(pwd)"
    echo "=========================================="
    echo ""
    
    # Inform user about logging
    echo -e "${GREEN}✓ Logging initialized${NC}"
    echo -e "${BLUE}Log file: ${LOG_FILE}${NC}"
    echo ""
}

# Get current log file path
get_log_file() {
    echo "$LOG_FILE"
}

# Clean up old log files (keep last 10)
cleanup_old_logs() {
    local log_count=$(ls -1 "$LOG_DIR" 2>/dev/null | wc -l)
    
    if [ "$log_count" -gt 10 ]; then
        echo -e "${BLUE}Cleaning up old log files (keeping last 10)...${NC}"
        ls -1t "$LOG_DIR"/* | tail -n +11 | xargs rm -f
    fi
}

# Show log file location at end
show_log_location() {
    if $LOGGING_ENABLED; then
        echo ""
        echo -e "${CYAN}Full setup log saved to:${NC}"
        echo -e "  ${GREEN}$LOG_FILE${NC}"
        echo ""
        echo -e "${BLUE}Tip: Use this log file when troubleshooting or reporting issues${NC}"
        echo ""
    fi
}

