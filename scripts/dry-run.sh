#!/bin/bash

# Dry run functionality to check dependencies and authentication

perform_dry_run() {
    local project_name=$1
    local package_manager=$2
    
    echo ""
    echo -e "${PURPLE}DRY RUN MODE - NO CHANGES${NC}"
    echo ""
    echo -e "${CYAN}Project: ${GREEN}$project_name${NC}"
    echo -e "${CYAN}Package Manager: ${GREEN}$package_manager${NC}"
    echo ""
    echo -e "Verifying dependencies, authentication, and planned actions..."
    echo ""

    local all_ok=true
    local warnings=0

    # --- Dependency Checks ---
    echo -e "${CYAN}1. Dependency Check${NC}"
    echo ""
    
    source "$(dirname "$0")/check-dependencies.sh"
    check_dependencies "$USE_VERCEL" "$USE_CONVEX" "$USE_AXIOM" "$package_manager"
    
    echo ""

    # --- Authentication Checks ---
    echo -e "${CYAN}2. Authentication Status${NC}"
    echo ""

    if $USE_GITHUB; then
        if command -v gh &> /dev/null; then
            if gh auth status &> /dev/null; then
                echo -e "  ${GREEN}✓ GitHub CLI (gh) - Logged in${NC}"
            else
                echo -e "  ${RED}✗ GitHub CLI (gh) - Not logged in${NC}"
                echo -e "    ${YELLOW}Remediation: gh auth login${NC}"
                all_ok=false
            fi
        else
            echo -e "  ${YELLOW}⚠️  GitHub CLI (gh) - Not installed${NC}"
            ((warnings++))
        fi
    fi

    if $USE_VERCEL; then
        if vercel whoami &> /dev/null; then
            echo -e "  ${GREEN}✓ Vercel CLI - Logged in as $(vercel whoami)${NC}"
        else
            echo -e "  ${RED}✗ Vercel CLI - Not logged in${NC}"
            echo -e "    ${YELLOW}Remediation: vercel login${NC}"
            all_ok=false
        fi
    fi

    if $USE_CONVEX; then
        echo -e "  ${CYAN}ℹ️  Convex - Login handled during setup (browser-based)${NC}"
    fi

    if $USE_AXIOM; then
        if command -v axiom &> /dev/null; then
            if axiom auth status &> /dev/null; then
                echo -e "  ${GREEN}✓ Axiom CLI - Logged in${NC}"
            else
                echo -e "  ${RED}✗ Axiom CLI - Not logged in${NC}"
                echo -e "    ${YELLOW}Remediation: axiom auth login${NC}"
                all_ok=false
            fi
        else
            echo -e "  ${YELLOW}⚠️  Axiom CLI - Not installed (will be installed during setup)${NC}"
            ((warnings++))
        fi
    fi
    
    echo ""

    # --- API Key Check ---
    echo -e "${CYAN}3. API Keys Status${NC}"
    echo ""
    
    if $USE_CLERK; then
        if [[ -n "$CLERK_PUBLISHABLE_KEY_DEV" ]] && [[ -n "$CLERK_SECRET_KEY_DEV" ]]; then
            echo -e "  ${GREEN}✓ Clerk Development keys - Collected${NC}"
        else
            echo -e "  ${YELLOW}⚠️  Clerk Development keys - Will be prompted${NC}"
        fi
        
        if [[ -n "$CLERK_PUBLISHABLE_KEY_PROD" ]] && [[ -n "$CLERK_SECRET_KEY_PROD" ]]; then
            echo -e "  ${GREEN}✓ Clerk Production keys - Collected${NC}"
        else
            echo -e "  ${YELLOW}⚠️  Clerk Production keys - Will be prompted${NC}"
        fi
    fi
    
    if $USE_AI; then
        if [ "$AI_PROVIDER" = "openai" ] || [ "$AI_PROVIDER" = "both" ]; then
            if [[ -n "$OPENAI_API_KEY" ]]; then
                echo -e "  ${GREEN}✓ OpenAI API key - Collected${NC}"
            else
                echo -e "  ${YELLOW}⚠️  OpenAI API key - Will be prompted${NC}"
            fi
        fi
        
        if [ "$AI_PROVIDER" = "anthropic" ] || [ "$AI_PROVIDER" = "both" ]; then
            if [[ -n "$ANTHROPIC_API_KEY" ]]; then
                echo -e "  ${GREEN}✓ Anthropic API key - Collected${NC}"
            else
                echo -e "  ${YELLOW}⚠️  Anthropic API key - Will be prompted${NC}"
            fi
        fi
    fi
    
    if $USE_LINEAR; then
        if [[ -n "$LINEAR_API_KEY" ]]; then
            echo -e "  ${GREEN}✓ Linear API key - Collected${NC}"
        else
            echo -e "  ${YELLOW}⚠️  Linear API key - Will be prompted${NC}"
        fi
    fi
    
    echo ""

    # --- Planned Actions ---
    echo -e "${CYAN}4. Planned Actions${NC}"
    echo ""
    
    echo -e "${BLUE}Project Setup:${NC}"
    echo -e "  • Create Next.js project: ${GREEN}$project_name${NC}"
    echo -e "  • Initialize with TypeScript, Tailwind, App Router"
    echo -e "  • Package manager: ${GREEN}$package_manager${NC}"
    echo ""
    
    echo -e "${BLUE}Services to Configure:${NC}"
    $USE_VERCEL && echo -e "  ${GREEN}✓${NC} Vercel - Deployment platform"
    $USE_CONVEX && echo -e "  ${GREEN}✓${NC} Convex - Backend & database"
    $USE_CLERK && echo -e "  ${GREEN}✓${NC} Clerk - Authentication (dev + prod)"
    $USE_AXIOM && echo -e "  ${GREEN}✓${NC} Axiom - Observability"
    $USE_LINEAR && echo -e "  ${GREEN}✓${NC} Linear - Issue tracking"
    echo ""
    
    echo -e "${BLUE}Features to Install:${NC}"
    $USE_SHADCN && echo -e "  ${GREEN}✓${NC} shadcn/ui + Dark Mode"
    $USE_AI && echo -e "  ${GREEN}✓${NC} AI Integration ($AI_PROVIDER)"
    $USE_ADMIN && echo -e "  ${GREEN}✓${NC} Admin Panel"
    $USE_FEATURE_TOGGLES && echo -e "  ${GREEN}✓${NC} Feature Toggle Dashboard"
    $USE_GITHUB && echo -e "  ${GREEN}✓${NC} GitHub Repository + CI/CD"
    echo ""
    
    echo -e "${BLUE}Files to Create:${NC}"
    echo -e "  • .env.local (with collected API keys)"
    echo -e "  • .env.production.template"
    echo -e "  • VERCEL_ENVIRONMENT_SETUP.md"
    $USE_CLERK && echo -e "  • SETUP_GUIDE.md (for Clerk)"
    $USE_CONVEX && echo -e "  • convex/schema.ts"
    $USE_CLERK && echo -e "  • middleware.ts (Clerk)"
    $USE_FEATURE_TOGGLES && echo -e "  • convex/featureFlags.ts"
    echo ""

    # --- Final Summary ---
    echo ""
    echo -e "${PURPLE}DRY RUN SUMMARY${NC}"
    echo ""
    
    if $all_ok; then
        echo -e "${GREEN}✅ Pre-flight check PASSED!${NC}"
        echo -e "${GREEN}All critical requirements are met.${NC}"
        echo ""
        if [ $warnings -gt 0 ]; then
            echo -e "${YELLOW}⚠️  $warnings warning(s) - non-critical${NC}"
            echo ""
        fi
        echo -e "${CYAN}Ready to run:${NC} ${GREEN}./create-project.sh${NC}"
    else
        echo -e "${RED}❌ Pre-flight check FAILED!${NC}"
        echo -e "${YELLOW}Please fix the issues above before running setup.${NC}"
        echo ""
        echo -e "${CYAN}After fixing issues, run:${NC} ${GREEN}./create-project.sh --dry-run${NC}"
    fi
    echo ""
    
    return $([ "$all_ok" = true ] && echo 0 || echo 1)
}
