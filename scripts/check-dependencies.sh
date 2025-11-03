#!/bin/bash

# Check for required dependencies

check_dependencies() {
    local use_vercel=$1
    local use_convex=$2
    local use_axiom=$3
    local package_manager=$4

    local missing_deps=()

    # Check Node.js
    if ! command -v node &> /dev/null; then
        echo -e "${RED}✗ Node.js not found${NC}"
        missing_deps+=("nodejs")
    else
        local node_version=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
        if [ "$node_version" -lt 18 ]; then
            echo -e "${YELLOW}⚠️  Node.js version is $node_version. Recommended: 18+${NC}"
        else
            echo -e "${GREEN}✓ Node.js $(node -v)${NC}"
        fi
    fi

    # Check package manager
    if [ "$package_manager" = "pnpm" ]; then
        if ! command -v pnpm &> /dev/null; then
            echo -e "${CYAN}pnpm Package Manager${NC}"
            echo ""
            echo "You selected pnpm as your package manager."
            echo "pnpm is a fast, disk-efficient alternative to npm."
            echo ""
            echo -e "${YELLOW}Installation details:${NC}"
            echo "  • Package: pnpm"
            echo "  • Method: npm global install"
            echo "  • Size: ~20MB"
            echo ""
            read -p "Install pnpm now? [y/N]: " install_pnpm
            install_pnpm=${install_pnpm:-N}
            
            if [[ $install_pnpm =~ ^[Yy]$ ]]; then
                npm install -g pnpm
                echo -e "${GREEN}✓ pnpm installed${NC}"
            else
                echo -e "${RED}✗ Cannot proceed without pnpm. Please install manually or choose a different package manager.${NC}"
                exit 1
            fi
        else
            echo -e "${GREEN}✓ pnpm $(pnpm -v)${NC}"
        fi
    elif [ "$package_manager" = "yarn" ]; then
        if ! command -v yarn &> /dev/null; then
            echo -e "${CYAN}Yarn Package Manager${NC}"
            echo ""
            echo "You selected Yarn as your package manager."
            echo "Yarn is a popular, fast alternative to npm."
            echo ""
            echo -e "${YELLOW}Installation details:${NC}"
            echo "  • Package: yarn"
            echo "  • Method: npm global install"
            echo "  • Size: ~5MB"
            echo ""
            read -p "Install Yarn now? [y/N]: " install_yarn
            install_yarn=${install_yarn:-N}
            
            if [[ $install_yarn =~ ^[Yy]$ ]]; then
                npm install -g yarn
                echo -e "${GREEN}✓ yarn installed${NC}"
            else
                echo -e "${RED}✗ Cannot proceed without yarn. Please install manually or choose a different package manager.${NC}"
                exit 1
            fi
        else
            echo -e "${GREEN}✓ yarn $(yarn -v)${NC}"
        fi
    else
        if ! command -v npm &> /dev/null; then
            echo -e "${RED}✗ npm not found${NC}"
            missing_deps+=("npm")
        else
            echo -e "${GREEN}✓ npm $(npm -v)${NC}"
        fi
    fi

    # Check Git
    if ! command -v git &> /dev/null; then
        echo -e "${RED}✗ Git not found${NC}"
        missing_deps+=("git")
    else
        echo -e "${GREEN}✓ Git $(git --version | cut -d' ' -f3)${NC}"
    fi

    # Check Vercel CLI
    if $use_vercel; then
        if ! command -v vercel &> /dev/null; then
            echo -e "${YELLOW}⚠️  Vercel CLI not found (will install)${NC}"
        else
            echo -e "${GREEN}✓ Vercel CLI $(vercel --version)${NC}"
        fi
    fi

    # Check Convex CLI
    if $use_convex; then
        # Convex is typically used via npx, so we don't need global install
        echo -e "${GREEN}✓ Convex CLI (will use via npx)${NC}"
    fi

    # Check Axiom CLI
    if $use_axiom; then
        if ! command -v axiom &> /dev/null; then
            echo -e "${YELLOW}⚠️  Axiom CLI not found (will install)${NC}"
        else
            echo -e "${GREEN}✓ Axiom CLI${NC}"
        fi
    fi

    # If there are missing critical dependencies, abort
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo -e "\n${RED}❌ Missing critical dependencies:${NC}"
        printf '%s\n' "${missing_deps[@]}"
        echo -e "\n${YELLOW}Please install the following:${NC}"

        if [[ " ${missing_deps[@]} " =~ " nodejs " ]]; then
            echo -e "  ${CYAN}Node.js:${NC} https://nodejs.org/ or use nvm: curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash"
        fi

        if [[ " ${missing_deps[@]} " =~ " git " ]]; then
            echo -e "  ${CYAN}Git:${NC} sudo apt install git (Ubuntu/Debian) or https://git-scm.com/"
        fi

        exit 1
    fi

    echo -e "${GREEN}✓ All critical dependencies satisfied${NC}"
}
