#!/bin/bash

# Setup Axiom for observability

setup_axiom() {
    local project_name=$1

    echo -e "${BLUE}Setting up Axiom...${NC}"

    # Check if user is logged in to Axiom
    if ! axiom auth status &> /dev/null; then
        echo -e "${YELLOW}⚠️  Not logged in to Axiom${NC}"
        echo -e "${CYAN}Opening browser for login...${NC}"
        axiom auth login
    else
        echo -e "${GREEN}✓ Logged in to Axiom${NC}"
    fi

    # Create dataset
    local dataset_name="${project_name}-dev"
    echo -e "${BLUE}Creating Axiom dataset: $dataset_name${NC}"

    axiom dataset create "$dataset_name" --description "Development logs for $project_name" 2>/dev/null || {
        echo -e "${YELLOW}⚠️  Dataset might already exist or creation failed${NC}"
        echo -e "${CYAN}Continuing with setup...${NC}"
    }

    # Create API token
    echo -e "${BLUE}Creating Axiom API token...${NC}"
    local token_name="${project_name}-token-$(date +%s)"

    # Note: Axiom CLI token creation might be interactive
    echo -e "${CYAN}Creating token: $token_name${NC}"
    axiom auth token create "$token_name" --datasets="$dataset_name:ingest" 2>/dev/null || {
        echo -e "${YELLOW}⚠️  Could not create token automatically${NC}"
        echo -e "${CYAN}Please create token manually:${NC}"
        echo -e "  1. Go to: https://app.axiom.co/settings/tokens"
        echo -e "  2. Create new token with 'ingest' permission for dataset: $dataset_name"
        echo -e "  3. Copy token to .env.local as AXIOM_TOKEN"
    }

    # Update .env.local with Axiom config
    if [ -f .env.local ]; then
        # Add dataset name
        sed -i "s|^AXIOM_DATASET=.*|AXIOM_DATASET=$dataset_name|g" .env.local
        echo -e "${GREEN}✓ AXIOM_DATASET updated in .env.local${NC}"
    fi

    # Install Axiom Next.js package
    echo -e "${BLUE}Installing @axiomhq/js package...${NC}"
    if [ "$PACKAGE_MANAGER" = "pnpm" ]; then
        pnpm add @axiomhq/js
    elif [ "$PACKAGE_MANAGER" = "yarn" ]; then
        yarn add @axiomhq/js
    else
        npm install @axiomhq/js
    fi

    # Create Axiom utility file
    mkdir -p lib
    cat > lib/axiom.ts << 'EOF'
import { Axiom } from '@axiomhq/js';

// Initialize Axiom client
// Make sure AXIOM_DATASET and AXIOM_TOKEN are set in your environment
const axiom = new Axiom({
  token: process.env.AXIOM_TOKEN!,
  orgId: process.env.AXIOM_ORG_ID,
});

const dataset = process.env.AXIOM_DATASET || 'default';

// Helper function to log events
export async function logEvent(
  type: 'info' | 'error' | 'warn' | 'debug',
  message: string,
  data?: Record<string, any>
) {
  try {
    await axiom.ingest(dataset, [
      {
        _time: new Date().toISOString(),
        type,
        message,
        ...data,
      },
    ]);
    await axiom.flush();
  } catch (error) {
    console.error('Failed to log to Axiom:', error);
  }
}

// Specific logging functions
export const logger = {
  info: (message: string, data?: Record<string, any>) =>
    logEvent('info', message, data),

  error: (message: string, error?: Error, data?: Record<string, any>) =>
    logEvent('error', message, {
      ...data,
      error: error?.message,
      stack: error?.stack,
    }),

  warn: (message: string, data?: Record<string, any>) =>
    logEvent('warn', message, data),

  debug: (message: string, data?: Record<string, any>) =>
    logEvent('debug', message, data),
};

export default axiom;
EOF

    echo -e "${GREEN}✓ Axiom utility created at lib/axiom.ts${NC}"

    echo -e "\n${CYAN}Axiom Setup Complete:${NC}"
    echo -e "  ${GREEN}✓${NC} Dataset created: $dataset_name"
    echo -e "  ${GREEN}✓${NC} Client library installed"
    echo -e "  ${GREEN}✓${NC} Helper utilities created"
    echo -e "\n  ${YELLOW}Next steps:${NC}"
    echo -e "    1. Verify AXIOM_TOKEN in .env.local"
    echo -e "    2. Dashboard: https://app.axiom.co"
    echo -e "    3. View logs in your dataset: $dataset_name"
    echo -e "\n  ${YELLOW}Usage in your code:${NC}"
    echo -e "    ${CYAN}import { logger } from '@/lib/axiom';${NC}"
    echo -e "    ${CYAN}await logger.info('User logged in', { userId: '123' });${NC}"
}
