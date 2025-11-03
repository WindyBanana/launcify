#!/bin/bash

# Post-Action Verification Functions
# Verify that setup actions were successful

# Verify Vercel environment variables
verify_vercel_env() {
    local project_name=$1
    local env_var_name=$2
    local expected_target=$3  # "production", "preview", "development"
    
    if [[ -z "$VERCEL_TOKEN" ]]; then
        echo -e "${YELLOW}⚠️  Cannot verify: VERCEL_TOKEN not set${NC}"
        return 2  # Cannot verify
    fi
    
    echo -e "${CYAN}Verifying Vercel env var: $env_var_name...${NC}"
    
    # Get project details
    local project_response=$(curl -s \
        "https://api.vercel.com/v9/projects/${project_name}" \
        -H "Authorization: Bearer ${VERCEL_TOKEN}")
    
    local project_id=$(echo "$project_response" | grep -o '"id":"[^"]*"' | head -1 | sed 's/"id":"//' | sed 's/"$//')
    
    if [[ -z "$project_id" ]]; then
        echo -e "${RED}✗ Could not find Vercel project${NC}"
        return 1
    fi
    
    # Get environment variables
    local env_response=$(curl -s \
        "https://api.vercel.com/v9/projects/${project_id}/env" \
        -H "Authorization: Bearer ${VERCEL_TOKEN}")
    
    # Check if the variable exists
    if echo "$env_response" | grep -q "\"key\":\"${env_var_name}\""; then
        echo -e "${GREEN}✓ ${env_var_name} is set in Vercel${NC}"
        return 0
    else
        echo -e "${RED}✗ ${env_var_name} not found in Vercel${NC}"
        echo -e "${YELLOW}Remediation: Set manually at https://vercel.com/${project_name}/settings/environment-variables${NC}"
        return 1
    fi
}

# Verify all critical Vercel environment variables
verify_all_vercel_envs() {
    local project_name=$1
    shift
    local env_vars=("$@")
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Verifying Vercel Environment Variables${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    local success_count=0
    local fail_count=0
    local skip_count=0
    
    for env_var in "${env_vars[@]}"; do
        IFS='=' read -r key value target type <<< "$env_var"
        
        verify_vercel_env "$project_name" "$key" "$target"
        local result=$?
        
        if [ $result -eq 0 ]; then
            ((success_count++))
        elif [ $result -eq 2 ]; then
            ((skip_count++))
        else
            ((fail_count++))
        fi
    done
    
    echo ""
    echo -e "${GREEN}✓ Verified: ${success_count}${NC}"
    if [ $fail_count -gt 0 ]; then
        echo -e "${RED}✗ Failed: ${fail_count}${NC}"
    fi
    if [ $skip_count -gt 0 ]; then
        echo -e "${YELLOW}⚠  Skipped: ${skip_count}${NC}"
    fi
    echo ""
    
    return 0
}

# Verify Clerk webhook was created
verify_clerk_webhook() {
    local clerk_secret_key=$1
    local webhook_url=$2
    
    if [[ -z "$clerk_secret_key" ]]; then
        echo -e "${YELLOW}⚠️  Cannot verify: Clerk secret key not provided${NC}"
        return 2
    fi
    
    echo -e "${CYAN}Verifying Clerk webhook...${NC}"
    
    # Get Svix app details from Clerk
    local svix_response=$(curl -s -X POST "https://api.clerk.com/v1/webhooks/svix" \
        -H "Authorization: Bearer ${clerk_secret_key}" \
        -H "Content-Type: application/json")
    
    if echo "$svix_response" | grep -q "errors"; then
        echo -e "${RED}✗ Could not verify Clerk webhook${NC}"
        echo -e "${YELLOW}Remediation: Check webhook configuration in Clerk dashboard${NC}"
        return 1
    fi
    
    # Get Svix URL to verify webhook exists
    local svix_url_response=$(curl -s -X POST "https://api.clerk.com/v1/webhooks/svix_url" \
        -H "Authorization: Bearer ${clerk_secret_key}" \
        -H "Content-Type: application/json")
    
    if echo "$svix_url_response" | grep -q "url"; then
        echo -e "${GREEN}✓ Clerk webhook integration verified${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  Could not fully verify webhook${NC}"
        echo -e "${YELLOW}Remediation: Verify webhook in Clerk dashboard${NC}"
        return 2
    fi
}

# Verify Axiom dataset exists
verify_axiom_dataset() {
    local dataset_name=$1
    
    if ! command -v axiom &> /dev/null; then
        echo -e "${YELLOW}⚠️  Cannot verify: Axiom CLI not installed${NC}"
        return 2
    fi
    
    echo -e "${CYAN}Verifying Axiom dataset: $dataset_name...${NC}"
    
    # Check if logged in
    if ! axiom auth status &> /dev/null; then
        echo -e "${YELLOW}⚠️  Not logged in to Axiom${NC}"
        echo -e "${YELLOW}Remediation: Run 'axiom auth login'${NC}"
        return 2
    fi
    
    # List datasets and check if ours exists
    local datasets=$(axiom dataset list --json 2>/dev/null)
    
    if echo "$datasets" | grep -q "\"name\":\"${dataset_name}\""; then
        echo -e "${GREEN}✓ Axiom dataset '${dataset_name}' exists${NC}"
        return 0
    else
        echo -e "${RED}✗ Axiom dataset '${dataset_name}' not found${NC}"
        echo -e "${YELLOW}Remediation: Run 'axiom dataset create ${dataset_name}'${NC}"
        return 1
    fi
}

# Verify Convex deployment
verify_convex_deployment() {
    local convex_url=$1
    
    if [[ -z "$convex_url" ]]; then
        echo -e "${YELLOW}⚠️  Cannot verify: CONVEX_URL not provided${NC}"
        return 2
    fi
    
    echo -e "${CYAN}Verifying Convex deployment...${NC}"
    
    # Try to reach the Convex deployment
    local response=$(curl -s -o /dev/null -w "%{http_code}" "${convex_url}" 2>/dev/null)
    
    if [[ "$response" =~ ^(200|301|302|404)$ ]]; then
        echo -e "${GREEN}✓ Convex deployment is reachable${NC}"
        return 0
    else
        echo -e "${RED}✗ Convex deployment not reachable (HTTP $response)${NC}"
        echo -e "${YELLOW}Remediation: Run 'npx convex dev' and check deployment${NC}"
        return 1
    fi
}

# Verify GitHub repository was created
verify_github_repo() {
    local repo_name=$1
    
    if ! command -v gh &> /dev/null; then
        echo -e "${YELLOW}⚠️  Cannot verify: GitHub CLI not installed${NC}"
        return 2
    fi
    
    if ! gh auth status &> /dev/null; then
        echo -e "${YELLOW}⚠️  Not logged in to GitHub CLI${NC}"
        return 2
    fi
    
    echo -e "${CYAN}Verifying GitHub repository...${NC}"
    
    if gh repo view "$repo_name" &> /dev/null; then
        echo -e "${GREEN}✓ GitHub repository exists${NC}"
        return 0
    else
        echo -e "${RED}✗ GitHub repository not found${NC}"
        echo -e "${YELLOW}Remediation: Create repository manually or run setup again${NC}"
        return 1
    fi
}

# Verify file exists and has content
verify_file_exists() {
    local file_path=$1
    local description=$2
    
    echo -e "${CYAN}Verifying ${description}...${NC}"
    
    if [[ ! -f "$file_path" ]]; then
        echo -e "${RED}✗ ${description} not found at ${file_path}${NC}"
        return 1
    fi
    
    if [[ ! -s "$file_path" ]]; then
        echo -e "${YELLOW}⚠️  ${description} is empty${NC}"
        return 2
    fi
    
    echo -e "${GREEN}✓ ${description} exists${NC}"
    return 0
}

# Verify package installation
verify_package_installed() {
    local package_name=$1
    local package_manager=${2:-"npm"}
    
    echo -e "${CYAN}Verifying package: $package_name...${NC}"
    
    # Check package.json
    if [[ ! -f "package.json" ]]; then
        echo -e "${RED}✗ package.json not found${NC}"
        return 1
    fi
    
    if grep -q "\"${package_name}\"" package.json; then
        echo -e "${GREEN}✓ ${package_name} is in package.json${NC}"
        
        # Check if node_modules exists
        if [[ -d "node_modules/${package_name}" ]]; then
            echo -e "${GREEN}✓ ${package_name} is installed${NC}"
            return 0
        else
            echo -e "${YELLOW}⚠️  ${package_name} not installed yet${NC}"
            echo -e "${YELLOW}Remediation: Run '${package_manager} install'${NC}"
            return 2
        fi
    else
        echo -e "${RED}✗ ${package_name} not in package.json${NC}"
        return 1
    fi
}

# Comprehensive verification after setup
run_comprehensive_verification() {
    local project_name=$1
    
    echo -e "${PURPLE}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                                                       ║${NC}"
    echo -e "${PURPLE}║          POST-SETUP VERIFICATION                      ║${NC}"
    echo -e "${PURPLE}║                                                       ║${NC}"
    echo -e "${PURPLE}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    local total_checks=0
    local passed_checks=0
    local failed_checks=0
    local skipped_checks=0
    
    # Verify critical files
    if $USE_CONVEX; then
        verify_file_exists "convex/schema.ts" "Convex schema"
        case $? in
            0) ((passed_checks++)) ;;
            1) ((failed_checks++)) ;;
            2) ((skipped_checks++)) ;;
        esac
        ((total_checks++))
    fi
    
    if $USE_CLERK; then
        verify_file_exists "middleware.ts" "Clerk middleware"
        case $? in
            0) ((passed_checks++)) ;;
            1) ((failed_checks++)) ;;
            2) ((skipped_checks++)) ;;
        esac
        ((total_checks++))
        
        verify_file_exists "app/api/webhooks/clerk/route.ts" "Clerk webhook handler"
        case $? in
            0) ((passed_checks++)) ;;
            1) ((failed_checks++)) ;;
            2) ((skipped_checks++)) ;;
        esac
        ((total_checks++))
        
        verify_package_installed "@clerk/nextjs" "$PACKAGE_MANAGER"
        case $? in
            0) ((passed_checks++)) ;;
            1) ((failed_checks++)) ;;
            2) ((skipped_checks++)) ;;
        esac
        ((total_checks++))
    fi
    
    if $USE_SHADCN; then
        verify_file_exists "components.json" "shadcn/ui config"
        case $? in
            0) ((passed_checks++)) ;;
            1) ((failed_checks++)) ;;
            2) ((skipped_checks++)) ;;
        esac
        ((total_checks++))
    fi
    
    if $USE_FEATURE_TOGGLES; then
        verify_file_exists "convex/featureFlags.ts" "Feature flags Convex functions"
        case $? in
            0) ((passed_checks++)) ;;
            1) ((failed_checks++)) ;;
            2) ((skipped_checks++)) ;;
        esac
        ((total_checks++))
        
        verify_file_exists "hooks/use-feature-flag.ts" "Feature flag hook"
        case $? in
            0) ((passed_checks++)) ;;
            1) ((failed_checks++)) ;;
            2) ((skipped_checks++)) ;;
        esac
        ((total_checks++))
    fi
    
    verify_file_exists ".env.local" "Environment file"
    case $? in
        0) ((passed_checks++)) ;;
        1) ((failed_checks++)) ;;
        2) ((skipped_checks++)) ;;
    esac
    ((total_checks++))
    
    verify_file_exists "VERCEL_ENVIRONMENT_SETUP.md" "Vercel setup guide"
    case $? in
        0) ((passed_checks++)) ;;
        1) ((failed_checks++)) ;;
        2) ((skipped_checks++)) ;;
    esac
    ((total_checks++))
    
    # Summary
    echo ""
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Verification Summary:${NC}"
    echo -e "  Total Checks: $total_checks"
    echo -e "  ${GREEN}✓ Passed: $passed_checks${NC}"
    if [ $failed_checks -gt 0 ]; then
        echo -e "  ${RED}✗ Failed: $failed_checks${NC}"
    fi
    if [ $skipped_checks -gt 0 ]; then
        echo -e "  ${YELLOW}⚠  Skipped: $skipped_checks${NC}"
    fi
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    if [ $failed_checks -eq 0 ]; then
        echo -e "${GREEN}✅ All verifications passed!${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  Some verifications failed. See remediation steps above.${NC}"
        return 1
    fi
}

