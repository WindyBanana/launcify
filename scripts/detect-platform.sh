#!/bin/bash

# Platform detection and tool installation

detect_platform() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        PLATFORM="linux"
        PLATFORM_NAME="Linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        PLATFORM="macos"
        PLATFORM_NAME="macOS"
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        PLATFORM="windows"
        PLATFORM_NAME="Windows (WSL/Cygwin)"
    else
        PLATFORM="unknown"
        PLATFORM_NAME="Unknown"
    fi

    export PLATFORM
    export PLATFORM_NAME
}

check_homebrew() {
    if [[ "$PLATFORM" == "macos" ]]; then
        if ! command -v brew &> /dev/null; then
            echo -e "${CYAN}Homebrew Package Manager${NC}"
            echo ""
            echo "Homebrew is the standard package manager for macOS development."
            echo "Many developer tools (including some Launchify features) rely on it."
            echo ""
            echo -e "${YELLOW}Installation details:${NC}"
            echo "  • Package: Homebrew"
            echo "  • Size: ~400MB"
            echo "  • Location: /opt/homebrew (Apple Silicon) or /usr/local (Intel)"
            echo "  • Purpose: Manages installation of developer tools and CLIs"
            echo ""
            echo "If you prefer, you can install manually later from https://brew.sh"
            echo ""
            read -p "Install Homebrew now? [y/N]: " install_brew
            install_brew=${install_brew:-N}

            if [[ $install_brew =~ ^[Yy]$ ]]; then
                echo ""
                echo "Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

                if [[ $? -eq 0 ]]; then
                    echo -e "${GREEN}✓ Homebrew installed successfully${NC}"

                    # Add to PATH for current session
                    if [[ -f "/opt/homebrew/bin/brew" ]]; then
                        eval "$(/opt/homebrew/bin/brew shellenv)"
                    fi
                else
                    echo -e "${YELLOW}Installation encountered an issue. You can install manually from brew.sh${NC}"
                    return 1
                fi
            else
                echo -e "${BLUE}Skipping Homebrew. You can install tools manually as needed.${NC}"
                return 1
            fi
        fi
    fi
    return 0
}

install_tool_cross_platform() {
    local tool_name=$1
    local brew_package=$2
    local apt_package=${3:-$2}
    local description=$4

    if command -v "$tool_name" &> /dev/null; then
        return 0
    fi

    echo -e "${YELLOW}⚠️  ${tool_name} not found${NC}"

    if [[ -n "$description" ]]; then
        echo "$description"
        echo ""
    fi

    read -p "Install ${tool_name}? [Y/n]: " install_it
    install_it=${install_it:-Y}

    if [[ ! $install_it =~ ^[Yy]$ ]]; then
        echo "Skipping ${tool_name}"
        return 1
    fi

    if [[ "$PLATFORM" == "macos" ]]; then
        if command -v brew &> /dev/null; then
            echo "Installing via Homebrew..."
            brew install "$brew_package"
        else
            echo -e "${RED}✗ Homebrew required for installation${NC}"
            return 1
        fi
    elif [[ "$PLATFORM" == "linux" ]]; then
        if command -v apt-get &> /dev/null; then
            echo "Installing via apt..."
            sudo apt-get update && sudo apt-get install -y "$apt_package"
        elif command -v yum &> /dev/null; then
            echo "Installing via yum..."
            sudo yum install -y "$apt_package"
        elif command -v pacman &> /dev/null; then
            echo "Installing via pacman..."
            sudo pacman -S --noconfirm "$apt_package"
        else
            echo -e "${RED}✗ No supported package manager found${NC}"
            return 1
        fi
    else
        echo -e "${RED}✗ Unsupported platform for automatic installation${NC}"
        return 1
    fi

    if command -v "$tool_name" &> /dev/null; then
        echo -e "${GREEN}✓ ${tool_name} installed${NC}"
        return 0
    else
        echo -e "${RED}✗ Installation may have failed${NC}"
        return 1
    fi
}

# Smart TUI Installation - offers to install whiptail/dialog if missing
install_tui_tools() {
    # Check if either whiptail or dialog is already available
    if command -v whiptail &> /dev/null || command -v dialog &> /dev/null; then
        return 0
    fi
    
    echo -e "${CYAN}Enhanced Interactive UI Available${NC}"
    echo ""
    echo "Launchify offers two interface modes:"
    echo ""
    echo -e "${GREEN}1. CLI Mode${NC} - Traditional text prompts (works everywhere)"
    echo -e "${BLUE}2. TUI Mode${NC} - Visual menus with checkboxes (enhanced experience)"
    echo ""
    echo "TUI mode provides a more intuitive experience with visual selection,"
    echo "but requires a small utility (dialog or whiptail) to be installed."
    echo ""
    echo -e "${YELLOW}Installation details:${NC}"
    echo "  • Package: 'dialog' (macOS) or 'whiptail' (Linux)"
    echo "  • Size: ~500KB"
    echo "  • Method: System package manager (brew/apt/yum/dnf)"
    echo ""
    echo "CLI mode is fully functional if you prefer not to install anything."
    echo ""
    
    read -p "Install TUI tools for enhanced experience? [y/N]: " install_tui
    install_tui=${install_tui:-N}
    
    if [[ ! $install_tui =~ ^[Yy]$ ]]; then
        echo ""
        echo -e "${GREEN}✓ No problem! Using CLI mode.${NC}"
        echo ""
        return 1
    fi
    
    echo ""
    echo "Installing TUI tools..."
    
    # Install based on platform
    if [[ "$PLATFORM" == "macos" ]]; then
        if command -v brew &> /dev/null; then
            echo "Installing dialog via Homebrew..."
            if brew install dialog; then
                echo -e "${GREEN}✓ dialog installed successfully${NC}"
                return 0
            else
                echo -e "${RED}✗ Installation failed${NC}"
                return 1
            fi
        else
            echo -e "${RED}✗ Homebrew required for installation on macOS${NC}"
            echo "Please install Homebrew first: https://brew.sh"
            return 1
        fi
    elif [[ "$PLATFORM" == "linux" ]]; then
        # Try different package managers
        if command -v apt-get &> /dev/null; then
            echo "Installing whiptail via apt..."
            if sudo apt-get update && sudo apt-get install -y whiptail; then
                echo -e "${GREEN}✓ whiptail installed successfully${NC}"
                return 0
            else
                echo -e "${RED}✗ Installation failed${NC}"
                return 1
            fi
        elif command -v yum &> /dev/null; then
            echo "Installing dialog via yum..."
            if sudo yum install -y dialog; then
                echo -e "${GREEN}✓ dialog installed successfully${NC}"
                return 0
            else
                echo -e "${RED}✗ Installation failed${NC}"
                return 1
            fi
        elif command -v pacman &> /dev/null; then
            echo "Installing dialog via pacman..."
            if sudo pacman -S --noconfirm dialog; then
                echo -e "${GREEN}✓ dialog installed successfully${NC}"
                return 0
            else
                echo -e "${RED}✗ Installation failed${NC}"
                return 1
            fi
        elif command -v dnf &> /dev/null; then
            echo "Installing dialog via dnf..."
            if sudo dnf install -y dialog; then
                echo -e "${GREEN}✓ dialog installed successfully${NC}"
                return 0
            else
                echo -e "${RED}✗ Installation failed${NC}"
                return 1
            fi
        else
            echo -e "${RED}✗ No supported package manager found${NC}"
            echo "Please install 'whiptail' or 'dialog' manually."
            return 1
        fi
    else
        echo -e "${RED}✗ Unsupported platform for automatic installation${NC}"
        return 1
    fi
}

setup_platform_tools() {
    detect_platform

    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Platform: ${PLATFORM_NAME}${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if [[ "$PLATFORM" == "macos" ]]; then
        check_homebrew
    fi
    
    # Offer to install TUI tools if missing
    install_tui_tools

    if [[ "$PLATFORM" == "windows" ]]; then
        echo -e "${YELLOW}⚠️  Windows detected (WSL/Cygwin)${NC}"
        echo "Some features may require manual configuration."
        echo "For best experience, use WSL 2."
        echo ""
    fi

    if [[ "$PLATFORM" == "unknown" ]]; then
        echo -e "${RED}✗ Unsupported platform${NC}"
        echo "Launchify is designed for Linux and macOS."
        echo ""
        return 1
    fi

    return 0
}
