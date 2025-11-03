#!/bin/bash

# Install missing CLI tools

install_missing_clis() {
    local use_vercel=$1
    local use_convex=$2
    local use_axiom=$3

    local installed_any=false

    # Install Vercel CLI
    if $use_vercel; then
        if ! command -v vercel &> /dev/null; then
            echo ""
            echo -e "${CYAN}Vercel CLI Required${NC}"
            echo ""
            echo "You selected Vercel for deployment. The Vercel CLI will help you:"
            echo "  • Link your project to Vercel"
            echo "  • Deploy from your local machine"
            echo "  • Manage environment variables"
            echo "  • View deployment logs and status"
            echo ""
            echo -e "${YELLOW}Installation details:${NC}"
            echo "  • Package: vercel (Vercel CLI)"
            echo "  • Method: npm global install"
            echo "  • Size: ~50MB"
            echo ""
            echo "If you prefer, you can install manually later: npm install -g vercel"
            echo ""
            read -p "Install Vercel CLI now? [y/N]: " install_vercel_cli
            install_vercel_cli=${install_vercel_cli:-N}
            
            if [[ $install_vercel_cli =~ ^[Yy]$ ]]; then
                echo -e "${BLUE}Installing Vercel CLI...${NC}"
                npm install -g vercel
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✓ Vercel CLI installed${NC}"
                    installed_any=true
                else
                    echo -e "${RED}✗ Failed to install Vercel CLI${NC}"
                    echo -e "${YELLOW}You can install manually later and run setup again${NC}"
                fi
            else
                echo -e "${BLUE}No problem. Install manually when ready: npm install -g vercel${NC}"
            fi
            echo ""
        fi
    fi

    # Convex is used via npx, no global install needed

    # Install Axiom CLI
    if $use_axiom; then
        if ! command -v axiom &> /dev/null; then
            echo ""
            echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${CYAN}Axiom CLI Required${NC}"
            echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo ""
            echo "You selected Axiom for observability. The Axiom CLI will help you:"
            echo "  • Authenticate with your Axiom account"
            echo "  • Create and manage datasets"
            echo "  • Query logs from the command line"
            echo "  • Configure project settings"
            echo ""
            echo -e "${YELLOW}Installation details:${NC}"
            echo "  • Package: axiom (Axiom CLI)"
            if [[ "$OSTYPE" == "darwin"* ]]; then
                echo "  • Method: Homebrew"
            else
                echo "  • Method: Direct binary to /usr/local/bin"
                echo "  • Note: Requires sudo access for installation"
            fi
            echo "  • Size: ~15MB"
            echo ""
            echo "If you prefer, install manually: https://axiom.co/docs/reference/cli"
            echo ""
            read -p "Install Axiom CLI now? [y/N]: " install_axiom_cli
            install_axiom_cli=${install_axiom_cli:-N}
            
            if [[ $install_axiom_cli =~ ^[Yy]$ ]]; then
                echo -e "${BLUE}Installing Axiom CLI...${NC}"

                # Detect OS and install accordingly
                if [[ "$OSTYPE" == "linux-gnu"* ]]; then
                    # Linux installation with proper error checking
                    if curl -fsSL https://github.com/axiomhq/cli/releases/latest/download/axiom_linux_amd64 -o /tmp/axiom; then
                        chmod +x /tmp/axiom
                        # Verify it's a valid binary
                        if file /tmp/axiom | grep -q "executable"; then
                            sudo mv /tmp/axiom /usr/local/bin/axiom
                            echo -e "${GREEN}✓ Axiom CLI installed${NC}"
                            installed_any=true
                        else
                            echo -e "${YELLOW}⚠️  Downloaded file is not a valid binary${NC}"
                            echo -e "${CYAN}Please install manually: https://axiom.co/docs/reference/cli#installation${NC}"
                            rm -f /tmp/axiom
                        fi
                    else
                        echo -e "${YELLOW}⚠️  Failed to download Axiom CLI${NC}"
                        echo -e "${CYAN}Please install manually: https://axiom.co/docs/reference/cli#installation${NC}"
                    fi
                elif [[ "$OSTYPE" == "darwin"* ]]; then
                    # macOS installation
                    if brew install axiomhq/tap/axiom; then
                        echo -e "${GREEN}✓ Axiom CLI installed${NC}"
                        installed_any=true
                    else
                        echo -e "${YELLOW}⚠️  Failed to install Axiom CLI via Homebrew${NC}"
                        echo -e "${CYAN}Please install manually: https://axiom.co/docs/reference/cli#installation${NC}"
                    fi
                else
                    echo -e "${YELLOW}⚠️  Unsupported OS for Axiom CLI auto-install${NC}"
                    echo -e "${CYAN}Please install manually: https://axiom.co/docs/reference/cli#installation${NC}"
                fi
            else
                echo -e "${BLUE}No problem. Install manually when ready: https://axiom.co/docs/reference/cli${NC}"
            fi
            echo ""
        fi
    fi

    if ! $installed_any; then
        echo -e "${GREEN}✓ All required CLIs already installed${NC}"
    fi
}
