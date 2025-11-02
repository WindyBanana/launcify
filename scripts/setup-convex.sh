#!/bin/bash

# Setup Convex with development and production deployments

setup_convex() {
    local project_name=$1
    local package_manager=$2

    echo -e "${BLUE}Setting up Convex...${NC}"

    # Install Convex package
    echo -e "${BLUE}Installing Convex package...${NC}"
    if [ "$package_manager" = "pnpm" ]; then
        pnpm add convex
    elif [ "$package_manager" = "yarn" ]; then
        yarn add convex
    else
        npm install convex
    fi

    # Create convex directory structure
    mkdir -p convex

    # Create basic schema
    cat > convex/schema.ts << 'EOF'
import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

// Define your Convex schema here
// Example:
// export default defineSchema({
//   users: defineTable({
//     name: v.string(),
//     email: v.string(),
//     createdAt: v.number(),
//   }).index("by_email", ["email"]),
// });

export default defineSchema({
  // Add your tables here
});
EOF

    # Create example query
    cat > convex/example.ts << 'EOF'
import { query } from "./_generated/server";

// Example query - delete this and add your own
export const get = query({
  args: {},
  handler: async (ctx) => {
    return { message: "Hello from Convex!" };
  },
});
EOF

    # Create convex.json config
    cat > convex.json << 'EOF'
{
  "functions": "convex/"
}
EOF

    echo -e "${GREEN}✓ Convex files created${NC}"

    # Initialize Convex
    echo -e "${BLUE}Initializing Convex development deployment...${NC}"
    echo -e "${CYAN}This will open your browser to create/link a Convex project${NC}"

    npx convex dev --once --configure=new

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Convex development deployment initialized${NC}"

        # Update .env.local with Convex URL
        if [ -f .env.local ]; then
            # Get the Convex URL from .env.local
            CONVEX_URL=$(grep "NEXT_PUBLIC_CONVEX_URL" .env.local | cut -d'=' -f2)
            if [ -n "$CONVEX_URL" ]; then
                echo -e "${GREEN}✓ NEXT_PUBLIC_CONVEX_URL added to .env.local${NC}"
            fi
        fi

        echo -e "\n${CYAN}Convex Setup Complete:${NC}"
        echo -e "  ${GREEN}✓${NC} Development deployment created"
        echo -e "  ${GREEN}✓${NC} Schema and example files created"
        echo -e "  ${GREEN}✓${NC} Environment variables configured"
        echo -e "\n  ${YELLOW}For Production Deployment:${NC}"
        echo -e "    1. Create production deployment:"
        echo -e "       ${CYAN}npx convex deploy --prod${NC}"
        echo -e "    2. Get production URL and deploy key from Convex dashboard"
        echo -e "    3. Add to Vercel environment variables:"
        echo -e "       - NEXT_PUBLIC_CONVEX_URL"
        echo -e "       - CONVEX_DEPLOY_KEY (for CI/CD)"
        echo -e "\n  ${YELLOW}Running Convex:${NC}"
        echo -e "    - Development: ${CYAN}npx convex dev${NC} (in separate terminal)"
        echo -e "    - Or let Next.js handle it automatically"

        # Add Convex scripts to package.json
        add_convex_scripts "$package_manager"
    else
        echo -e "${YELLOW}⚠️  Convex initialization incomplete${NC}"
        echo -e "${CYAN}You can run 'npx convex dev' manually later${NC}"
    fi
}

add_convex_scripts() {
    local package_manager=$1

    # Add useful scripts to package.json
    if command -v jq &> /dev/null; then
        # Use jq to modify package.json if available
        jq '.scripts += {
            "convex:dev": "convex dev",
            "convex:deploy": "convex deploy --prod"
        }' package.json > package.json.tmp && mv package.json.tmp package.json

        echo -e "${GREEN}✓ Added Convex scripts to package.json${NC}"
    else
        echo -e "${YELLOW}ℹ️  Manually add these scripts to package.json:${NC}"
        echo -e '    "convex:dev": "convex dev"'
        echo -e '    "convex:deploy": "convex deploy --prod"'
    fi
}
