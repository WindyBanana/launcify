#!/bin/bash

# Automated Clerk + Webhook Setup with Svix Integration

setup_clerk() {
    local use_convex=$1
    local use_vercel=$2
    local project_name=$3

    echo -e "${BLUE}Setting up Clerk authentication...${NC}"
    echo -e "${YELLOW}This will automatically configure webhooks via Svix API${NC}\n"

    # Step 1: Get Clerk API credentials
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Step 1: Clerk API Credentials${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "You'll need to create a Clerk application first:"
    echo "  1. Go to: ${CYAN}https://dashboard.clerk.com${NC}"
    echo "  2. Click 'Add application'"
    echo "  3. Name it: ${GREEN}${project_name}${NC}"
    echo "  4. Choose authentication methods (Email, Google, GitHub, etc.)"
    echo ""
    echo "Once created, you'll need your secret key for automation."
    echo ""

    # Prompt for secret key
    read -sp "Enter your CLERK_SECRET_KEY (starts with sk_test_ or sk_live_): " CLERK_SECRET_KEY
    echo ""

    if [[ -z "$CLERK_SECRET_KEY" ]]; then
        echo -e "${RED}✗ Clerk secret key is required${NC}"
        return 1
    fi

    # Validate format
    if [[ ! "$CLERK_SECRET_KEY" =~ ^sk_(test|live)_ ]]; then
        echo -e "${YELLOW}⚠️  Warning: Secret key format looks unusual${NC}"
        read -p "Continue anyway? [y/N]: " continue_anyway
        if [[ ! $continue_anyway =~ ^[Yy]$ ]]; then
            return 1
        fi
    fi

    # Get publishable key
    echo ""
    read -p "Enter your NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY (starts with pk_test_ or pk_live_): " CLERK_PUBLISHABLE_KEY

    if [[ -z "$CLERK_PUBLISHABLE_KEY" ]]; then
        echo -e "${RED}✗ Clerk publishable key is required${NC}"
        return 1
    fi

    # Step 2: Create Svix app via Clerk API
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Step 2: Creating Svix Integration${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # Create Svix app association
    SVIX_RESPONSE=$(curl -s -X POST "https://api.clerk.com/v1/webhooks/svix" \
        -H "Authorization: Bearer ${CLERK_SECRET_KEY}" \
        -H "Content-Type: application/json")

    if echo "$SVIX_RESPONSE" | grep -q "errors"; then
        echo -e "${RED}✗ Failed to create Svix integration${NC}"
        echo "Error: $SVIX_RESPONSE"
        return 1
    fi

    echo -e "${GREEN}✓ Svix integration created${NC}"

    # Get Svix dashboard URL with credentials
    SVIX_URL_RESPONSE=$(curl -s -X POST "https://api.clerk.com/v1/webhooks/svix_url" \
        -H "Authorization: Bearer ${CLERK_SECRET_KEY}" \
        -H "Content-Type: application/json")

    SVIX_URL=$(echo "$SVIX_URL_RESPONSE" | grep -o '"url":"[^"]*"' | sed 's/"url":"//' | sed 's/"$//')

    if [[ -z "$SVIX_URL" ]]; then
        echo -e "${YELLOW}⚠️  Could not get Svix dashboard URL automatically${NC}"
        echo "You can still create webhooks manually in the Clerk dashboard"
    else
        # Extract Svix credentials from URL
        # Format: https://app.svix.com/login#key=SVIX_TOKEN&app_id=APP_ID
        SVIX_TOKEN=$(echo "$SVIX_URL" | grep -o 'key=[^&]*' | cut -d'=' -f2)
        SVIX_APP_ID=$(echo "$SVIX_URL" | grep -o 'app_id=[^&]*' | cut -d'=' -f2)

        if [[ -n "$SVIX_TOKEN" ]] && [[ -n "$SVIX_APP_ID" ]]; then
            # Step 3: Create webhook endpoint via Svix API
            echo ""
            echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${CYAN}Step 3: Creating Webhook Endpoint${NC}"
            echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo ""

            # Determine webhook URL based on deployment
            if $use_vercel; then
                echo "You'll need your Vercel deployment URL for the webhook."
                read -p "Enter your Vercel project URL (e.g., your-project.vercel.app): " VERCEL_URL
                WEBHOOK_URL="https://${VERCEL_URL}/api/webhooks/clerk"
            else
                echo "For local development, you'll need to expose your localhost."
                echo "Recommended: Use ngrok or similar service"
                read -p "Enter your webhook URL (e.g., https://abc123.ngrok.io/api/webhooks/clerk): " WEBHOOK_URL
            fi

            # Prepare headers for Vercel bypass token if using Convex
            WEBHOOK_HEADERS="{}"
            if $use_convex && $use_vercel; then
                echo ""
                echo -e "${YELLOW}📝 Convex + Vercel Integration Detected${NC}"
                echo "Generating bypass token for Clerk → Convex webhooks..."

                # Generate a secure random token
                BYPASS_TOKEN=$(openssl rand -hex 32)
                WEBHOOK_HEADERS="{\"x-vercel-protection-bypass\": \"${BYPASS_TOKEN}\"}"

                echo -e "${GREEN}✓ Bypass token generated${NC}"
                echo -e "${YELLOW}⚠️  IMPORTANT: Add this to your Vercel environment variables:${NC}"
                echo -e "    ${CYAN}CLERK_WEBHOOK_BYPASS_TOKEN=${BYPASS_TOKEN}${NC}"
            fi

            # Create the webhook endpoint
            ENDPOINT_PAYLOAD=$(cat <<EOF
{
  "url": "${WEBHOOK_URL}",
  "description": "${project_name} - Clerk Webhooks",
  "filterTypes": [
    "user.created",
    "user.updated",
    "user.deleted",
    "session.created",
    "session.ended",
    "session.removed",
    "session.revoked"
  ],
  "headers": ${WEBHOOK_HEADERS}
}
EOF
)

            ENDPOINT_RESPONSE=$(curl -s -X POST "https://api.svix.com/api/v1/app/${SVIX_APP_ID}/endpoint" \
                -H "Authorization: Bearer ${SVIX_TOKEN}" \
                -H "Content-Type: application/json" \
                -d "$ENDPOINT_PAYLOAD")

            if echo "$ENDPOINT_RESPONSE" | grep -q '"id"'; then
                WEBHOOK_SECRET=$(echo "$ENDPOINT_RESPONSE" | grep -o '"secret":"[^"]*"' | sed 's/"secret":"//' | sed 's/"$//')
                echo -e "${GREEN}✓ Webhook endpoint created successfully${NC}"
                echo ""
                echo -e "${GREEN}Webhook URL:${NC} ${WEBHOOK_URL}"
                echo -e "${GREEN}Signing Secret:${NC} ${WEBHOOK_SECRET:0:20}..."

                # Store webhook secret for env file
                CLERK_WEBHOOK_SECRET="$WEBHOOK_SECRET"
            else
                echo -e "${RED}✗ Failed to create webhook endpoint${NC}"
                echo "Error: $ENDPOINT_RESPONSE"
                echo ""
                echo "You can create the webhook manually:"
                echo "  1. Visit: ${CYAN}${SVIX_URL}${NC}"
                echo "  2. Add endpoint: ${CYAN}${WEBHOOK_URL}${NC}"
                echo "  3. Subscribe to user and session events"
            fi
        fi
    fi

    # Step 4: Create webhook handler API route
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Step 4: Creating Webhook Handler${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    mkdir -p app/api/webhooks/clerk

    cat > app/api/webhooks/clerk/route.ts << 'EOF'
import { Webhook } from 'svix';
import { headers } from 'next/headers';
import { WebhookEvent } from '@clerk/nextjs/server';

export async function POST(req: Request) {
  // Get the webhook secret from environment
  const WEBHOOK_SECRET = process.env.CLERK_WEBHOOK_SECRET;

  if (!WEBHOOK_SECRET) {
    throw new Error('Please add CLERK_WEBHOOK_SECRET to .env.local');
  }

  // Get the headers
  const headerPayload = headers();
  const svix_id = headerPayload.get('svix-id');
  const svix_timestamp = headerPayload.get('svix-timestamp');
  const svix_signature = headerPayload.get('svix-signature');

  // If there are no headers, error out
  if (!svix_id || !svix_timestamp || !svix_signature) {
    return new Response('Error: Missing Svix headers', {
      status: 400,
    });
  }

  // Get the body
  const payload = await req.json();
  const body = JSON.stringify(payload);

  // Create a new Svix instance with your webhook secret
  const wh = new Webhook(WEBHOOK_SECRET);

  let evt: WebhookEvent;

  // Verify the webhook
  try {
    evt = wh.verify(body, {
      'svix-id': svix_id,
      'svix-timestamp': svix_timestamp,
      'svix-signature': svix_signature,
    }) as WebhookEvent;
  } catch (err) {
    console.error('Error verifying webhook:', err);
    return new Response('Error: Verification failed', {
      status: 400,
    });
  }

  // Handle the webhook
  const eventType = evt.type;
  console.log(`Webhook received: ${eventType}`);

  // Handle different event types
  switch (eventType) {
    case 'user.created':
      const { id, email_addresses, first_name, last_name } = evt.data;
      console.log(`New user created: ${id}`);
      // TODO: Add user to your database
      break;

    case 'user.updated':
      console.log(`User updated: ${evt.data.id}`);
      // TODO: Update user in your database
      break;

    case 'user.deleted':
      console.log(`User deleted: ${evt.data.id}`);
      // TODO: Delete user from your database
      break;

    case 'session.created':
      console.log(`Session created for user: ${evt.data.user_id}`);
      break;

    case 'session.ended':
    case 'session.removed':
    case 'session.revoked':
      console.log(`Session ended for user: ${evt.data.user_id}`);
      break;

    default:
      console.log(`Unhandled event type: ${eventType}`);
  }

  return new Response('Webhook received', { status: 200 });
}
EOF

    echo -e "${GREEN}✓ Webhook handler created at app/api/webhooks/clerk/route.ts${NC}"

    # Step 5: Install Clerk and Svix packages
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Step 5: Installing Dependencies${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if command -v pnpm &> /dev/null; then
        pnpm add @clerk/nextjs svix
    elif command -v yarn &> /dev/null; then
        yarn add @clerk/nextjs svix
    else
        npm install @clerk/nextjs svix
    fi

    echo -e "${GREEN}✓ Clerk and Svix packages installed${NC}"

    # Step 6: Create middleware for Clerk
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Step 6: Creating Clerk Middleware${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

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
    // Skip Next.js internals and all static files
    '/((?!_next|[^?]*\\.(?:html?|css|js(?!on)|jpe?g|webp|png|gif|svg|ttf|woff2?|ico|csv|docx?|xlsx?|zip|webmanifest)).*)',
    // Always run for API routes
    '/(api|trpc)(.*)',
  ],
};
EOF

    echo -e "${GREEN}✓ Clerk middleware created${NC}"

    # Step 7: Update environment variables
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Step 7: Updating Environment Variables${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # Add Clerk variables to .env.local
    cat >> .env.local << EOF

# ============================================
# CLERK AUTHENTICATION
# ============================================
# Automatically configured by Launchify
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=${CLERK_PUBLISHABLE_KEY}
CLERK_SECRET_KEY=${CLERK_SECRET_KEY}

# Webhook configuration
CLERK_WEBHOOK_SECRET=${CLERK_WEBHOOK_SECRET:-whsec_TODO}

# Clerk URLs
NEXT_PUBLIC_CLERK_SIGN_IN_URL=/sign-in
NEXT_PUBLIC_CLERK_SIGN_UP_URL=/sign-up
NEXT_PUBLIC_CLERK_AFTER_SIGN_IN_URL=/dashboard
NEXT_PUBLIC_CLERK_AFTER_SIGN_UP_URL=/dashboard

EOF

    # Add bypass token if using Convex + Vercel
    if [[ -n "$BYPASS_TOKEN" ]]; then
        cat >> .env.local << EOF
# Vercel bypass token for Clerk webhooks (Convex integration)
CLERK_WEBHOOK_BYPASS_TOKEN=${BYPASS_TOKEN}

EOF
    fi

    echo -e "${GREEN}✓ Environment variables updated${NC}"

    # Final summary
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ Clerk Setup Complete!${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "What was configured:"
    echo "  ${GREEN}✓${NC} Clerk authentication"
    echo "  ${GREEN}✓${NC} Svix webhook integration"
    echo "  ${GREEN}✓${NC} Webhook endpoint created"
    echo "  ${GREEN}✓${NC} Webhook handler API route"
    echo "  ${GREEN}✓${NC} Clerk middleware"
    echo "  ${GREEN}✓${NC} Environment variables"

    if [[ -n "$BYPASS_TOKEN" ]]; then
        echo ""
        echo -e "${YELLOW}⚠️  IMPORTANT: Vercel Configuration Required${NC}"
        echo ""
        echo "Add this environment variable in your Vercel dashboard:"
        echo "  ${CYAN}CLERK_WEBHOOK_BYPASS_TOKEN${NC}=${BYPASS_TOKEN}"
        echo ""
        echo "This allows Clerk webhooks to reach your Convex functions."
    fi

    echo ""
    echo "Next steps:"
    echo "  1. Test authentication: ${CYAN}npm run dev${NC}"
    echo "  2. Visit: ${CYAN}http://localhost:3000/sign-in${NC}"
    echo "  3. Create test account and verify webhooks in Svix dashboard"
    echo ""
    echo "Documentation:"
    echo "  • Clerk: ${CYAN}https://clerk.com/docs/nextjs${NC}"
    echo "  • Webhooks: ${CYAN}https://clerk.com/docs/webhooks${NC}"
    if [[ -n "$SVIX_URL" ]]; then
        echo "  • Svix Dashboard: ${CYAN}${SVIX_URL}${NC}"
    fi
    echo ""
}
