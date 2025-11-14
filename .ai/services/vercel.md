# Service Setup: Vercel Deployment

## When to Suggest This
- User wants to "deploy" or "go live"
- User asks "how do people see my app?"
- User mentions "production" or "launch"

## What is Vercel? (ELI5)

"Vercel is like a home for your website on the internet. Right now your app only lives on your computer. Vercel puts it online so anyone can visit it."

## Prerequisites Check

Before starting, verify:
1. Project has a Next.js app (we're using Next.js 16)
2. Git repository initialized
3. User has a GitHub/GitLab account (or willing to create one)

## Setup Steps

### Step 1: Use Context7
Get current Vercel setup instructions:
```
use context7 for latest Vercel Next.js 16 deployment
```

### Step 2: Explain to User

```
"To put your app online, I recommend Vercel:

✅ What's good:
- Made by the Next.js team (perfect match!)
- Free for personal projects
- Automatic deployments (push code → site updates)
- Fast global hosting

⚠️ What to know:
- Setup takes about 5 minutes
- You'll need to create a free Vercel account
- Your code will be on GitHub (public or private, your choice)

Sound good?"
```

### Step 3: Guide Through Process

**If user agrees:**

```
"Great! Here's what we'll do:

1. First, let's make sure your code is saved to GitHub
2. Then connect Vercel to your GitHub account
3. Vercel will automatically deploy your app
4. You'll get a URL like: your-app.vercel.app

Let me guide you step by step..."
```

### Step 4: GitHub Setup

**YOU check if git remote exists using Bash:**
```bash
git remote -v
```

**If no remote, YOU guide user:**
```
"First, we need to put your code on GitHub:

1. Go to github.com and sign in
2. Click '+' → 'New repository'
3. Name it: [your-project-name]
4. Choose Public or Private (your choice)
5. DON'T initialize with README (we already have code)
6. Click 'Create repository'
7. Copy the repository URL they show you

Got it? Great! I'll connect your code to GitHub now..."
```

**Then YOU run the git commands:**
```bash
git remote add origin [user-provided-url]
git branch -M main
git push -u origin main
```

**If remote exists:**
```
"Great! Your code is already on GitHub. Let's connect Vercel..."
```

### Step 5: Vercel Connection

```
"Now let's deploy:

1. Go to: vercel.com
2. Click 'Sign Up' → 'Continue with GitHub'
3. After signing in, click 'Add New Project'
4. Find your repository: [repo-name]
5. Click 'Import'
6. Vercel will auto-detect Next.js - just click 'Deploy'

It will take 1-2 minutes to deploy...

Let me know when you see 'Congratulations'!"
```

### Step 6: Environment Variables (If Needed)

**If app has .env.local:**
```
"One more step! Your app needs some secret values (like API keys).

In Vercel:
1. Go to your project → Settings → Environment Variables
2. Add these variables:
   [List required env vars from .env.local]

For each one:
- Name: [VAR_NAME]
- Value: [explain where to get it]
- Environment: Production

Then redeploy:
1. Go to Deployments tab
2. Click '...' on latest deployment
3. Click 'Redeploy'

This updates your live site with the secrets."
```

### Step 7: Verify Deployment

```
"Let's check if it works!

Your app is live at: [vercel-url]

Click that link - does it load correctly?

If yes: 🎉 Congratulations! Your app is live on the internet!
If no: Tell me what error you see, I'll help fix it."
```

### Step 8: Explain Automatic Deployments

```
"Cool thing about Vercel: Every time I push code to GitHub,
Vercel automatically updates your live site!

So the workflow is:
1. I make changes to your code
2. I commit and push the changes
3. Vercel detects the push and deploys automatically (takes ~1 min)
4. Your live site updates!

You don't have to do anything - I handle all the git commands.
Pretty neat!"
```

## Common Issues

### Build Fails

**Error:** "Build failed"

**YOU diagnose and fix:**
```
"The deployment hit an error. Let me check what's wrong..."
```

**YOU run diagnostic commands:**
```bash
npm run build  # Check if it builds locally
npm run lint   # Check for code issues
```

**Then explain:**
```
"I found the issue. It's [specific error]. Let me fix it..."

[YOU fix the code, then push the changes]

"Fixed! Vercel should redeploy automatically in about a minute."
```

### Environment Variable Missing

**Error:** "Cannot find module..." or API calls fail

**Explain:**
```
"Your app needs a secret value that we didn't add to Vercel yet.

Go to:
1. Vercel dashboard → Your project → Settings
2. Environment Variables
3. Add: [VAR_NAME]
4. Value: [where to get it]
5. Save
6. Deployments tab → Redeploy

This should fix it!"
```

### Domain Setup (If User Asks)

```
"Want to use your own domain (like myapp.com)?

Vercel makes this easy:
1. Buy a domain (from Namecheap, Google Domains, etc.)
2. In Vercel: Project → Settings → Domains
3. Add your domain: myapp.com
4. Follow Vercel's instructions to point your domain to Vercel
5. Wait 1-24 hours for DNS to update

Then myapp.com will show your site instead of the .vercel.app URL!"
```

## Post-Deployment

After successful deployment, tell user:

```
"✅ Your app is live!

URL: [vercel-url]

What happens now:
- Any code changes → push to GitHub → auto-deploys
- View logs in Vercel dashboard if issues occur
- Free SSL (https) included automatically
- Global CDN (fast everywhere) included

You can share that URL with anyone now! 🎉

Need help with anything else?"
```

## Files to Create (If Needed)

### vercel.json (Optional Optimization)
Only create if user has specific needs:

```json
{
  "$schema": "https://openapi.vercel.sh/vercel.json",
  "buildCommand": "npm run build",
  "devCommand": "npm run dev",
  "installCommand": "npm install",
  "framework": "nextjs",
  "outputDirectory": ".next"
}
```

**When to add:**
- Custom build commands
- Specific Node version needed
- Advanced configurations

**Default:** Usually not needed for Next.js 16 (auto-detected)

## Key Principles

1. **Use context7** - Get latest Vercel deployment practices
2. **Explain simply** - "Home for your website on the internet"
3. **Guide step-by-step** - Don't assume they know GitHub/Vercel
4. **Handle errors gracefully** - Explain common issues clearly
5. **Celebrate success** - Make them feel accomplished!

## Related Services

After Vercel is set up, user might ask about:
- `.ai/services/custom-domain.md` - Adding their own domain
- `.ai/services/analytics.md` - Tracking visitors
- `.ai/services/monitoring.md` - Watching for errors

Remember: User just accomplished something BIG. Be encouraging and celebratory!
