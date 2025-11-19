# 🚨 STRICT RULES: Running Commands (AI Instructions)

## Core Rule

**YOU (the AI) run ALL terminal commands. Users NEVER run commands.**

Use the Bash tool for every command. No exceptions.

## When to Run Commands Immediately (No Permission Needed)

### 1. User Explicitly Requests It

**User says:** "Install X"
**You do:** Immediately run `ppnpm install X` using Bash tool

**User says:** "Start the dev server"
**You do:** Immediately run `ppnpm run dev` using Bash tool

**User says:** "Run tests"
**You do:** Immediately run `ppnpm test` using Bash tool

**User says:** "Set up Context7"
**You do:** Immediately run `ppnpm run setup-context7` using Bash tool

**Rule:** If user directly asks for a command, execute it immediately. Don't ask for permission.

### 2. Diagnostic Commands

When troubleshooting or verifying, run these immediately:

```bash
node --version          # Check Node version
pnpm --version         # Check pnpm version
pwd                    # Check current directory
git status             # Check git status
git remote -v          # Check git remotes
ppnpm list             # Check installed packages
ppnpm run build        # Verify build works
ppnpm run lint         # Check for errors
```

**Rule:** Diagnostic commands are always safe. Run them without asking.

### 3. User's First Interaction

When user opens the project for the first time:

```bash
pnpm install           # Install dependencies immediately
```

**Rule:** First interaction = auto-install dependencies. User expects the project to work.

### 4. After Modifying package.json

If you add dependencies to package.json:

```bash
pnpm install           # Run immediately after saving package.json
```

**Rule:** Dependencies added → install immediately.

## When to Ask Permission First

### 1. Adding New Features That Need Packages

**Scenario:** User says "Add authentication"

**You ask:**
```
"I'll add authentication using Clerk. This will:
- Install the Clerk package (~2MB)
- Add authentication to your app
- Take about 5 minutes

Should I go ahead?"
```

**After user confirms:**
```bash
pnpm install @clerk/nextjs
```

**Rule:** New features with dependencies → explain first, ask permission, then install.

### 2. Large or Paid Services

**Scenario:** User says "Add a database"

**You ask:**
```
"I recommend Convex for your database. This will:
- Install Convex package
- Require you to sign up at convex.dev (free tier available)
- Store data in the cloud

Want me to set this up?"
```

**After user confirms:**
```bash
pnpm install convex
```

**Rule:** Services requiring signup/accounts → explain, ask permission.

### 3. Development vs Production Commands

**Development (safe, ask if unsure):**
```bash
pnpm run dev           # Safe - just starts server
pnpm run build         # Safe - just builds locally
pnpm test              # Safe - runs tests
```

**Production (ask first):**
```bash
git push              # Ask: "Should I push to GitHub?"
npx vercel deploy     # Ask: "Ready to deploy to production?"
pnpm publish           # Ask: "Should I publish this package?"
```

**Rule:** Production commands affect live systems → always ask first.

## Specific Scenarios

### Scenario 1: User Says "Make me a website"

**You do:**
1. Check if dependencies installed: `pnpm list` (run immediately)
2. If not installed: `pnpm install` (run immediately)
3. Start dev server: `pnpm run dev` (run immediately)
4. Create files
5. Tell user: "I've started the dev server. Go to http://localhost:3000"

**No permission needed** - user wants to start, so start everything.

### Scenario 2: User Says "Add a contact form"

**You do:**
1. Create the component files
2. If it needs a package (like react-hook-form):
   - Tell user: "I'll add form validation using react-hook-form. Should I proceed?"
   - Wait for confirmation
   - Run: `pnpm install react-hook-form`
3. Complete the feature
4. Run dev server if not running: `pnpm run dev`

**Ask permission** for new packages, but not for dev server.

### Scenario 3: User Says "It's not working"

**You do:**
1. Run diagnostics immediately:
   ```bash
   pnpm run build
   pnpm run lint
   git status
   ```
2. Identify the issue
3. Fix the code
4. Verify fix: `pnpm run dev`
5. Tell user: "Fixed! Your app should work now."

**No permission needed** - diagnostics and fixes are expected.

### Scenario 4: User Says "Deploy this"

**You ask:**
```
"I'll deploy your app to Vercel. This will:
- Make your app publicly accessible online
- Require a free Vercel account
- Push your code to GitHub first

Ready to proceed?"
```

**After user confirms:**
```bash
git add .
git commit -m "Prepare for deployment"
git push
npx vercel deploy
```

**Ask permission** - deployment is a big step.

### Scenario 5: User Says "Install dependencies"

**You do:**
```bash
pnpm install
```

Immediately. Then tell user: "Dependencies installed!"

**No permission needed** - user explicitly requested it.

### Scenario 6: User Opens Project, Says Anything

**You do:**
1. Check if node_modules exists (using bash: `ls node_modules`)
2. If missing: `pnpm install` immediately
3. Then respond to their request

**No permission needed** - project must be ready to work.

## Command Templates

### Installing a Package

```bash
pnpm install <package-name>
```

**When:** User asks for it OR after you ask permission for a feature

**Example:**
User: "Add Tailwind"
You: "I'll add Tailwind CSS for styling. One moment..."
```bash
pnpm install tailwindcss postcss autoprefixer
```

### Running Dev Server

```bash
pnpm run dev
```

**When:**
- User asks to see the app
- After creating a feature
- After fixing a bug
- Any time user wants to see their app

**Don't ask permission** - just run it.

### Installing Dependencies

```bash
pnpm install
```

**When:**
- First interaction with project
- After modifying package.json
- User explicitly asks
- After cloning/pulling from git

**Don't ask permission** - just run it.

### Running Tests

```bash
pnpm test
```

**When:**
- User asks
- After implementing a feature (if testing mode is "complete")
- After fixing a bug

**Don't ask permission** - just run it.

### Git Commands

```bash
git status              # Check status - run anytime
git add .              # Stage changes - run before commit
git commit -m "msg"    # Commit - run when ready
git push               # Push to remote - ASK FIRST unless user requested
```

**Push to GitHub:** Ask first unless user explicitly said to push.

## Error Handling

If a command fails:

1. **Show user the error** in simple terms
2. **Diagnose the issue** using more commands
3. **Fix it**
4. **Re-run the command**
5. **Verify it worked**

Example:

```bash
pnpm install some-package
# Error: package not found
```

You say:
```
"The package 'some-package' doesn't exist. Did you mean 'somepackage'?
Let me install the correct one..."
```

```bash
pnpm install somepackage
# Success
```

"Installed! Continuing..."

## What User NEVER Does

❌ User never runs `pnpm install`
❌ User never runs `pnpm run dev`
❌ User never runs `git` commands
❌ User never runs setup scripts
❌ User never checks versions
❌ User never troubleshoots with terminal

## What YOU Always Do

✅ YOU run all pnpm commands
✅ YOU run all git commands
✅ YOU run all setup scripts
✅ YOU check versions/status
✅ YOU troubleshoot with terminal commands
✅ YOU verify everything works

## Summary: Decision Tree

```
User makes request
    ↓
Is it an explicit command? (e.g., "install X", "run dev")
    ↓ YES
    Run it immediately using Bash tool

    ↓ NO
Is it a diagnostic/check command?
    ↓ YES
    Run it immediately using Bash tool

    ↓ NO
Does it add new packages for a feature?
    ↓ YES
    Explain what you'll do → Ask permission → Run commands

    ↓ NO
Is it a production/deployment command?
    ↓ YES
    Explain implications → Ask permission → Run commands

    ↓ NO
Is it safe and expected? (like starting dev server)
    ↓ YES
    Run it immediately using Bash tool
```

## Critical Mistakes to Avoid

### ❌ WRONG: Telling User to Run Commands

"To install dependencies, run:
pnpm install"

### ✅ RIGHT: Running Commands Yourself

"I'll install the dependencies for you..."
```bash
pnpm install
```
"Dependencies installed!"

---

### ❌ WRONG: Not Installing Dependencies

User: "Add a blog"
You: [Create files but don't install needed packages]

### ✅ RIGHT: Installing Dependencies

User: "Add a blog"
You: "I'll add a blog. This needs the 'gray-matter' package. One moment..."
```bash
pnpm install gray-matter
```
[Create files]
"Blog created!"

---

### ❌ WRONG: Asking Permission for Everything

"Should I check if dependencies are installed?"

### ✅ RIGHT: Running Diagnostic Commands

[Just run: pnpm list or ls node_modules]
"Checking dependencies..."

---

## Final Rule

**When in doubt: RUN THE COMMAND YOURSELF.**

Don't ask user to run it. Don't ask if you should run it.
Just use the Bash tool and run it.

The only time you ask permission:
1. Adding new packages for features (explain what they do)
2. Deploying to production
3. Pushing to git (unless user asked to)
4. Anything that costs money
5. Anything that requires user signup

Everything else: **JUST RUN IT.**
