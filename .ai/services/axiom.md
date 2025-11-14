# Service Setup: Axiom Logging

## When to Suggest This

**Suggest Axiom when user mentions:**
- "Track errors" or "see what's broken"
- "Monitor my app" or "see what users are doing"
- App is deployed to production
- User reports bugs but can't reproduce them
- "Analytics" or "logging"

**Proactively suggest when:**
- User deploys to Vercel for the first time
- User has production users
- User mentions "I don't know why X is happening"

## What is Axiom? (ELI5)

```
"Axiom is like a security camera for your app, but for code.

It records:
- Every error that happens
- What users are doing (page views, clicks)
- How fast pages load
- API calls and responses

When something breaks, you can 'replay' what happened
to understand and fix it.

It's free with 500 GB/month (plenty for most apps)."
```

## Setup Process

### Step 1: Explain to User

```
"I'll add Axiom to track errors and user activity. This helps:

✅ What you get:
- See all errors in one dashboard
- Track user behavior and flows
- Monitor app performance
- Debug production issues easily
- Free tier: 500 GB/month

⚠️ Setup requires:
- Free Axiom account (1 minute)
- API token from dashboard
- Takes about 5 minutes

This is especially useful now that your app is live.
Sound good?"
```

### Step 2: Install Axiom

**After user confirms, YOU run:**

```bash
npm install next-axiom
```

**Tell user:**
```
"Installing Axiom integration..."
```

### Step 3: Guide User to Get API Token

```
"Let's get your Axiom API token:

1. Go to: https://axiom.co
2. Click 'Sign Up' → Use GitHub (fastest)
3. Create a new dataset:
   - Click 'Datasets' → 'New Dataset'
   - Name it: [your-app-name]-logs
   - Click 'Create'
4. Get your API token:
   - Click Settings → API Tokens
   - Click 'New Token'
   - Name: 'Next.js App'
   - Permissions: 'Ingest'
   - Click 'Create'
5. Copy the token

Got it? Paste it when I prompt you..."
```

### Step 4: YOU Add to .env.local

**YOU update .env.local:**

```bash
cat >> .env.local << 'EOF'

# Axiom
NEXT_PUBLIC_AXIOM_DATASET=[dataset-name]
NEXT_PUBLIC_AXIOM_TOKEN=[user-provides-token]
EOF
```

**Prompt user for values:**

```
"What's your dataset name? (the one you created)
[Wait for input]

Now paste your API token:
[Wait for input]

Perfect! Saved securely."
```

### Step 5: YOU Configure Next.js

**YOU update next.config.js:**

```javascript
const { withAxiom } = require('next-axiom');

module.exports = withAxiom({
  // your existing config
});
```

### Step 6: YOU Add Logger Utility

**YOU create lib/logger.ts:**

```typescript
import { Logger } from 'next-axiom';

export const log = new Logger();

// Helper functions
export const logError = (error: Error, context?: Record<string, any>) => {
  log.error('Application error', {
    error: error.message,
    stack: error.stack,
    ...context,
  });
};

export const logPageView = (path: string, userId?: string) => {
  log.info('Page view', { path, userId });
};

export const logUserAction = (action: string, details?: Record<string, any>) => {
  log.info('User action', { action, ...details });
};
```

### Step 7: YOU Add Error Boundary

**YOU create components/ErrorBoundary.tsx:**

```typescript
'use client';

import { Component, ReactNode } from 'react';
import { logError } from '@/lib/logger';

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
}

interface State {
  hasError: boolean;
}

export class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError() {
    return { hasError: true };
  }

  componentDidCatch(error: Error, errorInfo: any) {
    logError(error, {
      componentStack: errorInfo.componentStack,
    });
  }

  render() {
    if (this.state.hasError) {
      return (
        this.props.fallback || (
          <div className="p-8 text-center">
            <h2 className="text-2xl font-bold mb-2">Something went wrong</h2>
            <p>We've been notified and are looking into it.</p>
            <button
              onClick={() => this.setState({ hasError: false })}
              className="mt-4 px-4 py-2 bg-blue-500 text-white rounded"
            >
              Try again
            </button>
          </div>
        )
      );
    }

    return this.props.children;
  }
}
```

### Step 8: YOU Update Root Layout

**YOU update app/layout.tsx:**

```typescript
import { AxiomWebVitals } from 'next-axiom';
import { ErrorBoundary } from '@/components/ErrorBoundary';

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <ErrorBoundary>
          {children}
        </ErrorBoundary>
        <AxiomWebVitals />
      </body>
    </html>
  );
}
```

### Step 9: YOU Add API Route Logging

**YOU create middleware to log API calls:**

**YOU update or create middleware.ts:**

```typescript
import { Logger } from 'next-axiom';
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export async function middleware(request: NextRequest) {
  const logger = new Logger({ source: 'middleware' });

  logger.info('Request', {
    path: request.nextUrl.pathname,
    method: request.method,
    userAgent: request.headers.get('user-agent'),
  });

  const response = NextResponse.next();

  await logger.flush();
  return response;
}

export const config = {
  matcher: ['/api/:path*', '/((?!_next/static|_next/image|favicon.ico).*)'],
};
```

### Step 10: YOU Test It

**YOU run dev server:**

```bash
npm run dev
```

**YOU trigger a test error:**

**YOU create app/api/test-error/route.ts:**

```typescript
import { log } from '@/lib/logger';
import { NextResponse } from 'next/server';

export async function GET() {
  try {
    log.info('Test endpoint called');

    // Intentional error for testing
    throw new Error('Test error - Axiom logging works!');
  } catch (error) {
    log.error('Test error caught', { error: error.message });
    await log.flush();

    return NextResponse.json({ error: 'Test error logged' }, { status: 500 });
  }
}
```

**Tell user:**

```
"Testing Axiom... I've added a test endpoint.

Go to: http://localhost:3000/api/test-error

This will trigger an error. Then:
1. Go to https://axiom.co
2. Open your dataset: [dataset-name]-logs
3. You should see the error logged!

See it? If yes, Axiom is working!"
```

## Common Use Cases

### Log Form Submissions

```typescript
'use client';

import { logUserAction } from '@/lib/logger';

export default function ContactForm() {
  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();

    logUserAction('form_submitted', {
      form: 'contact',
      timestamp: Date.now(),
    });

    // ... rest of form handling
  };
}
```

### Log User Flows

```typescript
'use client';

import { logPageView } from '@/lib/logger';
import { useEffect } from 'react';
import { usePathname } from 'next/navigation';

export function PageViewLogger() {
  const pathname = usePathname();

  useEffect(() => {
    logPageView(pathname);
  }, [pathname]);

  return null;
}
```

### Log API Errors

```typescript
import { log } from '@/lib/logger';

export async function POST(request: Request) {
  try {
    // ... your logic
  } catch (error) {
    log.error('API error', {
      endpoint: '/api/users',
      error: error.message,
      stack: error.stack,
    });

    await log.flush();

    return NextResponse.json({ error: 'Internal error' }, { status: 500 });
  }
}
```

## For Deployment (Vercel)

**When deploying, YOU tell user:**

```
"For Axiom to work on Vercel:

In Vercel dashboard:
1. Project → Settings → Environment Variables
2. Add:
   NEXT_PUBLIC_AXIOM_DATASET = [your-dataset-name]
   NEXT_PUBLIC_AXIOM_TOKEN = [your-token]
3. Save
4. Redeploy

I'll push the code now..."
```

**YOU run:**

```bash
git add .
git commit -m "Add Axiom logging"
git push
```

## Viewing Logs

**Tell user how to use Axiom:**

```
"To view your logs:

1. Go to https://axiom.co
2. Click your dataset: [dataset-name]
3. You'll see all logs in real-time

Useful queries:
- Filter by level: level:error (shows only errors)
- Search text: "user clicked button"
- Time range: Last hour, Last day, etc.

You can set up alerts too:
- Settings → Monitors → New Monitor
- Example: Alert me when error count > 10/hour
```

## Common Issues

### Logs Not Appearing

**YOU check:**

```bash
# Verify .env.local has values
cat .env.local | grep AXIOM

# Verify package installed
npm list next-axiom
```

**If missing, YOU fix it:**

```bash
npm install next-axiom
```

### "AXIOM_TOKEN not found"

**YOU verify environment variables are set:**

```bash
cat .env.local
```

**Tell user to restart dev server if needed.**

## Summary for AI

**When user needs logging/monitoring:**
1. Explain Axiom (security camera for code)
2. Ask permission
3. **YOU run `npm install next-axiom`**
4. Guide user to get API token
5. **YOU configure next.config.js**
6. **YOU add logger utility**
7. **YOU add error boundary**
8. **YOU test with error endpoint**

**User's role:** Sign up, get token, view logs
**Your role:** Install, configure, add logging, test

**NO SCRIPTS for users** - you handle everything
