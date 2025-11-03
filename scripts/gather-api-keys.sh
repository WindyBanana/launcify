#!/bin/bash

# Gather and validate API keys for all selected services

# API key validation patterns
CLERK_TEST_KEY_PATTERN="^sk_test_[A-Za-z0-9_-]+$"
CLERK_LIVE_KEY_PATTERN="^sk_live_[A-Za-z0-9_-]+$"
CLERK_PK_TEST_PATTERN="^pk_test_[A-Za-z0-9_-]+$"
CLERK_PK_LIVE_PATTERN="^pk_live_[A-Za-z0-9_-]+$"
OPENAI_KEY_PATTERN="^sk-proj-[A-Za-z0-9_-]+$"
ANTHROPIC_KEY_PATTERN="^sk-ant-[A-Za-z0-9_-]+$"
LINEAR_KEY_PATTERN="^lin_api_[A-Za-z0-9_-]+$"

# Validate API key format
validate_key_format() {
    local key=$1
    local pattern=$2
    local key_name=$3
    
    if [[ -z "$key" ]]; then
        echo -e "${RED}✗ $key_name cannot be empty${NC}"
        return 1
    fi
    
    if [[ ! "$key" =~ $pattern ]]; then
        echo -e "${YELLOW}⚠️  Warning: $key_name format looks unusual${NC}"
        echo -e "${YELLOW}   Expected pattern: ${pattern}${NC}"
        return 2  # Warning but not fatal
    fi
    
    return 0
}

# Gather Clerk API keys (both dev and prod)
gather_clerk_keys() {
    local use_tui=$1
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Clerk Authentication - API Keys${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${BLUE}You'll need to create Clerk applications first:${NC}"
    echo -e "  1. Go to: ${CYAN}https://dashboard.clerk.com${NC}"
    echo -e "  2. Create TWO applications:"
    echo -e "     - One for Development (test keys: pk_test_*, sk_test_*)"
    echo -e "     - One for Production (live keys: pk_live_*, sk_live_*)"
    echo ""
    
    # Development keys
    echo -e "${GREEN}Development Environment Keys:${NC}"
    echo ""
    
    local clerk_dev_pk=""
    local clerk_dev_sk=""
    local clerk_prod_pk=""
    local clerk_prod_sk=""
    
    while true; do
        if $use_tui && command -v whiptail &> /dev/null; then
            clerk_dev_pk=$(whiptail --title "Clerk Development - Publishable Key" \
                --inputbox "Enter DEVELOPMENT publishable key (pk_test_...):\n\nFrom: https://dashboard.clerk.com" \
                12 70 3>&1 1>&2 2>&3)
        else
            read -p "Enter DEVELOPMENT publishable key (pk_test_...): " clerk_dev_pk
        fi
        
        validate_key_format "$clerk_dev_pk" "$CLERK_PK_TEST_PATTERN" "Development publishable key"
        local result=$?
        
        if [ $result -eq 0 ]; then
            break
        elif [ $result -eq 2 ]; then
            read -p "Continue anyway? [y/N]: " continue_anyway
            if [[ $continue_anyway =~ ^[Yy]$ ]]; then
                break
            fi
        fi
        
        echo -e "${YELLOW}Please try again...${NC}"
    done
    
    echo ""
    
    while true; do
        if $use_tui && command -v whiptail &> /dev/null; then
            clerk_dev_sk=$(whiptail --title "Clerk Development - Secret Key" \
                --passwordbox "Enter DEVELOPMENT secret key (sk_test_...):\n\nFrom: https://dashboard.clerk.com" \
                12 70 3>&1 1>&2 2>&3)
        else
            read -sp "Enter DEVELOPMENT secret key (sk_test_...): " clerk_dev_sk
            echo ""
        fi
        
        validate_key_format "$clerk_dev_sk" "$CLERK_TEST_KEY_PATTERN" "Development secret key"
        local result=$?
        
        if [ $result -eq 0 ]; then
            break
        elif [ $result -eq 2 ]; then
            read -p "Continue anyway? [y/N]: " continue_anyway
            if [[ $continue_anyway =~ ^[Yy]$ ]]; then
                break
            fi
        fi
        
        echo -e "${YELLOW}Please try again...${NC}"
    done
    
    echo -e "${GREEN}✓ Development keys collected${NC}"
    echo ""
    
    # Production keys
    echo -e "${GREEN}Production Environment Keys:${NC}"
    echo ""
    
    while true; do
        if $use_tui && command -v whiptail &> /dev/null; then
            clerk_prod_pk=$(whiptail --title "Clerk Production - Publishable Key" \
                --inputbox "Enter PRODUCTION publishable key (pk_live_...):\n\nFrom: https://dashboard.clerk.com" \
                12 70 3>&1 1>&2 2>&3)
        else
            read -p "Enter PRODUCTION publishable key (pk_live_...): " clerk_prod_pk
        fi
        
        validate_key_format "$clerk_prod_pk" "$CLERK_PK_LIVE_PATTERN" "Production publishable key"
        local result=$?
        
        if [ $result -eq 0 ]; then
            break
        elif [ $result -eq 2 ]; then
            read -p "Continue anyway? [y/N]: " continue_anyway
            if [[ $continue_anyway =~ ^[Yy]$ ]]; then
                break
            fi
        fi
        
        echo -e "${YELLOW}Please try again...${NC}"
    done
    
    echo ""
    
    while true; do
        if $use_tui && command -v whiptail &> /dev/null; then
            clerk_prod_sk=$(whiptail --title "Clerk Production - Secret Key" \
                --passwordbox "Enter PRODUCTION secret key (sk_live_...):\n\nFrom: https://dashboard.clerk.com" \
                12 70 3>&1 1>&2 2>&3)
        else
            read -sp "Enter PRODUCTION secret key (sk_live_...): " clerk_prod_sk
            echo ""
        fi
        
        validate_key_format "$clerk_prod_sk" "$CLERK_LIVE_KEY_PATTERN" "Production secret key"
        local result=$?
        
        if [ $result -eq 0 ]; then
            break
        elif [ $result -eq 2 ]; then
            read -p "Continue anyway? [y/N]: " continue_anyway
            if [[ $continue_anyway =~ ^[Yy]$ ]]; then
                break
            fi
        fi
        
        echo -e "${YELLOW}Please try again...${NC}"
    done
    
    echo -e "${GREEN}✓ Production keys collected${NC}"
    echo ""
    
    # Export as global variables
    export CLERK_PUBLISHABLE_KEY_DEV="$clerk_dev_pk"
    export CLERK_SECRET_KEY_DEV="$clerk_dev_sk"
    export CLERK_PUBLISHABLE_KEY_PROD="$clerk_prod_pk"
    export CLERK_SECRET_KEY_PROD="$clerk_prod_sk"
    
    return 0
}

# Gather OpenAI API key
gather_openai_key() {
    local use_tui=$1
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}OpenAI API Key${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${BLUE}Get your API key from: ${CYAN}https://platform.openai.com/api-keys${NC}"
    echo ""
    
    local openai_key=""
    
    while true; do
        if $use_tui && command -v whiptail &> /dev/null; then
            openai_key=$(whiptail --title "OpenAI API Key" \
                --passwordbox "Enter your OpenAI API key (sk-proj-...):\n\nFrom: https://platform.openai.com/api-keys" \
                12 70 3>&1 1>&2 2>&3)
        else
            read -sp "Enter your OpenAI API key (sk-proj-...): " openai_key
            echo ""
        fi
        
        validate_key_format "$openai_key" "$OPENAI_KEY_PATTERN" "OpenAI API key"
        local result=$?
        
        if [ $result -eq 0 ]; then
            break
        elif [ $result -eq 2 ]; then
            read -p "Continue anyway? [y/N]: " continue_anyway
            if [[ $continue_anyway =~ ^[Yy]$ ]]; then
                break
            fi
        fi
        
        echo -e "${YELLOW}Please try again...${NC}"
    done
    
    echo -e "${GREEN}✓ OpenAI key collected${NC}"
    echo ""
    
    export OPENAI_API_KEY="$openai_key"
    return 0
}

# Gather Anthropic API key
gather_anthropic_key() {
    local use_tui=$1
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Anthropic API Key (Claude)${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${BLUE}Get your API key from: ${CYAN}https://console.anthropic.com/settings/keys${NC}"
    echo ""
    
    local anthropic_key=""
    
    while true; do
        if $use_tui && command -v whiptail &> /dev/null; then
            anthropic_key=$(whiptail --title "Anthropic API Key" \
                --passwordbox "Enter your Anthropic API key (sk-ant-...):\n\nFrom: https://console.anthropic.com/settings/keys" \
                12 70 3>&1 1>&2 2>&3)
        else
            read -sp "Enter your Anthropic API key (sk-ant-...): " anthropic_key
            echo ""
        fi
        
        validate_key_format "$anthropic_key" "$ANTHROPIC_KEY_PATTERN" "Anthropic API key"
        local result=$?
        
        if [ $result -eq 0 ]; then
            break
        elif [ $result -eq 2 ]; then
            read -p "Continue anyway? [y/N]: " continue_anyway
            if [[ $continue_anyway =~ ^[Yy]$ ]]; then
                break
            fi
        fi
        
        echo -e "${YELLOW}Please try again...${NC}"
    done
    
    echo -e "${GREEN}✓ Anthropic key collected${NC}"
    echo ""
    
    export ANTHROPIC_API_KEY="$anthropic_key"
    return 0
}

# Gather Linear API key
gather_linear_key() {
    local use_tui=$1
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Linear API Key${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${BLUE}Get your API key from: ${CYAN}https://linear.app/settings/api${NC}"
    echo ""
    
    local linear_key=""
    
    while true; do
        if $use_tui && command -v whiptail &> /dev/null; then
            linear_key=$(whiptail --title "Linear API Key" \
                --passwordbox "Enter your Linear API key (lin_api_...):\n\nFrom: https://linear.app/settings/api" \
                12 70 3>&1 1>&2 2>&3)
        else
            read -sp "Enter your Linear API key (lin_api_...): " linear_key
            echo ""
        fi
        
        validate_key_format "$linear_key" "$LINEAR_KEY_PATTERN" "Linear API key"
        local result=$?
        
        if [ $result -eq 0 ]; then
            break
        elif [ $result -eq 2 ]; then
            read -p "Continue anyway? [y/N]: " continue_anyway
            if [[ $continue_anyway =~ ^[Yy]$ ]]; then
                break
            fi
        fi
        
        echo -e "${YELLOW}Please try again...${NC}"
    done
    
    echo -e "${GREEN}✓ Linear key collected${NC}"
    echo ""
    
    export LINEAR_API_KEY="$linear_key"
    return 0
}

# Main function to gather all required API keys
gather_all_api_keys() {
    local use_clerk=$1
    local use_ai=$2
    local ai_provider=$3
    local use_linear=$4
    local use_tui=${5:-true}
    
    echo ""
    echo -e "${PURPLE}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                                                       ║${NC}"
    echo -e "${PURPLE}║              API KEY COLLECTION                       ║${NC}"
    echo -e "${PURPLE}║       All keys will be collected upfront             ║${NC}"
    echo -e "${PURPLE}║                                                       ║${NC}"
    echo -e "${PURPLE}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Note: Keys will be validated and stored securely in .env.local${NC}"
    echo -e "${YELLOW}      Production keys will be set in Vercel (encrypted)${NC}"
    echo ""
    
    # Gather Clerk keys (both dev and prod)
    if $use_clerk; then
        gather_clerk_keys "$use_tui"
    fi
    
    # Gather AI provider keys
    if $use_ai; then
        if [ "$ai_provider" = "openai" ] || [ "$ai_provider" = "both" ]; then
            gather_openai_key "$use_tui"
        fi
        
        if [ "$ai_provider" = "anthropic" ] || [ "$ai_provider" = "both" ]; then
            gather_anthropic_key "$use_tui"
        fi
    fi
    
    # Gather Linear key
    if $use_linear; then
        gather_linear_key "$use_tui"
    fi
    
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ✓ All API keys collected successfully!              ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    return 0
}

