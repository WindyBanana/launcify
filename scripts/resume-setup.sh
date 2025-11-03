#!/bin/bash

# Resume/recovery functions for partial setups

# Check if project already exists and what's been configured
check_existing_project() {
    local project_name=$1

    if [ ! -d "$project_name" ]; then
        return 1  # Project doesn't exist
    fi

    return 0  # Project exists
}

# Detect what's already configured
detect_configured_services() {
    local project_name=$1

    # Check if we're in the project directory
    if [ ! -f "package.json" ]; then
        if [ -d "$project_name" ]; then
            cd "$project_name" || return 1
        else
            return 1
        fi
    fi

    # Check Vercel
    HAS_VERCEL=false
    if [ -f ".vercel/project.json" ]; then
        HAS_VERCEL=true
    fi

    # Check Convex
    HAS_CONVEX=false
    if [ -d "convex" ] && grep -q "CONVEX" .env.local 2>/dev/null; then
        HAS_CONVEX=true
    fi

    # Check Clerk
    HAS_CLERK=false
    if grep -q "CLERK" .env.local 2>/dev/null; then
        HAS_CLERK=true
    fi

    # Check Axiom
    HAS_AXIOM=false
    if grep -q "AXIOM" .env.local 2>/dev/null && [ -f "lib/axiom.ts" ]; then
        HAS_AXIOM=true
    fi

    # Check shadcn/ui
    HAS_SHADCN=false
    if [ -f "components.json" ]; then
        HAS_SHADCN=true
    fi

    # Check AI
    HAS_AI=false
    if [ -d "lib/ai" ]; then
        HAS_AI=true
    fi

    # Check Admin Panel
    HAS_ADMIN=false
    if [ -d "app/admin" ]; then
        HAS_ADMIN=true
    fi

    # Check if env file exists
    HAS_ENV=false
    if [ -f ".env.local" ]; then
        HAS_ENV=true
    fi

    # Check if setup guide exists
    HAS_GUIDE=false
    if [ -f "SETUP_GUIDE.md" ]; then
        HAS_GUIDE=true
    fi
}

# Show what's already configured
show_existing_configuration() {
    echo -e "${CYAN}Existing configuration detected:${NC}"
    echo -e "  Services:"
    $HAS_VERCEL && echo -e "    ${GREEN}✓${NC} Vercel" || echo -e "    ${RED}✗${NC} Vercel"
    $HAS_CONVEX && echo -e "    ${GREEN}✓${NC} Convex" || echo -e "    ${RED}✗${NC} Convex"
    $HAS_CLERK && echo -e "    ${GREEN}✓${NC} Clerk" || echo -e "    ${RED}✗${NC} Clerk"
    $HAS_AXIOM && echo -e "    ${GREEN}✓${NC} Axiom" || echo -e "    ${RED}✗${NC} Axiom"
    echo -e "  Features:"
    $HAS_SHADCN && echo -e "    ${GREEN}✓${NC} shadcn/ui" || echo -e "    ${RED}✗${NC} shadcn/ui"
    $HAS_AI && echo -e "    ${GREEN}✓${NC} AI Integration" || echo -e "    ${RED}✗${NC} AI Integration"
    $HAS_ADMIN && echo -e "    ${GREEN}✓${NC} Admin Panel" || echo -e "    ${RED}✗${NC} Admin Panel"
    echo -e "  Configuration:"
    $HAS_ENV && echo -e "    ${GREEN}✓${NC} .env.local" || echo -e "    ${RED}✗${NC} .env.local"
    $HAS_GUIDE && echo -e "    ${GREEN}✓${NC} SETUP_GUIDE.md" || echo -e "    ${RED}✗${NC} SETUP_GUIDE.md"
}

# Ask user what to do with existing project
ask_resume_action() {
    echo -e "\n${YELLOW}Project '$PROJECT_NAME' already exists!${NC}"
    echo ""
    show_existing_configuration
    echo ""
    echo "What would you like to do?"
    echo "  1) Resume setup (complete missing configuration)"
    echo "  2) Skip (exit without changes)"
    echo "  3) Start fresh (delete and recreate)"
    echo ""
    read -p "Choice [1-3]: " RESUME_ACTION

    case $RESUME_ACTION in
        1)
            echo -e "${GREEN}✓ Resuming setup...${NC}"
            return 0  # Resume
            ;;
        2)
            echo -e "${YELLOW}✓ Exiting without changes${NC}"
            exit 0
            ;;
        3)
            echo -e "${RED}⚠️  This will DELETE the existing project!${NC}"
            read -p "Are you sure? [y/N]: " CONFIRM_DELETE
            if [[ $CONFIRM_DELETE =~ ^[Yy]$ ]]; then
                rm -rf "$PROJECT_NAME"
                echo -e "${GREEN}✓ Project deleted${NC}"
                return 1  # Start fresh
            else
                echo -e "${YELLOW}✓ Cancelled - exiting${NC}"
                exit 0
            fi
            ;;
        *)
            echo -e "${RED}Invalid choice - exiting${NC}"
            exit 1
            ;;
    esac
}

# Determine if a service should be set up
should_setup_service() {
    local service_name=$1
    local user_wants=$2  # true/false
    local already_has=$3  # true/false

    # If user doesn't want it, skip
    if ! $user_wants; then
        return 1
    fi

    # If already configured, skip
    if $already_has; then
        echo -e "${BLUE}✓ $service_name already configured, skipping${NC}"
        return 1
    fi

    # User wants it and doesn't have it yet
    return 0
}
