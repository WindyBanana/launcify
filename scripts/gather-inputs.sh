#!/bin/bash

# Gather all user inputs upfront (Phase 1: Interactive)

# Source required modules
source "$SCRIPT_DIR/scripts/interactive-ui.sh"
source "$SCRIPT_DIR/scripts/gather-api-keys.sh"

# Initialize config storage (using global variables for bash compatibility)
declare -g PROJECT_NAME=""
declare -g PACKAGE_MANAGER=""
declare -g FRAMEWORK="nextjs"
declare -g USE_VERCEL=false
declare -g USE_CONVEX=false
declare -g USE_CLERK=false
declare -g USE_AXIOM=false
declare -g USE_LINEAR=false
declare -g USE_SHADCN=false
declare -g USE_AI=false
declare -g AI_PROVIDER="none"
declare -g USE_ADMIN=false
declare -g USE_FEATURE_TOGGLES=false
declare -g USE_GITHUB=false
declare -g ADMIN_PROD_ENABLED=false

# Gather project name
gather_project_name() {
    echo -e "${CYAN}Step 1: Project Configuration${NC}"
    
    while true; do
        read -p "Enter project name (lowercase, hyphens only): " PROJECT_NAME
        
        # Validate project name
        if [[ ! $PROJECT_NAME =~ ^[a-z0-9-]+$ ]]; then
            echo -e "${RED}❌ Invalid project name. Use lowercase letters, numbers, and hyphens only.${NC}"
            continue
        fi
        
        if [ -z "$PROJECT_NAME" ]; then
            echo -e "${RED}❌ Project name cannot be empty.${NC}"
            continue
        fi
        
        break
    done
    
    echo -e "${GREEN}✓ Project name: $PROJECT_NAME${NC}"
    echo ""
}

# Determine project location
gather_project_location() {
    # Determine project creation directory
    PARENT_DIR="$(cd .. && pwd)"
    CURRENT_DIR="$(pwd)"
    
    echo -e "${YELLOW}📁 Project Location:${NC}"
    echo -e "   By default, your project will be created in the parent directory:"
    echo -e "   ${CYAN}$PARENT_DIR/$PROJECT_NAME${NC}"
    echo ""
    echo -e "   This keeps it separate from the Launchify template folder."
    echo ""
    read -p "Create project in parent directory? [Y/n]: " USE_PARENT
    USE_PARENT=${USE_PARENT:-Y}
    
    if [[ $USE_PARENT =~ ^[Yy]$ ]]; then
        PROJECT_DIR="$PARENT_DIR/$PROJECT_NAME"
        echo -e "${GREEN}✓ Project will be created at: $PROJECT_DIR${NC}"
    else
        PROJECT_DIR="$CURRENT_DIR/$PROJECT_NAME"
        echo -e "${GREEN}✓ Project will be created at: $PROJECT_DIR${NC}"
        echo -e "${YELLOW}⚠️  Note: Project will be created inside the Launchify directory${NC}"
    fi
    echo ""
}

# Gather package manager selection
gather_package_manager() {
    echo -e "${CYAN}Step 2: Package Manager${NC}"
    
    # Try interactive UI first, fall back to CLI
    if ! show_package_manager_ui; then
        echo "Select your package manager:"
        echo "  1) npm (default)"
        echo "  2) pnpm"
        echo "  3) yarn"
        read -p "Choice [1-3] (default: 1): " PKG_MANAGER_CHOICE
        
        case $PKG_MANAGER_CHOICE in
            2) PACKAGE_MANAGER="pnpm" ;;
            3) PACKAGE_MANAGER="yarn" ;;
            *) PACKAGE_MANAGER="npm" ;;
        esac
    fi
    
    echo -e "${GREEN}✓ Package manager: $PACKAGE_MANAGER${NC}"
    echo ""
}

# Gather framework selection
gather_framework() {
    echo -e "${CYAN}Step 3: Framework${NC}"
    echo "Select your framework:"
    echo "  1) Next.js 15 + TypeScript + Tailwind (recommended)"
    echo "  2) Plain React + TypeScript (coming soon)"
    echo "  3) Node.js Express API (coming soon)"
    read -p "Choice [1-3] (default: 1): " FRAMEWORK_CHOICE
    
    case $FRAMEWORK_CHOICE in
        1) FRAMEWORK="nextjs" ;;
        2)
            echo -e "${YELLOW}⚠️  Plain React template coming soon. Using Next.js for now.${NC}"
            FRAMEWORK="nextjs"
            ;;
        3)
            echo -e "${YELLOW}⚠️  Express template coming soon. Using Next.js for now.${NC}"
            FRAMEWORK="nextjs"
            ;;
        *) FRAMEWORK="nextjs" ;;
    esac
    
    echo -e "${GREEN}✓ Framework: $FRAMEWORK${NC}"
    echo ""
}

# Gather feature selections
gather_features() {
    echo -e "${CYAN}Step 4: Feature Selection${NC}"
    
    # Try interactive UI first (this will call the enhanced two-step wizard)
    if ! show_feature_selection_ui; then
        # Fallback to CLI mode
        echo -e "${YELLOW}Using CLI mode...${NC}"
        echo ""
        
        # Service Selection
        echo "Select services to integrate (y/n):"
        
        read -p "  Vercel (Deployment) [Y/n]: " USE_VERCEL
        USE_VERCEL=${USE_VERCEL:-Y}
        [[ $USE_VERCEL =~ ^[Yy]$ ]] && USE_VERCEL=true || USE_VERCEL=false
        
        read -p "  Convex (Backend/Database) [Y/n]: " USE_CONVEX
        USE_CONVEX=${USE_CONVEX:-Y}
        [[ $USE_CONVEX =~ ^[Yy]$ ]] && USE_CONVEX=true || USE_CONVEX=false
        
        read -p "  Clerk (Authentication) [Y/n]: " USE_CLERK
        USE_CLERK=${USE_CLERK:-Y}
        [[ $USE_CLERK =~ ^[Yy]$ ]] && USE_CLERK=true || USE_CLERK=false
        
        read -p "  Axiom (Observability) [y/N]: " USE_AXIOM
        USE_AXIOM=${USE_AXIOM:-N}
        [[ $USE_AXIOM =~ ^[Yy]$ ]] && USE_AXIOM=true || USE_AXIOM=false
        
        read -p "  Linear (Issue/Project Tracking) [y/N]: " USE_LINEAR
        USE_LINEAR=${USE_LINEAR:-N}
        [[ $USE_LINEAR =~ ^[Yy]$ ]] && USE_LINEAR=true || USE_LINEAR=false
        
        echo ""
        
        # UI & Features
        echo "Select additional features (y/n):"
        
        read -p "  shadcn/ui + Dark Mode [Y/n]: " USE_SHADCN
        USE_SHADCN=${USE_SHADCN:-Y}
        [[ $USE_SHADCN =~ ^[Yy]$ ]] && USE_SHADCN=true || USE_SHADCN=false
        
        read -p "  AI Integration [y/N]: " USE_AI
        USE_AI=${USE_AI:-N}
        [[ $USE_AI =~ ^[Yy]$ ]] && USE_AI=true || USE_AI=false
        
        # AI Provider selection
        if $USE_AI; then
            echo "  Which AI provider?"
            echo "    1) OpenAI (GPT-4, etc.)"
            echo "    2) Anthropic (Claude)"
            echo "    3) Both"
            read -p "  Choice [1-3]: " AI_CHOICE
            case $AI_CHOICE in
                1) AI_PROVIDER="openai" ;;
                2) AI_PROVIDER="anthropic" ;;
                3) AI_PROVIDER="both" ;;
                *) AI_PROVIDER="openai" ;;
            esac
        fi
        
        # Admin panel (only if Convex)
        if $USE_CONVEX; then
            read -p "  Admin Panel (requires Convex) [y/N]: " USE_ADMIN
            USE_ADMIN=${USE_ADMIN:-N}
            [[ $USE_ADMIN =~ ^[Yy]$ ]] && USE_ADMIN=true || USE_ADMIN=false
            
            # Feature Toggles (only if Convex)
            read -p "  Feature Toggle Dashboard (requires Convex) [y/N]: " USE_FEATURE_TOGGLES
            USE_FEATURE_TOGGLES=${USE_FEATURE_TOGGLES:-N}
            [[ $USE_FEATURE_TOGGLES =~ ^[Yy]$ ]] && USE_FEATURE_TOGGLES=true || USE_FEATURE_TOGGLES=false
        else
            USE_ADMIN=false
            USE_FEATURE_TOGGLES=false
        fi
        
        # GitHub CI/CD
        read -p "  GitHub Repository + CI/CD [y/N]: " USE_GITHUB
        USE_GITHUB=${USE_GITHUB:-N}
        [[ $USE_GITHUB =~ ^[Yy]$ ]] && USE_GITHUB=true || USE_GITHUB=false
    fi
    
    # Check if admin panel requires Convex
    if $USE_ADMIN && ! $USE_CONVEX; then
        echo -e "\n${YELLOW}⚠️  Admin Panel requires Convex backend.${NC}"
        read -p "Enable Convex? [Y/n]: " ENABLE_CONVEX_FOR_ADMIN
        ENABLE_CONVEX_FOR_ADMIN=${ENABLE_CONVEX_FOR_ADMIN:-Y}
        if [[ $ENABLE_CONVEX_FOR_ADMIN =~ ^[Yy]$ ]]; then
            USE_CONVEX=true
            echo -e "${GREEN}✓ Convex enabled${NC}"
        else
            USE_ADMIN=false
            echo -e "${YELLOW}⚠️  Admin Panel disabled (requires Convex)${NC}"
        fi
    fi
    
    # Admin panel production setting
    if $USE_ADMIN; then
        read -p "  Enable admin panel in production? [y/N]: " ADMIN_PROD
        ADMIN_PROD=${ADMIN_PROD:-N}
        [[ $ADMIN_PROD =~ ^[Yy]$ ]] && ADMIN_PROD_ENABLED=true || ADMIN_PROD_ENABLED=false
    fi
    
    echo ""
}

# Show configuration summary and confirm
show_configuration_summary() {
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Configuration Summary:${NC}"
    echo -e "  Project: ${GREEN}$PROJECT_NAME${NC}"
    echo -e "  Package Manager: ${GREEN}$PACKAGE_MANAGER${NC}"
    echo -e "  Framework: ${GREEN}$FRAMEWORK${NC}"
    echo -e "  Services:"
    $USE_VERCEL && echo -e "    ${GREEN}✓${NC} Vercel" || echo -e "    ${RED}✗${NC} Vercel"
    $USE_CONVEX && echo -e "    ${GREEN}✓${NC} Convex" || echo -e "    ${RED}✗${NC} Convex"
    $USE_CLERK && echo -e "    ${GREEN}✓${NC} Clerk" || echo -e "    ${RED}✗${NC} Clerk"
    $USE_AXIOM && echo -e "    ${GREEN}✓${NC} Axiom" || echo -e "    ${RED}✗${NC} Axiom"
    $USE_LINEAR && echo -e "    ${GREEN}✓${NC} Linear" || echo -e "    ${RED}✗${NC} Linear"
    echo -e "  Features:"
    $USE_SHADCN && echo -e "    ${GREEN}✓${NC} shadcn/ui + Dark Mode" || echo -e "    ${RED}✗${NC} shadcn/ui"
    if $USE_AI; then
        echo -e "    ${GREEN}✓${NC} AI Integration ($AI_PROVIDER)"
    else
        echo -e "    ${RED}✗${NC} AI Integration"
    fi
    $USE_ADMIN && echo -e "    ${GREEN}✓${NC} Admin Panel" || echo -e "    ${RED}✗${NC} Admin Panel"
    $USE_FEATURE_TOGGLES && echo -e "    ${GREEN}✓${NC} Feature Toggle Dashboard" || echo -e "    ${RED}✗${NC} Feature Toggle Dashboard"
    $USE_GITHUB && echo -e "    ${GREEN}✓${NC} GitHub CI/CD" || echo -e "    ${RED}✗${NC} GitHub CI/CD"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}Note: You can cancel here to safely restart configuration.${NC}"
    echo ""
    
    read -p "Proceed with this configuration? [Y/n]: " CONFIRM
    CONFIRM=${CONFIRM:-Y}
    
    if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Configuration cancelled. Run the script again to start over.${NC}"
        exit 0
    fi
    
    echo ""
}

# Gather API keys for services that need them
gather_api_keys_for_services() {
    # Determine which services need API keys
    local needs_api_keys=false
    
    if $USE_CLERK || $USE_AI || $USE_LINEAR; then
        needs_api_keys=true
    fi
    
    if $needs_api_keys; then
        # Check if TUI is available
        local use_tui=true
        if ! command -v whiptail &> /dev/null && ! command -v dialog &> /dev/null; then
            use_tui=false
        fi
        
        gather_all_api_keys "$USE_CLERK" "$USE_AI" "$AI_PROVIDER" "$USE_LINEAR" "$use_tui"
    fi
}

# Main gather function - orchestrates all input collection
gather_all_inputs() {
    echo ""
    echo -e "${PURPLE}PHASE 1: GATHER INPUTS${NC}"
    echo -e "${BLUE}(All questions will be asked upfront)${NC}"
    echo ""
    
    # Step 1: Project name and location
    gather_project_name
    gather_project_location
    
    # Step 2: Package manager
    gather_package_manager
    
    # Step 3: Framework
    gather_framework
    
    # Step 4: Try to load a saved config, use preset, or do custom selection
    if load_saved_config; then
        # Loaded a saved configuration
        echo -e "${BLUE}Using saved configuration${NC}"
        echo ""
    elif show_preset_menu; then
        # Preset was loaded and confirmed
        echo -e "${BLUE}Using preset configuration${NC}"
        echo ""
    else
        # User chose custom or declined preset - use interactive selection
        gather_features
    fi
    
    # Step 5: Show summary and confirm
    show_configuration_summary
    
    # Step 6: Gather API keys for selected services
    gather_api_keys_for_services
    
    echo ""
    echo -e "${GREEN}✓ All inputs collected!${NC}"
    echo -e "${GREEN}Beginning automated setup...${NC}"
    echo ""
    
    return 0
}

