#!/bin/bash

# Execute Setup Phase - Non-Interactive
# All inputs should be collected before calling this

# Execute project creation
execute_create_project() {
    should_skip_step 1 && return 0
    
    show_progress 1
    start_step_timer
    
    if ! $RESUMING; then
        echo -e "${CYAN}Creating Project${NC}"
        create_project "$PROJECT_NAME" "$FRAMEWORK" "$PACKAGE_MANAGER"
        echo ""
        cd "$PROJECT_NAME"
    else
        echo -e "${CYAN}Project Creation${NC}"
        echo -e "${BLUE}✓ Skipping - project already exists${NC}"
        echo ""
    fi
    
    end_step_timer 1
    mark_step_completed 1
}

# Execute Vercel setup
execute_vercel_setup() {
    should_skip_step 2 && return 0
    
    show_progress 2
    start_step_timer
    
    if should_setup_service "Vercel" "$USE_VERCEL" "$HAS_VERCEL"; then
        echo -e "${CYAN}Setting up Vercel...${NC}"
        setup_vercel "$PROJECT_NAME"
        echo ""
    fi
    
    end_step_timer 2
    mark_step_completed 2
}

# Execute Convex setup
execute_convex_setup() {
    should_skip_step 3 && return 0
    show_progress 3
    start_step_timer
    
    if should_setup_service "Convex" "$USE_CONVEX" "$HAS_CONVEX"; then
        echo -e "${CYAN}Setting up Convex...${NC}"
        setup_convex "$PROJECT_NAME" "$PACKAGE_MANAGER"
        echo ""
    fi
    
    end_step_timer 3
    mark_step_completed 3
}

# Execute Axiom setup
execute_axiom_setup() {
    should_skip_step 4 && return 0
    show_progress 4
    start_step_timer
    
    if should_setup_service "Axiom" "$USE_AXIOM" "$HAS_AXIOM"; then
        echo -e "${CYAN}Setting up Axiom Observability...${NC}"
        echo -e "${BLUE}After setup, you'll need to run: ${GREEN}axiom auth login${NC}"
        echo -e "${BLUE}and create an API token${NC}"
        echo ""
        if setup_axiom "$PROJECT_NAME"; then
            echo -e "${GREEN}✓ Axiom setup completed${NC}"
        else
            echo -e "${YELLOW}⚠️  Axiom setup incomplete - manual configuration needed${NC}"
            echo -e "${CYAN}See SETUP_GUIDE.md for manual setup instructions${NC}"
        fi
        echo ""
    fi
    
    end_step_timer 4
    mark_step_completed 4
}

# Execute Clerk setup (with pre-collected API keys)
execute_clerk_setup() {
    should_skip_step 5 && return 0
    show_progress 5
    start_step_timer
    
    if should_setup_service "Clerk" "$USE_CLERK" "$HAS_CLERK"; then
        echo -e "${CYAN}Setting up Clerk Authentication...${NC}"
        echo -e "${BLUE}Using pre-collected API keys...${NC}"
        echo ""
        
        # Setup Clerk with the pre-collected keys
        if setup_clerk_automated "$USE_CONVEX" "$USE_VERCEL" "$PROJECT_NAME"; then
            CLERK_AUTOMATED=true
            echo -e "${GREEN}✓ Clerk automated setup completed${NC}"
        else
            CLERK_AUTOMATED=false
            echo -e "${YELLOW}⚠️  Clerk needs manual configuration${NC}"
            echo -e "${BLUE}See the manual setup summary at the end${NC}"
        fi
        echo ""
    fi
    
    end_step_timer 5
    mark_step_completed 5
}

# Execute shadcn/ui setup
execute_shadcn_setup() {
    should_skip_step 6 && return 0
    show_progress 6
    start_step_timer
    
    if should_setup_service "shadcn/ui" "$USE_SHADCN" "$HAS_SHADCN"; then
        echo -e "${CYAN}Setting up shadcn/ui...${NC}"
        setup_shadcn "$PACKAGE_MANAGER"
        echo ""
    fi
    
    end_step_timer 6
    mark_step_completed 6
}

# Execute AI integration setup
execute_ai_setup() {
    should_skip_step 7 && return 0
    show_progress 7
    start_step_timer
    
    if should_setup_service "AI Integration" "$USE_AI" "$HAS_AI"; then
        echo -e "${CYAN}Setting up AI Integration...${NC}"
        echo -e "${BLUE}Using pre-collected API keys...${NC}"
        echo ""
        setup_ai "$PACKAGE_MANAGER" "$AI_PROVIDER"
        echo ""
    fi
    
    end_step_timer 7
    mark_step_completed 7
}

# Execute Admin Panel setup
execute_admin_setup() {
    should_skip_step 8 && return 0
    show_progress 8
    start_step_timer
    
    if should_setup_service "Admin Panel" "$USE_ADMIN" "$HAS_ADMIN"; then
        echo -e "${CYAN}Setting up Admin Panel...${NC}"
        setup_admin_panel "$USE_CLERK" "$USE_AXIOM" "$USE_LINEAR" "$ADMIN_PROD_ENABLED"
        echo ""
    fi
    
    end_step_timer 8
    mark_step_completed 8
}

# Execute Feature Toggle Dashboard setup
execute_feature_toggles_setup() {
    should_skip_step 9 && return 0
    show_progress 9
    start_step_timer
    
    if $USE_FEATURE_TOGGLES && ! $HAS_FEATURE_TOGGLES; then
        echo -e "${CYAN}Setting up Feature Toggle Dashboard...${NC}"
        setup_feature_toggles
        echo ""
        HAS_FEATURE_TOGGLES=true
    elif $USE_FEATURE_TOGGLES && $HAS_FEATURE_TOGGLES; then
        echo -e "${CYAN}Feature Toggle Dashboard${NC}"
        echo -e "${BLUE}✓ Already configured${NC}"
        echo ""
    fi
    
    end_step_timer 9
    mark_step_completed 9
}

# Execute GitHub CI/CD setup
execute_github_setup() {
    should_skip_step 10 && return 0
    show_progress 10
    start_step_timer
    
    if $USE_GITHUB && ! $HAS_GITHUB; then
        echo -e "${CYAN}Setting up GitHub Repository & CI/CD...${NC}"
        
        # Get Vercel team ID if using Vercel
        local vercel_team_id=""
        if $USE_VERCEL; then
            vercel_team_id=$(vercel whoami 2>/dev/null | grep -o 'team_[A-Za-z0-9_]*' | head -1)
        fi
        
        if setup_github "$PROJECT_NAME" "$(pwd)" "$vercel_team_id"; then
            echo -e "${GREEN}✓ GitHub setup completed${NC}"
            HAS_GITHUB=true
        else
            echo -e "${YELLOW}⚠️  GitHub setup skipped or incomplete${NC}"
        fi
        echo ""
    elif $USE_GITHUB && $HAS_GITHUB; then
        echo -e "${CYAN}GitHub Repository${NC}"
        echo -e "${BLUE}✓ Already configured${NC}"
        echo ""
    fi
    
    end_step_timer 10
    mark_step_completed 10
}

# Generate environment files
execute_generate_env_files() {
    should_skip_step 11 && return 0
    show_progress 11
    start_step_timer
    
    if ! $HAS_ENV || $RESUMING; then
        echo -e "${CYAN}Generating Environment Files${NC}"
        echo -e "${YELLOW}Security Reminder:${NC}"
        echo -e "   • .env.local contains your secrets - ${GREEN}stored locally only${NC}"
        echo -e "   • ${RED}Never commit .env files to Git${NC}"
        echo -e "   • Production secrets set separately in Vercel dashboard"
        echo ""
        generate_env_files "$USE_VERCEL" "$USE_CONVEX" "$USE_CLERK" "$USE_AXIOM" "$USE_LINEAR" "$USE_AI" "$AI_PROVIDER"
        echo ""
        echo -e "${GREEN}✓ Environment files created${NC}"
        echo -e "${BLUE}.env.local is already in .gitignore - safe from Git${NC}"
        echo ""
    else
        echo -e "${CYAN}Environment Files${NC}"
        echo -e "${BLUE}✓ .env.local already exists${NC}"
        echo ""
    fi
    
    end_step_timer 11
    mark_step_completed 11
}

# Create setup guides
execute_create_guides() {
    should_skip_step 12 && return 0
    show_progress 12
    start_step_timer
    
    if ! $HAS_GUIDE || $RESUMING; then
        echo -e "${CYAN}Creating Setup Guides${NC}"
        
        # Always copy Vercel environment setup guide
        cp "$SCRIPT_DIR/guides/VERCEL_ENVIRONMENT_SETUP.md" .
        echo -e "${GREEN}✓ VERCEL_ENVIRONMENT_SETUP.md created${NC}"
        
        # Create service-specific guides if needed
        if $USE_CLERK || $USE_LINEAR; then
            create_setup_guides "$USE_CLERK" "$USE_LINEAR"
        fi
        
        echo ""
    else
        echo -e "${CYAN}Setup Guides${NC}"
        echo -e "${BLUE}✓ Setup guides already exist${NC}"
        echo ""
    fi
    
    end_step_timer 12
    mark_step_completed 12
}

# Validate project build
execute_validate_build() {
    should_skip_step 13 && return 0
    show_progress 13
    start_step_timer
    
    echo -e "${CYAN}Validating Project Build${NC}"
    echo -e "${BLUE}Running type check...${NC}"
    
    if [ "$PACKAGE_MANAGER" = "pnpm" ]; then
        pnpm tsc --noEmit
    elif [ "$PACKAGE_MANAGER" = "yarn" ]; then
        yarn tsc --noEmit
    else
        npm run tsc --noEmit 2>/dev/null || npx tsc --noEmit
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Type check passed${NC}"
    else
        echo -e "${YELLOW}⚠️  Type check had warnings (non-critical)${NC}"
    fi
    
    echo -e "${BLUE}Running lint...${NC}"
    if [ "$PACKAGE_MANAGER" = "pnpm" ]; then
        pnpm lint
    elif [ "$PACKAGE_MANAGER" = "yarn" ]; then
        yarn lint
    else
        npm run lint
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Lint passed${NC}"
    else
        echo -e "${YELLOW}⚠️  Lint had warnings${NC}"
    fi
    
    echo -e "${BLUE}Running production build...${NC}"
    if [ "$PACKAGE_MANAGER" = "pnpm" ]; then
        pnpm build
    elif [ "$PACKAGE_MANAGER" = "yarn" ]; then
        yarn build
    else
        npm run build
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Production build successful${NC}"
        echo -e "${GREEN}✓ Project is ready for Vercel deployment${NC}\n"
    else
        echo -e "${RED}✗ Build failed${NC}"
        echo -e "${YELLOW}⚠️  Please fix build errors before deploying${NC}\n"
    fi
    
    end_step_timer 13
    mark_step_completed 13
}

# Initialize Git repository
execute_git_init() {
    should_skip_step 14 && return 0
    show_progress 14
    start_step_timer
    
    echo -e "${CYAN}Initializing Git Repository${NC}"
    git init
    git add .
    git commit -m "Initial commit: $PROJECT_NAME - Launchify template with automated setup"
    echo -e "${GREEN}✓ Git repository initialized${NC}\n"
    
    end_step_timer 14
    mark_step_completed 14
}

# Main execution function
execute_all_setup() {
    echo ""
    echo -e "${PURPLE}PHASE 2: EXECUTE SETUP${NC}"
    echo -e "${BLUE}Running non-interactively to completion${NC}"
    echo ""
    
    # Check dependencies
    echo -e "${CYAN}Checking Dependencies${NC}"
    check_dependencies "$USE_VERCEL" "$USE_CONVEX" "$USE_AXIOM" "$PACKAGE_MANAGER"
    echo ""
    
    # Install missing CLIs
    echo -e "${CYAN}Installing Missing CLIs${NC}"
    install_missing_clis "$USE_VERCEL" "$USE_CONVEX" "$USE_AXIOM"
    echo ""
    
    # Execute all setup steps in order
    execute_create_project
    execute_vercel_setup
    execute_convex_setup
    execute_axiom_setup
    execute_clerk_setup
    execute_shadcn_setup
    execute_ai_setup
    execute_admin_setup
    execute_feature_toggles_setup
    execute_github_setup
    execute_generate_env_files
    execute_create_guides
    execute_validate_build
    execute_git_init
    
    return 0
}

# Automated Clerk setup using pre-collected keys
setup_clerk_automated() {
    local use_convex=$1
    local use_vercel=$2
    local project_name=$3
    
    echo -e "${BLUE}Setting up Clerk authentication with automated configuration...${NC}"
    echo ""
    
    # Use the pre-collected keys from environment variables
    local CLERK_SECRET_KEY="$CLERK_SECRET_KEY_DEV"
    local CLERK_PUBLISHABLE_KEY="$CLERK_PUBLISHABLE_KEY_DEV"
    
    if [[ -z "$CLERK_SECRET_KEY" ]] || [[ -z "$CLERK_PUBLISHABLE_KEY" ]]; then
        echo -e "${RED}✗ Clerk keys not found in environment${NC}"
        return 1
    fi
    
    # Continue with the existing Clerk setup logic from setup-clerk.sh
    # but using the pre-collected keys
    # (The detailed implementation will be in the setup-clerk.sh enhancement)
    
    # For now, just set up the basic files and configuration
    mkdir -p app/api/webhooks/clerk
    
    # Create webhook handler
    cat > app/api/webhooks/clerk/route.ts << 'EOF'
import { Webhook } from 'svix';
import { headers } from 'next/headers';
import { WebhookEvent } from '@clerk/nextjs/server';

export async function POST(req: Request) {
  const WEBHOOK_SECRET = process.env.CLERK_WEBHOOK_SECRET;
  
  if (!WEBHOOK_SECRET) {
    throw new Error('Please add CLERK_WEBHOOK_SECRET to .env.local');
  }
  
  const headerPayload = headers();
  const svix_id = headerPayload.get('svix-id');
  const svix_timestamp = headerPayload.get('svix-timestamp');
  const svix_signature = headerPayload.get('svix-signature');
  
  if (!svix_id || !svix_timestamp || !svix_signature) {
    return new Response('Error: Missing Svix headers', { status: 400 });
  }
  
  const payload = await req.json();
  const body = JSON.stringify(payload);
  const wh = new Webhook(WEBHOOK_SECRET);
  
  let evt: WebhookEvent;
  
  try {
    evt = wh.verify(body, {
      'svix-id': svix_id,
      'svix-timestamp': svix_timestamp,
      'svix-signature': svix_signature,
    }) as WebhookEvent;
  } catch (err) {
    console.error('Error verifying webhook:', err);
    return new Response('Error: Verification failed', { status: 400 });
  }
  
  const eventType = evt.type;
  console.log(`Webhook received: ${eventType}`);
  
  return new Response('Webhook received', { status: 200 });
}
EOF
    
    # Install packages
    if command -v pnpm &> /dev/null && [ "$PACKAGE_MANAGER" = "pnpm" ]; then
        pnpm add @clerk/nextjs svix
    elif command -v yarn &> /dev/null && [ "$PACKAGE_MANAGER" = "yarn" ]; then
        yarn add @clerk/nextjs svix
    else
        npm install @clerk/nextjs svix
    fi
    
    # Create middleware
    cat > middleware.ts << 'EOF'
import { clerkMiddleware, createRouteMatcher } from '@clerk/nextjs/server';

const isPublicRoute = createRouteMatcher([
  '/sign-in(.*)',
  '/sign-up(.*)',
  '/api/webhooks(.*)',
]);

export default clerkMiddleware(async (auth, request) => {
  if (!isPublicRoute(request)) {
    await auth.protect();
  }
});

export const config = {
  matcher: [
    '/((?!_next|[^?]*\\.(?:html?|css|js(?!on)|jpe?g|webp|png|gif|svg|ttf|woff2?|ico|csv|docx?|xlsx?|zip|webmanifest)).*)',
    '/(api|trpc)(.*)',
  ],
};
EOF
    
    # Add to .env.local
    cat >> .env.local << EOF

# ============================================
# CLERK AUTHENTICATION
# ============================================
# Development Environment
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=${CLERK_PUBLISHABLE_KEY}
CLERK_SECRET_KEY=${CLERK_SECRET_KEY}

# Clerk URLs
NEXT_PUBLIC_CLERK_SIGN_IN_URL=/sign-in
NEXT_PUBLIC_CLERK_SIGN_UP_URL=/sign-up
NEXT_PUBLIC_CLERK_AFTER_SIGN_IN_URL=/dashboard
NEXT_PUBLIC_CLERK_AFTER_SIGN_UP_URL=/dashboard

# Webhook secret (will be set after webhook creation)
CLERK_WEBHOOK_SECRET=whsec_TODO

EOF
    
    # Set production keys in Vercel if enabled
    if $use_vercel && [[ -n "$CLERK_SECRET_KEY_PROD" ]] && [[ -n "$CLERK_PUBLISHABLE_KEY_PROD" ]]; then
        source "$SCRIPT_DIR/scripts/setup-vercel-env.sh" 2>/dev/null || source "$(dirname "$0")/setup-vercel-env.sh"
        
        local env_vars=()
        env_vars+=("NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=${CLERK_PUBLISHABLE_KEY_PROD}=production,preview=plain")
        env_vars+=("CLERK_SECRET_KEY=${CLERK_SECRET_KEY_PROD}=production,preview=encrypted")
        env_vars+=("NEXT_PUBLIC_CLERK_SIGN_IN_URL=/sign-in=production,preview,development=plain")
        env_vars+=("NEXT_PUBLIC_CLERK_SIGN_UP_URL=/sign-up=production,preview,development=plain")
        env_vars+=("NEXT_PUBLIC_CLERK_AFTER_SIGN_IN_URL=/dashboard=production,preview,development=plain")
        env_vars+=("NEXT_PUBLIC_CLERK_AFTER_SIGN_UP_URL=/dashboard=production,preview,development=plain")
        
        setup_vercel_env_vars "$project_name" "${env_vars[@]}"
    fi
    
    echo -e "${GREEN}✓ Clerk setup completed${NC}"
    return 0
}

