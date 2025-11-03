#!/bin/bash

# Configuration Preset System for Launchify

PRESET_DIR="$SCRIPT_DIR/templates/configs"

# Show preset selection menu
show_preset_menu() {
    echo -e "${CYAN}Quick Start with Configuration Presets${NC}"
    echo ""
    echo "Choose a preset configuration to get started quickly,"
    echo "or select Custom to choose features individually."
    echo ""
    echo -e "${YELLOW}Available Presets:${NC}"
    echo ""
    echo -e "${GREEN}1. SaaS Starter${NC} - Full-featured SaaS application"
    echo "   ✓ Vercel + Convex + Clerk + Axiom"
    echo "   ✓ shadcn/ui + Admin Panel + Feature Toggles"
    echo "   ✓ GitHub CI/CD"
    echo ""
    echo -e "${GREEN}2. Blog/Content Site${NC} - Lightweight content-focused site"
    echo "   ✓ Vercel + shadcn/ui + GitHub"
    echo "   ✗ No backend/auth (keep it simple)"
    echo ""
    echo -e "${GREEN}3. AI Application${NC} - AI-powered app"
    echo "   ✓ Vercel + Convex + Clerk + Axiom"
    echo "   ✓ OpenAI & Anthropic integration"
    echo "   ✓ shadcn/ui + GitHub"
    echo ""
    echo -e "${GREEN}4. Minimal${NC} - Just the basics"
    echo "   ✓ Next.js + Vercel only"
    echo "   ✗ No additional services"
    echo ""
    echo -e "${BLUE}5. Custom${NC} - Choose features individually"
    echo ""
    
    read -p "Select preset [1-5]: " preset_choice
    
    case $preset_choice in
        1)
            load_preset "saas-starter"
            return 0
            ;;
        2)
            load_preset "blog-content"
            return 0
            ;;
        3)
            load_preset "ai-app"
            return 0
            ;;
        4)
            load_preset "minimal"
            return 0
            ;;
        5|*)
            echo -e "${BLUE}Using custom configuration...${NC}"
            echo ""
            return 1  # Signal to use manual configuration
            ;;
    esac
}

# Load a preset configuration
load_preset() {
    local preset_name=$1
    local preset_file="$PRESET_DIR/${preset_name}.conf"
    
    if [ ! -f "$preset_file" ]; then
        echo -e "${RED}Error: Preset file not found: $preset_file${NC}"
        return 1
    fi
    
    # Source the preset file to load all variables
    source "$preset_file"
    
    echo -e "${GREEN}✓ Loaded preset: ${preset_name}${NC}"
    echo ""
    
    # Show what was configured
    echo -e "${CYAN}Configuration Summary:${NC}"
    echo "  Framework: $FRAMEWORK"
    echo "  Vercel: $([ "$USE_VERCEL" = "true" ] && echo "✓" || echo "✗")"
    echo "  Convex: $([ "$USE_CONVEX" = "true" ] && echo "✓" || echo "✗")"
    echo "  Clerk: $([ "$USE_CLERK" = "true" ] && echo "✓" || echo "✗")"
    echo "  Axiom: $([ "$USE_AXIOM" = "true" ] && echo "✓" || echo "✗")"
    echo "  shadcn/ui: $([ "$USE_SHADCN" = "true" ] && echo "✓" || echo "✗")"
    echo "  AI Integration: $([ "$USE_AI" = "true" ] && echo "✓ ($AI_PROVIDER)" || echo "✗")"
    echo "  Admin Panel: $([ "$USE_ADMIN" = "true" ] && echo "✓" || echo "✗")"
    echo "  Feature Toggles: $([ "$USE_FEATURE_TOGGLES" = "true" ] && echo "✓" || echo "✗")"
    echo "  GitHub CI/CD: $([ "$USE_GITHUB" = "true" ] && echo "✓" || echo "✗")"
    echo ""
    
    read -p "Use this configuration? [Y/n]: " confirm
    confirm=${confirm:-Y}
    
    if [[ $confirm =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}✓ Configuration confirmed${NC}"
        echo ""
        return 0
    else
        echo -e "${YELLOW}Switching to custom configuration...${NC}"
        echo ""
        return 1
    fi
}

# Save current configuration for future use
save_config() {
    local config_name=$1
    local config_dir="$HOME/.launchify/configs"
    
    mkdir -p "$config_dir"
    
    local config_file="$config_dir/${config_name}.conf"
    
    cat > "$config_file" << EOF
# Launchify Configuration: ${config_name}
# Saved: $(date '+%Y-%m-%d %H:%M:%S')

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
EOF
    
    echo -e "${GREEN}✓ Configuration saved to: $config_file${NC}"
}

# Offer to save configuration after successful setup
offer_save_config() {
    echo ""
    echo -e "${CYAN}Save this configuration for future projects?${NC}"
    read -p "Enter a name for this config (or press Enter to skip): " config_name
    
    if [ -n "$config_name" ]; then
        # Clean the name (lowercase, hyphens only)
        config_name=$(echo "$config_name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/[^a-z0-9-]//g')
        save_config "$config_name"
    else
        echo -e "${BLUE}Configuration not saved${NC}"
    fi
    echo ""
}

# List and load saved configurations
load_saved_config() {
    local config_dir="$HOME/.launchify/configs"
    
    if [ ! -d "$config_dir" ] || [ -z "$(ls -A $config_dir 2>/dev/null)" ]; then
        return 1  # No saved configs
    fi
    
    echo -e "${CYAN}Saved Configurations:${NC}"
    echo ""
    
    local configs=()
    local i=1
    
    while IFS= read -r file; do
        local name=$(basename "$file" .conf)
        local date=$(stat -f "%Sm" -t "%Y-%m-%d" "$file" 2>/dev/null || stat -c "%y" "$file" 2>/dev/null | cut -d' ' -f1)
        echo "$i. $name (saved: $date)"
        configs+=("$file")
        ((i++))
    done < <(ls -t "$config_dir"/*.conf 2>/dev/null)
    
    echo "$i. Don't load a saved config"
    echo ""
    
    read -p "Select configuration [1-$i]: " choice
    
    if [ "$choice" -ge 1 ] && [ "$choice" -lt "$i" ]; then
        local selected_file="${configs[$((choice-1))]}"
        source "$selected_file"
        echo -e "${GREEN}✓ Loaded configuration${NC}"
        echo ""
        return 0
    else
        return 1
    fi
}

