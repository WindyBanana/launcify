#!/bin/bash

# Error handling and resume functionality for Launchify

# State file location
STATE_DIR=".launchify-state"
STATE_FILE="${STATE_DIR}/progress.state"
CONFIG_FILE="${STATE_DIR}/config.state"

# Initialize state tracking
init_state_tracking() {
    local project_name=$1

    # Create state directory in target location
    mkdir -p "$STATE_DIR"

    # Save configuration for resume
    cat > "$CONFIG_FILE" << EOF
PROJECT_NAME="$project_name"
PACKAGE_MANAGER="$PACKAGE_MANAGER"
FRAMEWORK="$FRAMEWORK"
USE_VERCEL=$USE_VERCEL
USE_CONVEX=$USE_CONVEX
USE_CLERK=$USE_CLERK
USE_AXIOM=$USE_AXIOM
USE_LINEAR=$USE_LINEAR
USE_SHADCN=$USE_SHADCN
USE_AI=$USE_AI
AI_PROVIDER="$AI_PROVIDER"
USE_ADMIN=$USE_ADMIN
ADMIN_PROD_ENABLED=$ADMIN_PROD_ENABLED
USE_FEATURE_TOGGLES=$USE_FEATURE_TOGGLES
USE_GITHUB=$USE_GITHUB
TIMESTAMP=$(date +%s)
EOF

    echo "0" > "$STATE_FILE"
    echo -e "${GREEN}✓ State tracking initialized${NC}"
}

# Load state if resuming
load_state() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
        local current_step=$(cat "$STATE_FILE" 2>/dev/null || echo "0")

        echo ""
        echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
        echo -e "${YELLOW}PREVIOUS SETUP DETECTED${NC}"
        echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
        echo ""
        echo -e "${CYAN}Found saved progress:${NC}"
        echo -e "  Project: ${GREEN}$PROJECT_NAME${NC}"
        echo -e "  Last completed step: ${GREEN}$current_step of 14${NC}"
        echo -e "  Time: $(date -d @$TIMESTAMP '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date -r $TIMESTAMP '+%Y-%m-%d %H:%M:%S' 2>/dev/null || echo 'Unknown')"
        echo ""
        echo -e "${BLUE}💡 You can continue from where you left off!${NC}"
        echo ""

        read -p "Resume from step $((current_step + 1))? [Y/n]: " resume_choice
        resume_choice=${resume_choice:-Y}

        if [[ $resume_choice =~ ^[Yy]$ ]]; then
            RESUME_FROM_STEP=$current_step
            return 0
        else
            echo -e "${YELLOW}Starting fresh setup...${NC}"
            rm -rf "$STATE_DIR"
            RESUME_FROM_STEP=0
            return 1
        fi
    fi

    RESUME_FROM_STEP=0
    return 1
}

# Mark step as completed
mark_step_completed() {
    local step=$1
    echo "$step" > "$STATE_FILE"
}

# Check if step should be skipped (already completed)
should_skip_step() {
    local step=$1
    if [ "$RESUME_FROM_STEP" -ge "$step" ]; then
        echo -e "${BLUE}✓ Skipping step $step (already completed)${NC}"
        return 0
    fi
    return 1
}

# Wrap command with error handling
safe_execute() {
    local step_number=$1
    local step_name=$2
    local command=$3
    local allow_failure=${4:-false}

    echo -e "${CYAN}Executing: $step_name${NC}"

    # Execute command and capture output
    if eval "$command" 2>&1; then
        echo -e "${GREEN}✓ $step_name completed${NC}"
        mark_step_completed "$step_number"
        return 0
    else
        local exit_code=$?
        echo -e "${RED}✗ $step_name failed (exit code: $exit_code)${NC}"

        if $allow_failure; then
            echo -e "${YELLOW}⚠️  Continuing despite failure...${NC}"
            return 0
        fi

        # Offer recovery options
        offer_recovery_options "$step_number" "$step_name"
        return $?
    fi
}

# Offer recovery options on failure
offer_recovery_options() {
    local step=$1
    local step_name=$2

    echo ""
    echo -e "${YELLOW}⚠️  STEP FAILED: $step_name${NC}"
    echo ""
    echo -e "${CYAN}What would you like to do?${NC}"
    echo ""
    echo -e "  1) ${GREEN}Retry${NC} - Try this step again right now"
    echo -e "  2) ${YELLOW}Skip${NC} - Skip this step and continue (may cause issues)"
    echo -e "  3) ${CYAN}Manual${NC} - I'll fix it manually, mark as done"
    echo -e "  4) ${RED}Abort${NC} - Stop here, I'll fix it later"
    echo ""
    echo -e "${BLUE}💡 If you choose Abort:${NC}"
    echo -e "   • Your progress is saved automatically"
    echo -e "   • Just run ./create-project.sh again to resume from this step"
    echo -e "   • Check the log file at ~/.launchify/logs/ for details"
    echo ""
    
    read -p "Choose option [1-4]: " recovery_choice

    case $recovery_choice in
        1)
            echo -e "${BLUE}Retrying...${NC}"
            return 2  # Signal to retry
            ;;
        2)
            echo -e "${YELLOW}⚠️  Skipping step. This may cause issues later.${NC}"
            mark_step_completed "$step"
            return 0
            ;;
        3)
            echo -e "${GREEN}Marking as completed${NC}"
            mark_step_completed "$step"
            return 0
            ;;
        4|*)
            echo ""
            echo -e "${RED}Setup paused at step $step${NC}"
            echo ""
            echo -e "${CYAN}To resume:${NC}"
            echo -e "  1. Fix the issue (check logs at ~/.launchify/logs/)"
            echo -e "  2. Run: ${GREEN}./create-project.sh${NC}"
            echo -e "  3. The script will automatically resume from this step"
            echo ""
            return 1
            ;;
    esac
}

# Service-specific error handling
handle_service_error() {
    local service=$1
    local error_type=$2

    echo ""
    echo -e "${YELLOW}⚠️  $service SETUP FAILED${NC}"
    echo ""

    case $service in
        "Clerk")
            echo -e "${CYAN}Clerk setup failed. This is usually because:${NC}"
            echo -e "  • Invalid API keys"
            echo -e "  • Network connectivity issues"
            echo -e "  • Svix API rate limiting"
            echo ""
            echo -e "${BLUE}You can:${NC}"
            echo -e "  1. Complete Clerk setup manually later (See SETUP_GUIDE.md)"
            echo -e "  2. Retry with correct credentials"
            ;;
        "Vercel")
            echo -e "${CYAN}Vercel setup failed. This is usually because:${NC}"
            echo -e "  • Not logged in to Vercel CLI"
            echo -e "  • Project name already exists"
            echo -e "  • Network connectivity issues"
            echo ""
            echo -e "${BLUE}You can:${NC}"
            echo -e "  1. Run 'vercel login' and retry"
            echo -e "  2. Link manually with 'vercel link' later"
            ;;
        "Convex")
            echo -e "${CYAN}Convex setup failed. This is usually because:${NC}"
            echo -e "  • Not logged in to Convex"
            echo -e "  • Project initialization timeout"
            echo -e "  • Network connectivity issues"
            echo ""
            echo -e "${BLUE}You can:${NC}"
            echo -e "  1. Run 'npx convex dev' manually later"
            echo -e "  2. Complete setup interactively"
            ;;
        "Axiom")
            echo -e "${CYAN}Axiom setup failed. This is usually because:${NC}"
            echo -e "  • CLI not installed correctly"
            echo -e "  • Not logged in"
            echo -e "  • Dataset creation failed"
            echo ""
            echo -e "${BLUE}You can:${NC}"
            echo -e "  1. Run 'axiom auth login' and complete manually"
            echo -e "  2. Skip and add observability later"
            ;;
    esac

    echo ""
    read -p "Continue without $service? [y/N]: " skip_service
    skip_service=${skip_service:-N}

    if [[ $skip_service =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}⚠️  Continuing without $service${NC}"
        echo -e "${BLUE}ℹ️  See SETUP_GUIDE.md for manual setup instructions${NC}"
        return 0
    else
        return 1
    fi
}

# Clean up state on successful completion
cleanup_state() {
    if [ -d "$STATE_DIR" ]; then
        rm -rf "$STATE_DIR"
        echo -e "${GREEN}✓ State tracking cleaned up${NC}"
    fi
}

# Rollback function for critical failures
rollback_project() {
    local project_name=$1

    echo ""
    echo -e "${RED}⚠️  CRITICAL FAILURE - ROLLBACK OPTION${NC}"
    echo ""
    echo -e "${YELLOW}The project creation encountered a critical error.${NC}"
    echo ""

    read -p "Delete incomplete project '$project_name'? [y/N]: " delete_choice
    delete_choice=${delete_choice:-N}

    if [[ $delete_choice =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Rolling back...${NC}"
        cd ..
        rm -rf "$project_name"
        rm -rf "$STATE_DIR"
        echo -e "${GREEN}✓ Rollback complete${NC}"
        echo -e "${CYAN}You can run the script again to start fresh.${NC}"
        return 0
    else
        echo -e "${YELLOW}Incomplete project kept: $project_name${NC}"
        echo -e "${CYAN}You can resume setup later or fix issues manually.${NC}"
        return 1
    fi
}

# Validate environment before starting
validate_environment() {
    local errors=0

    echo -e "${CYAN}Validating environment...${NC}"

    # Check Node.js
    if ! command -v node &> /dev/null; then
        echo -e "${RED}✗ Node.js not found${NC}"
        ((errors++))
    else
        local node_version=$(node -v | sed 's/v//')
        echo -e "${GREEN}✓ Node.js $node_version${NC}"
    fi

    # Check npm/pnpm/yarn based on selection
    if ! command -v "$PACKAGE_MANAGER" &> /dev/null; then
        echo -e "${RED}✗ $PACKAGE_MANAGER not found${NC}"
        ((errors++))
    else
        echo -e "${GREEN}✓ $PACKAGE_MANAGER${NC}"
    fi

    # Check git
    if ! command -v git &> /dev/null; then
        echo -e "${RED}✗ git not found${NC}"
        ((errors++))
    else
        echo -e "${GREEN}✓ git${NC}"
    fi

    # Check disk space (need at least 500MB)
    local available_space=$(df -m . | tail -1 | awk '{print $4}')
    if [ "$available_space" -lt 500 ]; then
        echo -e "${YELLOW}⚠️  Low disk space: ${available_space}MB available${NC}"
        echo -e "${YELLOW}   Recommended: 500MB+${NC}"
    else
        echo -e "${GREEN}✓ Disk space: ${available_space}MB available${NC}"
    fi

    if [ $errors -gt 0 ]; then
        echo ""
        echo -e "${RED}Environment validation failed with $errors error(s)${NC}"
        return 1
    fi

    echo -e "${GREEN}✓ Environment validation passed${NC}"
    return 0
}
