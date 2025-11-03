#!/bin/bash

# Post-Setup Health Check for Launchify
# Verifies that everything is working correctly after setup

# Run comprehensive health check
run_health_check() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}Running Post-Setup Health Check${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    
    local all_passed=true
    
    # Check 1: TypeScript compilation
    echo -e "${BLUE}Checking TypeScript...${NC}"
    if npx tsc --noEmit 2>&1 | grep -q "error TS"; then
        echo -e "${RED}✗ TypeScript has errors${NC}"
        all_passed=false
    else
        echo -e "${GREEN}✓ TypeScript compiles successfully${NC}"
    fi
    echo ""
    
    # Check 2: Lint
    echo -e "${BLUE}Checking ESLint...${NC}"
    if npm run lint 2>&1 | grep -q "error"; then
        echo -e "${YELLOW}⚠  ESLint has warnings${NC}"
    else
        echo -e "${GREEN}✓ ESLint passed${NC}"
    fi
    echo ""
    
    # Check 3: Dependencies installed
    echo -e "${BLUE}Checking dependencies...${NC}"
    if [ -d "node_modules" ] && [ -f "package-lock.json" -o -f "pnpm-lock.yaml" -o -f "yarn.lock" ]; then
        echo -e "${GREEN}✓ Dependencies installed${NC}"
    else
        echo -e "${RED}✗ Dependencies not properly installed${NC}"
        all_passed=false
    fi
    echo ""
    
    # Check 4: Environment file exists
    echo -e "${BLUE}Checking environment configuration...${NC}"
    if [ -f ".env.local" ]; then
        echo -e "${GREEN}✓ .env.local exists${NC}"
        
        # Check for TODO placeholders
        if grep -q "TODO" ".env.local"; then
            echo -e "${YELLOW}⚠  Some environment variables still need configuration (marked with TODO)${NC}"
        else
            echo -e "${GREEN}✓ All environment variables configured${NC}"
        fi
    else
        echo -e "${RED}✗ .env.local missing${NC}"
        all_passed=false
    fi
    echo ""
    
    # Check 5: Convex connection (if using Convex)
    if $USE_CONVEX; then
        echo -e "${BLUE}Checking Convex connection...${NC}"
        if [ -d "convex" ] && [ -f "convex.json" ]; then
            echo -e "${GREEN}✓ Convex configured${NC}"
        else
            echo -e "${YELLOW}⚠  Convex configuration incomplete${NC}"
        fi
        echo ""
    fi
    
    # Check 6: Git repository
    echo -e "${BLUE}Checking Git repository...${NC}"
    if [ -d ".git" ]; then
        echo -e "${GREEN}✓ Git repository initialized${NC}"
        
        # Check if there's a remote
        if git remote -v | grep -q "origin"; then
            echo -e "${GREEN}✓ Git remote configured${NC}"
        else
            echo -e "${BLUE}ℹ  No Git remote configured yet${NC}"
        fi
    else
        echo -e "${YELLOW}⚠  Git repository not initialized${NC}"
    fi
    echo ""
    
    # Summary
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    if $all_passed; then
        echo -e "${GREEN}✅ Health check PASSED - Your project is ready!${NC}"
        echo ""
        echo -e "${BLUE}Next steps:${NC}"
        echo "  1. Review TODO items in .env.local (if any)"
        echo "  2. Run: npm run dev"
        if $USE_CONVEX; then
            echo "  3. In another terminal: npx convex dev"
        fi
    else
        echo -e "${YELLOW}⚠  Health check completed with warnings${NC}"
        echo ""
        echo -e "${BLUE}Please address the issues above before running your app.${NC}"
    fi
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

