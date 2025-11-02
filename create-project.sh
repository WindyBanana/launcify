#!/bin/bash

# Fullstack Project Template Generator
# Creates a production-ready project with automated service setup

set -e  # Exit on error

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

# Source helper scripts
source "$SCRIPT_DIR/scripts/check-dependencies.sh"
source "$SCRIPT_DIR/scripts/install-clis.sh"
source "$SCRIPT_DIR/scripts/setup-vercel.sh"
source "$SCRIPT_DIR/scripts/setup-convex.sh"
source "$SCRIPT_DIR/scripts/setup-axiom.sh"
source "$SCRIPT_DIR/scripts/setup-shadcn.sh"
source "$SCRIPT_DIR/scripts/setup-ai.sh"
source "$SCRIPT_DIR/scripts/setup-admin.sh"
source "$SCRIPT_DIR/scripts/utils.sh"

# Banner
echo -e "${PURPLE}"
echo "╔═══════════════════════════════════════════════════════╗"
echo "║                                                       ║"
echo "║     FULLSTACK PROJECT TEMPLATE GENERATOR             ║"
echo "║     Zero-config setup for production-ready apps      ║"
echo "║                                                       ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo -e "${NC}\n"

# Step 1: Project Name
echo -e "${CYAN}📝 Step 1: Project Configuration${NC}"
read -p "Enter project name (lowercase, hyphens only): " PROJECT_NAME

# Validate project name
if [[ ! $PROJECT_NAME =~ ^[a-z0-9-]+$ ]]; then
    echo -e "${RED}❌ Invalid project name. Use lowercase letters, numbers, and hyphens only.${NC}"
    exit 1
fi

# Check if directory already exists
if [ -d "$PROJECT_NAME" ]; then
    echo -e "${RED}❌ Directory '$PROJECT_NAME' already exists!${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Project name: $PROJECT_NAME${NC}\n"

# Step 2: Package Manager Selection
echo -e "${CYAN}📦 Step 2: Package Manager${NC}"
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

echo -e "${GREEN}✓ Package manager: $PACKAGE_MANAGER${NC}\n"

# Step 3: Framework Selection
echo -e "${CYAN}🎨 Step 3: Framework${NC}"
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

echo -e "${GREEN}✓ Framework: $FRAMEWORK${NC}\n"

# Step 4: Service Selection
echo -e "${CYAN}🔧 Step 4: Service Selection${NC}"
echo "Select services to integrate (y/n):"

read -p "  Vercel (Deployment) [Y/n]: " USE_VERCEL
USE_VERCEL=${USE_VERCEL:-Y}

read -p "  Convex (Backend/Database) [Y/n]: " USE_CONVEX
USE_CONVEX=${USE_CONVEX:-Y}

read -p "  Clerk (Authentication) [Y/n]: " USE_CLERK
USE_CLERK=${USE_CLERK:-Y}

read -p "  Axiom (Observability) [y/N]: " USE_AXIOM
USE_AXIOM=${USE_AXIOM:-N}

read -p "  Linear (Project Management) [y/N]: " USE_LINEAR
USE_LINEAR=${USE_LINEAR:-N}

echo ""

# Convert to boolean flags
[[ $USE_VERCEL =~ ^[Yy]$ ]] && USE_VERCEL=true || USE_VERCEL=false
[[ $USE_CONVEX =~ ^[Yy]$ ]] && USE_CONVEX=true || USE_CONVEX=false
[[ $USE_CLERK =~ ^[Yy]$ ]] && USE_CLERK=true || USE_CLERK=false
[[ $USE_AXIOM =~ ^[Yy]$ ]] && USE_AXIOM=true || USE_AXIOM=false
[[ $USE_LINEAR =~ ^[Yy]$ ]] && USE_LINEAR=true || USE_LINEAR=false

# Step 5: UI & Features
echo -e "${CYAN}🎨 Step 5: UI & Features${NC}"
echo "Select additional features (y/n):"

read -p "  shadcn/ui + Dark Mode [Y/n]: " USE_SHADCN
USE_SHADCN=${USE_SHADCN:-Y}
[[ $USE_SHADCN =~ ^[Yy]$ ]] && USE_SHADCN=true || USE_SHADCN=false

read -p "  AI Integration [y/N]: " USE_AI
USE_AI=${USE_AI:-N}
[[ $USE_AI =~ ^[Yy]$ ]] && USE_AI=true || USE_AI=false

# AI Provider selection
AI_PROVIDER="none"
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

read -p "  Admin Panel (requires Convex) [y/N]: " USE_ADMIN
USE_ADMIN=${USE_ADMIN:-N}
[[ $USE_ADMIN =~ ^[Yy]$ ]] && USE_ADMIN=true || USE_ADMIN=false

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
ADMIN_PROD_ENABLED=false
if $USE_ADMIN; then
    read -p "  Enable admin panel in production? [y/N]: " ADMIN_PROD
    ADMIN_PROD=${ADMIN_PROD:-N}
    [[ $ADMIN_PROD =~ ^[Yy]$ ]] && ADMIN_PROD_ENABLED=true || ADMIN_PROD_ENABLED=false
fi

echo ""

# Summary
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📋 Configuration Summary:${NC}"
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
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

read -p "Proceed with setup? [Y/n]: " CONFIRM
CONFIRM=${CONFIRM:-Y}

if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Setup cancelled.${NC}"
    exit 0
fi

echo ""

# Step 6: Check Dependencies
echo -e "${CYAN}🔍 Step 6: Checking Dependencies${NC}"
check_dependencies "$USE_VERCEL" "$USE_CONVEX" "$USE_AXIOM" "$PACKAGE_MANAGER"
echo ""

# Step 7: Install Missing CLIs
echo -e "${CYAN}📥 Step 7: Installing Missing CLIs${NC}"
install_missing_clis "$USE_VERCEL" "$USE_CONVEX" "$USE_AXIOM"
echo ""

# Step 8: Create Project
echo -e "${CYAN}🚀 Step 8: Creating Project${NC}"
create_project "$PROJECT_NAME" "$FRAMEWORK" "$PACKAGE_MANAGER"
echo ""

# Step 9: Setup Services
cd "$PROJECT_NAME"

if $USE_VERCEL; then
    echo -e "${CYAN}🔷 Setting up Vercel...${NC}"
    setup_vercel "$PROJECT_NAME"
    echo ""
fi

if $USE_CONVEX; then
    echo -e "${CYAN}🔶 Setting up Convex...${NC}"
    setup_convex "$PROJECT_NAME" "$PACKAGE_MANAGER"
    echo ""
fi

if $USE_AXIOM; then
    echo -e "${CYAN}🔸 Setting up Axiom...${NC}"
    setup_axiom "$PROJECT_NAME"
    echo ""
fi

# Step 10: Setup UI & Features
if $USE_SHADCN; then
    echo -e "${CYAN}🎨 Setting up shadcn/ui...${NC}"
    setup_shadcn "$PACKAGE_MANAGER"
    echo ""
fi

if $USE_AI; then
    echo -e "${CYAN}🤖 Setting up AI Integration...${NC}"
    setup_ai "$PACKAGE_MANAGER" "$AI_PROVIDER"
    echo ""
fi

if $USE_ADMIN; then
    echo -e "${CYAN}👨‍💼 Setting up Admin Panel...${NC}"
    setup_admin_panel "$USE_CLERK" "$USE_AXIOM" "$USE_LINEAR" "$ADMIN_PROD_ENABLED"
    echo ""
fi

# Step 11: Generate Environment Files
echo -e "${CYAN}📝 Step 11: Generating Environment Files${NC}"
generate_env_files "$USE_VERCEL" "$USE_CONVEX" "$USE_CLERK" "$USE_AXIOM" "$USE_LINEAR" "$USE_AI" "$AI_PROVIDER"
echo ""

# Step 12: Create Setup Guides for Manual Services
if $USE_CLERK || $USE_LINEAR; then
    echo -e "${CYAN}📚 Step 12: Creating Setup Guides${NC}"
    create_setup_guides "$USE_CLERK" "$USE_LINEAR"
    echo ""
fi

# Step 13: Initialize Git
echo -e "${CYAN}🔧 Step 13: Initializing Git Repository${NC}"
git init
git add .
git commit -m "Initial commit: $PROJECT_NAME - Fullstack template with automated setup"
echo -e "${GREEN}✓ Git repository initialized${NC}\n"

# Final Summary
echo -e "${GREEN}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                       ║${NC}"
echo -e "${GREEN}║          🎉 PROJECT SETUP COMPLETE! 🎉               ║${NC}"
echo -e "${GREEN}║                                                       ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════╝${NC}\n"

echo -e "${CYAN}📂 Project created at: ${GREEN}./$PROJECT_NAME${NC}\n"

echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. ${CYAN}cd $PROJECT_NAME${NC}"

if $USE_CLERK; then
    echo -e "  2. ${CYAN}Read SETUP_GUIDE.md and configure Clerk${NC}"
fi

if $USE_LINEAR; then
    echo -e "  3. ${CYAN}Read SETUP_GUIDE.md and configure Linear${NC}"
fi

echo -e "  4. ${CYAN}Review .env.local and add any missing API keys${NC}"
echo -e "  5. ${CYAN}$PACKAGE_MANAGER run dev${NC} - Start development server"
echo -e "  6. ${CYAN}git remote add origin <your-repo-url>${NC}"
echo -e "  7. ${CYAN}git push -u origin main${NC}\n"

echo -e "${GREEN}✨ Happy coding!${NC}\n"
