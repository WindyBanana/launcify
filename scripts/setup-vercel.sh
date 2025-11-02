#!/bin/bash

# Setup Vercel with development and production environments

setup_vercel() {
    local project_name=$1

    echo -e "${BLUE}Setting up Vercel project...${NC}"

    # Check if user is logged in
    if ! vercel whoami &> /dev/null; then
        echo -e "${YELLOW}⚠️  Not logged in to Vercel${NC}"
        echo -e "${CYAN}Opening browser for login...${NC}"
        vercel login
    else
        echo -e "${GREEN}✓ Logged in to Vercel as $(vercel whoami)${NC}"
    fi

    # Link/create Vercel project
    echo -e "${BLUE}Linking Vercel project...${NC}"
    echo -e "${CYAN}This will create a new Vercel project or link to an existing one${NC}"

    # Run vercel link (interactive)
    vercel link --yes

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Vercel project linked${NC}"

        # Create vercel.json configuration
        cat > vercel.json << EOF
{
  "buildCommand": "npm run build",
  "devCommand": "npm run dev",
  "installCommand": "npm install",
  "framework": "nextjs",
  "regions": ["iad1"],
  "env": {
    "NODE_ENV": "production"
  },
  "build": {
    "env": {}
  }
}
EOF
        echo -e "${GREEN}✓ vercel.json created${NC}"

        echo -e "\n${CYAN}Vercel Setup Complete:${NC}"
        echo -e "  ${GREEN}✓${NC} Project created/linked"
        echo -e "  ${GREEN}✓${NC} Development environment: Preview deployments (automatic on push)"
        echo -e "  ${GREEN}✓${NC} Production environment: Production deployments (main branch)"
        echo -e "\n  ${YELLOW}Next steps:${NC}"
        echo -e "    1. Set environment variables in Vercel dashboard"
        echo -e "    2. Go to: https://vercel.com/dashboard"
        echo -e "    3. Select your project > Settings > Environment Variables"
        echo -e "    4. Add production keys (CLERK_SECRET_KEY, etc.)"
    else
        echo -e "${RED}✗ Failed to link Vercel project${NC}"
        echo -e "${YELLOW}You can run 'vercel link' manually later${NC}"
    fi
}
