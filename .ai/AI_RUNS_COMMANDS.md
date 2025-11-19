# AI Runs ALL Commands - User NEVER Does

## Core Principle

**Users of this template should NEVER have to open a terminal or run commands.**

You (the AI assistant) run ALL commands using the Bash tool.

## Why This Matters

This template is designed for non-developers who may:
- Not know what a terminal is
- Not know how to navigate directories
- Be intimidated by command-line interfaces
- Just want to describe what they want and have it built

## Commands YOU Run

### Development
```bash
# YOU run these, never ask user to run them
pnpm install          # Install dependencies
pnpm run dev          # Start development server
pnpm run build        # Build for production
npm start            # Start production server
pnpm run lint         # Run linter
```

### Testing
```bash
# YOU run these
npm test                    # Run tests
pnpm run test:ui             # Run tests with UI
pnpm run test:coverage       # Run with coverage
```

### Setup Scripts
```bash
# YOU run these
pnpm run setup-context7      # Enable Context7
pnpm run cleanup-unused      # Remove unused config folders
```

### Git Commands
```bash
# YOU run these
git status
git add .
git commit -m "message"
git push
git pull
```

### Package Management
```bash
# YOU run these
pnpm install [package-name]
npm uninstall [package-name]
npm update
```

## Communication Examples

### ❌ WRONG - Telling User to Run Commands

```
"To see your app, run:
pnpm run dev

Then open http://localhost:3000"
```

### ✅ RIGHT - YOU Run Commands

```
"Let me start the development server for you..."

[YOU run: pnpm run dev using Bash tool]

"Done! Your app is running at http://localhost:3000"
```

### ❌ WRONG - Installing Packages

```
"You'll need to install this package:
pnpm install shadcn-ui"
```

### ✅ RIGHT - YOU Install

```
"I'll install the UI components library for you..."

[YOU run: pnpm install shadcn-ui using Bash tool]

"Installed! Now let me add a button component..."
```

### ❌ WRONG - Context7 Setup

```
"To enable Context7, run:
pnpm run setup-context7

Then paste your API key when prompted."
```

### ✅ RIGHT - YOU Run Setup

```
"I'll set up Context7 for you. First, get your API key:

1. Go to https://context7.com/dashboard
2. Copy your API key

Got it? Great! I'll run the setup now..."

[YOU run: pnpm run setup-context7 using Bash tool]

"Paste your API key when you see the prompt below..."

[User pastes key into the interactive prompt]

"Perfect! Context7 is now enabled. Please restart your editor."
```

## Exception: Editor Restarts

The ONLY thing users need to do themselves:
- Restart their AI editor after Context7 setup
- Refresh their browser to see changes

Everything else: YOU do it.

## Verification Steps

Before ANY response, ask yourself:
1. Am I telling the user to run a command?
2. Could I run this command myself instead?
3. Have I used the Bash tool to run commands?

If you're telling the user to run something, STOP and run it yourself.

## Common Scenarios

### Scenario 1: User Asks for a Feature

**User:** "Add a contact form"

**Your workflow:**
1. YOU check if dependencies are installed (`npm list`)
2. YOU install any needed packages
3. YOU create the component files
4. YOU run the dev server
5. YOU tell user where to see it

### Scenario 2: User Wants to Deploy

**User:** "Deploy to Vercel"

**Your workflow:**
1. YOU run `pnpm install vercel` if needed
2. YOU run `npx vercel login` and guide them through auth
3. YOU run `npx vercel deploy`
4. YOU provide the deployment URL

### Scenario 3: User Encounters Error

**User:** "I see an error"

**Your workflow:**
1. YOU run diagnostic commands (`pnpm run lint`, `pnpm run build`)
2. YOU identify the issue
3. YOU fix the code
4. YOU run `pnpm run dev` to verify
5. YOU explain what was wrong in simple terms

## Summary

- **User role:** Describe what they want, answer questions, paste API keys when needed
- **Your role:** Run ALL commands, build features, explain in simple terms
- **Never:** Ask users to open terminal or run commands
- **Always:** Use Bash tool to run commands yourself

This is an AI-first template. The AI (you) does the technical work. The user does the creative thinking.
