# Service Setup: Clerk Authentication

## When to Suggest This

**Suggest Clerk when user mentions:**
- "Add login" or "user accounts"
- "Authentication" or "sign up"
- "Users need to log in"
- "Protect this page" or "only for logged-in users"
- "User profiles" or "user settings"

**Proactively suggest when:**
- User creates features that should be user-specific (dashboards, profiles)
- User asks about saving user data
- User wants to deploy an app with protected content

## What is Clerk? (ELI5)

```
"Clerk handles user accounts for your app. It lets people:
- Sign up with email or social accounts (Google, GitHub, etc.)
- Log in and out
- Have their own profile and settings
- Access protected pages

Think of it like the login system you see on apps like Twitter or Facebook,
but you don't have to build it yourself."
```

## Setup Process

### Step 1: Explain What User Gets

```
"I'll add user authentication with Clerk. This gives you:

✅ What's included:
- Email + password login
- Social login (Google, GitHub, etc.)
- User profiles and management
- Password reset functionality
- Free up to 10,000 users

⚠️ Setup requires:
- Free Clerk account signup (~1 minute)
- API keys from dashboard
- Takes about 10 minutes total

Sound good?"
```

### Step 2: Install Package

**After user confirms, YOU run:**

```bash
npm install @clerk/nextjs
```

**Tell user:**
```
"Installing Clerk... This will take about 30 seconds."
```

### Step 3: Guide User to Get API Keys

```
"Now let's get your API keys:

1. Go to: https://clerk.com
2. Click 'Start Building For Free'
3. Sign up (use GitHub for fastest)
4. Create a new application
   - Name it: [your-app-name]
   - Choose: Email + Google (you can add more later)
5. Click 'Create Application'

Done that? You should see a screen with API keys..."
```

### Step 4: Get Keys from Dashboard

```
"On the API Keys page, you should see:
- Publishable Key (starts with pk_test_...)
- Secret Key (starts with sk_test_...)

Copy both of these. I'll add them to your project now..."
```

### Step 5: YOU Create .env.local

**YOU create/update the file:**

```bash
# Read existing .env.local if it exists
cat .env.local 2>/dev/null || echo "# Creating new .env.local"
```

**YOU write:**

```
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=[user provides this]
CLERK_SECRET_KEY=[user provides this]
```

**Tell user:**
```
"Paste your Publishable Key when I prompt you:
[Wait for input]

Great! Now paste your Secret Key:
[Wait for input]

Perfect! Keys saved securely."
```

### Step 6: YOU Configure Clerk

**YOU create middleware.ts:**

```typescript
import { clerkMiddleware } from '@clerk/nextjs/server';

export default clerkMiddleware();

export const config = {
  matcher: [
    '/((?!_next|[^?]*\\.(?:html?|css|js(?!on)|jpe?g|webp|png|gif|svg|ttf|woff2?|ico|csv|docx?|xlsx?|zip|webmanifest)).*)',
    '/(api|trpc)(.*)',
  ],
};
```

**YOU update app/layout.tsx:**

```typescript
import { ClerkProvider } from '@clerk/nextjs'

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <ClerkProvider>
      <html lang="en">
        <body>{children}</body>
      </html>
    </ClerkProvider>
  )
}
```

### Step 7: YOU Create Sign In/Up Pages

**YOU create app/sign-in/[[...sign-in]]/page.tsx:**

```typescript
import { SignIn } from '@clerk/nextjs'

export default function SignInPage() {
  return (
    <div className="flex min-h-screen items-center justify-center">
      <SignIn />
    </div>
  )
}
```

**YOU create app/sign-up/[[...sign-up]]/page.tsx:**

```typescript
import { SignUp } from '@clerk/nextjs'

export default function SignUpPage() {
  return (
    <div className="flex min-h-screen items-center justify-center">
      <SignUp />
    </div>
  )
}
```

### Step 8: YOU Update .env.local with Routes

**YOU add to .env.local:**

```
NEXT_PUBLIC_CLERK_SIGN_IN_URL=/sign-in
NEXT_PUBLIC_CLERK_SIGN_UP_URL=/sign-up
NEXT_PUBLIC_CLERK_AFTER_SIGN_IN_URL=/dashboard
NEXT_PUBLIC_CLERK_AFTER_SIGN_UP_URL=/dashboard
```

### Step 9: YOU Create Protected Dashboard Example

**YOU create app/dashboard/page.tsx:**

```typescript
import { auth } from '@clerk/nextjs/server'
import { UserButton } from '@clerk/nextjs'
import { redirect } from 'next/navigation'

export default async function DashboardPage() {
  const { userId } = await auth()

  if (!userId) {
    redirect('/sign-in')
  }

  return (
    <div className="p-8">
      <div className="flex justify-between items-center mb-8">
        <h1 className="text-3xl font-bold">Dashboard</h1>
        <UserButton />
      </div>
      <p>Welcome! This page is protected - only logged-in users can see it.</p>
    </div>
  )
}
```

### Step 10: YOU Test It

**YOU run:**

```bash
npm run dev
```

**Then tell user:**

```
"Testing Clerk setup... Your dev server is running.

Go to: http://localhost:3000/sign-in

You should see a login page. Try:
1. Click 'Sign up'
2. Create an account
3. You'll be redirected to /dashboard

Does it work? Let me know what you see!"
```

## Common Use Cases

### Protecting a Page

**User asks:** "Make this page require login"

**YOU add to the page:**

```typescript
import { auth } from '@clerk/nextjs/server'
import { redirect } from 'next/navigation'

export default async function ProtectedPage() {
  const { userId } = await auth()

  if (!userId) {
    redirect('/sign-in')
  }

  return (
    // Page content here
  )
}
```

### Getting User Info

**User asks:** "Show the user's name"

**YOU update component:**

```typescript
import { currentUser } from '@clerk/nextjs/server'

export default async function ProfilePage() {
  const user = await currentUser()

  return (
    <div>
      <h1>Welcome, {user?.firstName}!</h1>
      <p>Email: {user?.emailAddresses[0]?.emailAddress}</p>
    </div>
  )
}
```

### Adding User Button

**User asks:** "Add a logout button"

**YOU add:**

```typescript
import { UserButton } from '@clerk/nextjs'

export default function Header() {
  return (
    <header>
      <nav>
        <UserButton />
      </nav>
    </header>
  )
}
```

## Common Issues

### "Clerk: Missing publishableKey"

**YOU check:**

```bash
cat .env.local | grep CLERK
```

**If missing, tell user:**

```
"Your Clerk API keys aren't loaded. Let me check...

The .env.local file is missing keys. Can you provide:
1. Your Publishable Key (pk_test_...)
2. Your Secret Key (sk_test_...)"
```

**YOU add them and restart dev server:**

```bash
npm run dev
```

### "redirect_uri mismatch"

**YOU check Clerk dashboard settings and tell user:**

```
"The redirect URLs need updating in Clerk:

1. Go to Clerk dashboard
2. Your application → Paths
3. Add these paths:
   - Sign-in URL: /sign-in
   - Sign-up URL: /sign-up
   - Home URL: /
   - After sign-in: /dashboard
   - After sign-up: /dashboard

Save and try again."
```

## For Deployment (Vercel)

**When deploying, YOU tell user:**

```
"For Clerk to work on Vercel, we need to add environment variables:

In Vercel dashboard:
1. Your project → Settings → Environment Variables
2. Add:
   - NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY = [your key]
   - CLERK_SECRET_KEY = [your key]
3. Save
4. Redeploy

I'll push the code changes now..."
```

**YOU run:**

```bash
git add .
git commit -m "Add Clerk authentication"
git push
```

## Customization Options

If user wants to customize:

### Change Theme

**YOU update provider:**

```typescript
<ClerkProvider appearance={{
  variables: { colorPrimary: '#0066cc' }
}}>
```

### Add More Social Providers

**Tell user:**

```
"To add more login options (Facebook, Twitter, etc.):

1. Clerk dashboard → User & Authentication → Social Connections
2. Enable the providers you want
3. Follow Clerk's setup for each (they provide instructions)
4. That's it - they'll appear automatically!"
```

## Summary for AI

**When user needs authentication:**
1. Explain what Clerk does in simple terms
2. Ask permission
3. **YOU run `npm install @clerk/nextjs`**
4. Guide user to get API keys
5. **YOU create all config files**
6. **YOU create sign-in/up pages**
7. **YOU test it**
8. Show user how it works

**User's role:** Sign up, get keys, test the login
**Your role:** Install, configure, test, verify

**NO SCRIPTS for users** - you do all terminal work.
