#!/bin/bash

# Launchify - Project Template Generator
# Transform your idea into a production-ready project with automated service setup

# Note: We don't use 'set -e' because we handle errors through the checkpoint system

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Parse command-line arguments
DRY_RUN_MODE=false
for arg in "$@"; do
    case $arg in
        --dry-run)
            DRY_RUN_MODE=true
            shift
            ;;
        --help|-h)
            echo "Launchify - Project Template Generator"
            echo ""
            echo "Usage: ./create-project.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --dry-run    Run pre-flight checks without making changes"
            echo "  --help, -h   Show this help message"
            echo ""
            exit 0
            ;;
        *)
            ;;
    esac
done

# Source helper scripts
source "$SCRIPT_DIR/scripts/error-handling.sh"
source "$SCRIPT_DIR/scripts/logging.sh"
source "$SCRIPT_DIR/scripts/progress.sh"
source "$SCRIPT_DIR/scripts/presets.sh"
source "$SCRIPT_DIR/scripts/health-check.sh"
source "$SCRIPT_DIR/scripts/check-dependencies.sh"
source "$SCRIPT_DIR/scripts/install-clis.sh"
source "$SCRIPT_DIR/scripts/setup-vercel.sh"
source "$SCRIPT_DIR/scripts/setup-convex.sh"
source "$SCRIPT_DIR/scripts/setup-axiom.sh"
source "$SCRIPT_DIR/scripts/setup-clerk.sh"
source "$SCRIPT_DIR/scripts/setup-shadcn.sh"
source "$SCRIPT_DIR/scripts/setup-ai.sh"
source "$SCRIPT_DIR/scripts/setup-admin.sh"
source "$SCRIPT_DIR/scripts/utils.sh"
source "$SCRIPT_DIR/scripts/resume-setup.sh"
source "$SCRIPT_DIR/scripts/setup-vercel-env.sh"
source "$SCRIPT_DIR/scripts/detect-platform.sh"
source "$SCRIPT_DIR/scripts/interactive-ui.sh"
source "$SCRIPT_DIR/scripts/setup-feature-toggles.sh"
source "$SCRIPT_DIR/scripts/setup-github.sh"
source "$SCRIPT_DIR/scripts/gather-inputs.sh"
source "$SCRIPT_DIR/scripts/execute-setup.sh"
source "$SCRIPT_DIR/scripts/dry-run.sh"
source "$SCRIPT_DIR/scripts/verify-actions.sh"

# Welcome & Information
echo ""
echo -e "${CYAN}WELCOME TO LAUNCHIFY${NC}"
echo ""
echo -e "${GREEN}Launchify accelerates your development workflow by automating${NC}"
echo -e "${GREEN}the setup of modern web applications with production-ready tools.${NC}"
echo ""
echo -e "${CYAN}Perfect for developers who:${NC}"
echo "  • Want to skip repetitive setup and get straight to coding"
echo "  • Need a standardized project structure across teams"
echo "  • Prefer automated configuration over manual setup"
echo "  • Are familiar with modern web development practices"
echo ""
echo -e "${YELLOW}What This Tool Does:${NC}"
echo ""
echo -e "${BLUE}✓ Project Setup:${NC}"
echo "  • Creates a Next.js project with TypeScript and Tailwind CSS"
echo "  • Generates configuration files (.env, package.json, etc.)"
echo "  • Installs npm packages within your project directory"
echo "  • Sets up Git repository with proper .gitignore"
echo ""
echo -e "${BLUE}✓ Service Integration (optional):${NC}"
echo "  • Configures deployment (Vercel)"
echo "  • Sets up authentication (Clerk)"
echo "  • Connects backend services (Convex)"
echo "  • Integrates observability (Axiom)"
echo ""
echo -e "${BLUE}✓ Developer Tools (optional - requires your consent):${NC}"
echo "  • May offer to install CLI tools: Vercel, Axiom, GitHub CLIs"
echo "  • May offer to install UI tools: dialog/whiptail for better UX"
echo "  • You will be prompted before each installation"
echo "  • You can decline any installation - the script adapts accordingly"
echo ""
echo -e "${YELLOW}Important Notes:${NC}"
echo ""
echo "• This tool is designed for developers familiar with the stack"
echo "• Generated code should be reviewed before production deployment"
echo "• You are responsible for API costs, security, and compliance"
echo "• This software is provided as-is (see LICENSE for details)"
echo ""
echo -e "${CYAN}✨ Built-in Safety Features:${NC}"
echo "• Setup progress is automatically saved at each step"
echo "• If anything fails, you can resume from where you left off"
echo "• Full logs saved to ~/.launchify/logs/ for troubleshooting"
echo "• Just run the script again to continue"
echo ""
echo -e "${CYAN}By continuing, you acknowledge that you understand what this${NC}"
echo -e "${CYAN}tool does and will review generated configurations appropriately.${NC}"
echo ""
read -p "Ready to begin? [y/N]: " ACCEPT_TERMS
ACCEPT_TERMS=${ACCEPT_TERMS:-N}

if [[ ! $ACCEPT_TERMS =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${YELLOW}No problem! Feel free to review the code and run again when ready.${NC}"
    exit 0
fi
echo ""
echo -e "${GREEN}✓ Great! Let's build something amazing.${NC}"
echo ""

# Safety Check: Prevent running inside launchify directory
if [ -f "$SCRIPT_DIR/create-project.sh" ] && [ -d "$SCRIPT_DIR/scripts" ] && [ -d "$SCRIPT_DIR/templates" ]; then
    CURRENT_DIR=$(basename "$PWD")
    if [ "$PWD" = "$SCRIPT_DIR" ]; then
        echo ""
        echo -e "${RED}⚠️  SAFETY WARNING: Wrong Directory!${NC}"
        echo ""
        echo -e "${YELLOW}You are running the generator inside the launchify directory itself!${NC}"
        echo -e "${YELLOW}This will create your project as a subdirectory of the generator.${NC}"
        echo ""
        echo -e "${CYAN}Recommended:${NC}"
        echo -e "  1. ${CYAN}cd ..${NC} (go up one directory)"
        echo -e "  2. ${CYAN}./launchify/create-project.sh${NC} (run from parent directory)"
        echo ""
        echo -e "${YELLOW}This way your project will be created alongside launchify, not inside it.${NC}"
        echo ""
        read -p "Continue anyway? [y/N]: " CONTINUE_ANYWAY
        CONTINUE_ANYWAY=${CONTINUE_ANYWAY:-N}

        if [[ ! $CONTINUE_ANYWAY =~ ^[Yy]$ ]]; then
            echo -e "${GREEN}Good choice! Run from the parent directory instead.${NC}"
            exit 0
        fi

        echo -e "${YELLOW}⚠️  Proceeding anyway (not recommended)${NC}\n"
    fi
fi

# Security Notice
echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         SECURITY & PRIVACY NOTICE                          ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}✅ Safe Practices This Script Uses:${NC}"
echo ""
echo -e "  ${BLUE}What Gets Committed to Git:${NC}"
echo -e "    • Project code and configuration files"
echo -e "    • Templates and .gitignore"
echo -e "    • Setup guides and documentation"
echo ""
echo -e "  ${GREEN}What NEVER Gets Committed:${NC}"
echo -e "    • ${RED}.env.local${NC} - Your development secrets (in .gitignore)"
echo -e "    • ${RED}.env.production${NC} - Production secrets (in .gitignore)"
echo -e "    • ${RED}API keys and tokens${NC} - Never stored in Git"
echo ""
echo -e "  ${BLUE}How Environment Variables Are Set:${NC}"
echo -e "    • ${CYAN}Manual Entry:${NC} You type them when prompted (Clerk, Linear, AI)"
echo -e "    • ${CYAN}Vercel API:${NC} Sent directly to Vercel cloud (encrypted)"
echo -e "    • ${CYAN}Convex CLI:${NC} Managed by Convex deployment"
echo -e "    • ${CYAN}Axiom CLI:${NC} Managed by Axiom cloud"
echo ""
echo -e "  ${YELLOW}⚠️  Important:${NC}"
echo -e "    • Secrets stored ${GREEN}locally in .env.local${NC} (on your machine only)"
echo -e "    • Production secrets set ${GREEN}in Vercel dashboard${NC} (encrypted)"
echo -e "    • ${RED}Never commit .env files to Git${NC} (already in .gitignore)"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Platform Detection
setup_platform_tools
echo ""

# Initialize detection flags for resume functionality  
HAS_VERCEL=false
HAS_CONVEX=false
HAS_CLERK=false
HAS_AXIOM=false
HAS_SHADCN=false
HAS_AI=false
HAS_ADMIN=false
HAS_FEATURE_TOGGLES=false
HAS_GITHUB=false
HAS_ENV=false
HAS_GUIDE=false
RESUMING=false

# Check for checkpoint resume state BEFORE gathering inputs
RESUME_FROM_STEP=0
if load_state; then
    echo -e "${BLUE}Resuming from saved state...${NC}"
    echo ""
    RESUMING=true
    # Skip gather phase - we have the config
    
    # Initialize logging for resumed session
    init_logging "$PROJECT_NAME"
    cleanup_old_logs
else
    # GATHER PHASE: Collect all inputs upfront
    gather_all_inputs
    
    # Initialize logging after we have the project name
    init_logging "$PROJECT_NAME"
    cleanup_old_logs
    
    # Initialize state tracking after gathering inputs
    init_state_tracking "$PROJECT_NAME"
fi

# Check if we're resuming an existing project
if [ -d "$PROJECT_NAME" ]; then
    detect_configured_services "$PROJECT_NAME"
    
    if ask_resume_action; then
        RESUMING=true
        cd "$PROJECT_NAME" || exit 1
        echo -e "${GREEN}✓ Resuming setup for '$PROJECT_NAME'${NC}\n"
    else
        RESUMING=false
    fi
fi

# DRY RUN MODE: Just report what would happen, then exit
if $DRY_RUN_MODE; then
    perform_dry_run "$PROJECT_NAME" "$PACKAGE_MANAGER"
    exit $?
fi

# Initialize progress tracking
init_progress

# EXECUTE PHASE: Run all setup non-interactively
execute_all_setup

# Show completion summary
show_completion_summary

# Run health check
run_health_check

# Clean up state tracking on successful completion
cleanup_state

# Offer to save this configuration for future use
offer_save_config

# Show log file location
show_log_location

# Final Summary
echo ""
echo -e "${GREEN}PROJECT SETUP COMPLETE!${NC}"
echo ""

echo -e "${CYAN}Project created at: ${GREEN}$PROJECT_DIR${NC}\n"

# Show detailed manual setup summary
CLERK_AUTOMATED=${CLERK_AUTOMATED:-false}
show_manual_setup_summary "$USE_CLERK" "$USE_AXIOM" "$USE_LINEAR" "$USE_AI" "$AI_PROVIDER" "$CLERK_AUTOMATED"

echo -e "${YELLOW}GETTING STARTED - RUNNING YOUR PROJECT${NC}"
echo ""

echo -e "${CYAN}1. Navigate to your project:${NC}"
echo -e "   ${GREEN}cd $PROJECT_DIR${NC}\n"

echo -e "${CYAN}2. Review and update environment variables:${NC}"
echo -e "   ${GREEN}# Edit .env.local and add your API keys${NC}"
echo -e "   ${GREEN}# See the manual setup instructions above for details${NC}\n"

if $USE_CONVEX; then
    echo -e "${CYAN}3. Start your development servers:${NC}"
    echo -e "   ${GREEN}# Terminal 1 - Start Convex${NC}"
    echo -e "   ${GREEN}npx convex dev${NC}\n"
    echo -e "   ${GREEN}# Terminal 2 - Start Next.js${NC}"
    echo -e "   ${GREEN}$PACKAGE_MANAGER run dev${NC}\n"
    echo -e "   ${BLUE}Your app will be running at: ${CYAN}http://localhost:3000${NC}\n"
else
    echo -e "${CYAN}3. Start your development server:${NC}"
    echo -e "   ${GREEN}$PACKAGE_MANAGER run dev${NC}\n"
    echo -e "   ${BLUE}Your app will be running at: ${CYAN}http://localhost:3000${NC}\n"
fi

if $USE_ADMIN; then
    echo -e "${CYAN}4. Access the admin panel:${NC}"
    echo -e "   ${GREEN}http://localhost:3000/admin${NC}\n"
fi

# Only show git push instructions if user didn't already push
if [[ ! $SETUP_GITHUB =~ ^[Yy]$ ]]; then
    echo -e "${CYAN}5. Push to GitHub (when ready):${NC}"
    echo -e "   ${GREEN}git remote add origin <your-repo-url>${NC}"
    echo -e "   ${GREEN}git push -u origin main${NC}\n"
fi

echo ""
echo -e "${GREEN}Happy coding!${NC}"
echo ""
