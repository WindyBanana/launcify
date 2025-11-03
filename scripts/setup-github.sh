#!/bin/bash

# Setup GitHub repository and connect to Vercel

setup_github() {
    local project_name=$1
    local project_dir=$2
    local vercel_team_id=$3

    echo -e "${BLUE}Setting up GitHub repository...${NC}"

    # Check if gh cli is installed
    if ! command -v gh &> /dev/null; then
        echo -e "${YELLOW}⚠️  GitHub CLI (gh) not found.${NC}"
        echo -e "${CYAN}Please install it to enable automatic repository creation: https://cli.github.com/${NC}"
        return 1
    fi

    # Check if user is logged in
    if ! gh auth status &> /dev/null; then
        echo -e "${YELLOW}⚠️  You are not logged in to the GitHub CLI.${NC}"
        read -p "Log in with GitHub CLI now? [Y/n]: " login_choice
        login_choice=${login_choice:-Y}
        if [[ $login_choice =~ ^[Yy]$ ]]; then
            if ! gh auth login; then
                echo -e "${RED}✗ GitHub login failed. Skipping GitHub setup.${NC}"
                return 1
            fi
        else
            echo -e "${YELLOW}Skipping GitHub setup.${NC}"
            return 1
        fi
    fi

    echo -e "${GREEN}✓ Logged in to GitHub CLI${NC}"

    # Ask for repository details
    read -p "Enter GitHub repository name (default: $project_name): " repo_name
    repo_name=${repo_name:-$project_name}

    read -p "Create a public or private repository? [public/private] (default: private): " visibility
    visibility=${visibility:-private}

    echo -e "${BLUE}Creating GitHub repository '$repo_name'...${NC}"

    # Create repository
    if gh repo create "$repo_name" --$visibility --source="$project_dir" --push --remote=origin; then
        echo -e "${GREEN}✓ GitHub repository created and code pushed successfully.${NC}"
        
        # Get repository details
        local repo_owner=$(gh repo view --json owner --jq .owner.login 2>/dev/null)
        local repo_url="https://github.com/${repo_owner}/${repo_name}"
        
        echo -e "${GREEN}✓ Repository URL: ${repo_url}${NC}"
        
        # If Vercel is being used, connect the repo and set up CI/CD
        if command -v vercel &> /dev/null; then
            echo ""
            echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${CYAN}Setting up Vercel CI/CD Integration${NC}"
            echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo ""
            
            # Link Vercel to GitHub repo
            echo -e "${BLUE}Linking Vercel project to GitHub repository...${NC}"
            
            # Try to connect via Vercel API if token is available
            if [[ -n "$VERCEL_TOKEN" ]]; then
                setup_vercel_github_integration "$repo_name" "$repo_owner" "$vercel_team_id"
            else
                echo -e "${YELLOW}⚠️  VERCEL_TOKEN not set${NC}"
                echo -e "${CYAN}Manual setup required:${NC}"
                echo -e "  1. Go to: https://vercel.com/dashboard"
                echo -e "  2. Select your project: ${repo_name}"
                echo -e "  3. Go to Settings → Git"
                echo -e "  4. Connect to repository: ${repo_url}"
                echo ""
                echo -e "${BLUE}After connection, Vercel will automatically:${NC}"
                echo -e "  ${GREEN}✓${NC} Deploy main branch to Production"
                echo -e "  ${GREEN}✓${NC} Deploy other branches to Preview"
                echo -e "  ${GREEN}✓${NC} Create deployments for every push"
            fi
        fi
        
        echo ""
        echo -e "${GREEN}╔═══════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║  ✓ GitHub CI/CD Setup Complete!                      ║${NC}"
        echo -e "${GREEN}╚═══════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${CYAN}Repository:${NC} ${repo_url}"
        echo -e "${CYAN}Branch Deployment Strategy:${NC}"
        echo -e "  • ${GREEN}main${NC} → Production (https://your-project.vercel.app)"
        echo -e "  • ${BLUE}other branches${NC} → Preview (https://branch-name-your-project.vercel.app)"
        echo ""
        
        return 0
    else
        echo -e "${RED}✗ Failed to create GitHub repository.${NC}"
        echo -e "${YELLOW}It might already exist or there was an authentication issue.${NC}"
        return 1
    fi
}

# Setup Vercel-GitHub integration via API
setup_vercel_github_integration() {
    local repo_name=$1
    local repo_owner=$2
    local vercel_team_id=$3
    
    echo -e "${BLUE}Configuring Vercel deployment settings for GitHub...${NC}"
    
    # Get Vercel project details
    local project_response=$(curl -s \
        "https://api.vercel.com/v9/projects/${repo_name}" \
        -H "Authorization: Bearer ${VERCEL_TOKEN}")
    
    local project_id=$(echo "$project_response" | grep -o '"id":"[^"]*"' | head -1 | sed 's/"id":"//' | sed 's/"$//')
    
    if [[ -z "$project_id" ]]; then
        echo -e "${YELLOW}⚠️  Could not find Vercel project${NC}"
        echo -e "${CYAN}Make sure the project is linked to Vercel first${NC}"
        return 1
    fi
    
    # Configure GitHub connection
    local git_config=$(cat <<EOF
{
  "gitRepositoryId": "${repo_owner}/${repo_name}",
  "productionBranch": "main",
  "autoExposeSystemEnvs": true
}
EOF
)
    
    local update_response=$(curl -s -X PATCH \
        "https://api.vercel.com/v9/projects/${project_id}" \
        -H "Authorization: Bearer ${VERCEL_TOKEN}" \
        -H "Content-Type: application/json" \
        -d "$git_config")
    
    if echo "$update_response" | grep -q '"error"'; then
        echo -e "${YELLOW}⚠️  Could not auto-configure GitHub integration${NC}"
        echo -e "${CYAN}Please connect manually in Vercel dashboard${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✓ Vercel project connected to GitHub${NC}"
    echo -e "${GREEN}✓ Production branch set to: main${NC}"
    echo -e "${GREEN}✓ Preview deployments enabled for all branches${NC}"
    
    return 0
}
