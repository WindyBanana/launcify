# How It Works

## The Magic Behind the Scenes

This template is designed to make building apps as simple as having a conversation. Here's what happens when you talk to your AI.

## Your First Request

### Step 1: Testing Preferences

Your AI will ask one quick question:

```
How do you want to handle testing?

1. Complete Test Suite - AI writes tests for everything (safest)
2. Smart Testing - AI suggests tests for important features (balanced)
3. No Automatic Tests - Build quickly without tests (fastest)

Which fits your needs?
```

**Why this matters:** This helps your AI know how thoroughly to test your code. You can change this anytime.

### Step 2: AI Sets Everything Up

Your AI automatically:
- Installs all necessary packages
- Sets up the development environment
- Prepares everything to run

**You don't do anything** - your AI handles all the technical setup.

### Step 3: AI Builds What You Asked For

Your AI:
- Creates the files needed
- Writes the code
- Tests that it works
- Starts a preview so you can see it

## How Your AI Understands You

### Smart Clarification

If your request is unclear, your AI will ask:

**You:** "Add a form"

**AI:**
```
What kind of form?

1. Contact form - Let people reach you
2. Sign up form - Create user accounts
3. Survey - Collect responses

Which one?
```

### Verification Before Building

Before starting, your AI confirms:

```
I'll create a contact form for you.

This will:
- Name, email, and message fields
- Send you an email when someone submits
- Takes about 10 minutes

Is this what you're looking for?
```

### Verification After Building

After building, your AI checks:

```
Done! Here's what you got:
- Contact form at /contact
- Sends to your email
- Shows "Thanks!" message

Try it at: http://localhost:3000/contact

Does this work as expected?
```

## What's Included in the Template

```
your-app/
├── .ai/                    # Instructions for AI assistants
│   ├── services/          # How to set up auth, databases, etc.
│   ├── workflows/         # Step-by-step guides
│   └── rules/             # Code quality guidelines
│
├── .cursor/               # Cursor configuration
├── .windsurf/             # Windsurf configuration
├── .vscode/               # VS Code Copilot configuration
├── .codex/                # OpenAI Codex configuration
│
├── app/                   # Your Next.js application
├── components/            # Reusable UI components
├── lib/                   # Helper functions and utilities
└── docs/                  # Documentation (what you're reading!)
```

### The .ai/ Folder

This contains instructions that your AI reads to know how to help you. You don't need to read these - your AI does it automatically.

### Config Folders (.cursor/, .windsurf/, etc.)

These ensure the template works with any AI editor. Each editor only reads its own folder and ignores the rest.

**Don't delete them!** They allow you to switch between different AI editors seamlessly.

## Context7 (Optional)

Context7 gives your AI access to the latest documentation for frameworks like Next.js and React.

**Without Context7:** AI uses its training data (might be outdated)
**With Context7:** AI gets current docs from official sources

**To enable:** Just tell your AI: `"Set up Context7 for me"`

Your AI will:
1. Guide you to get a free API key
2. Run the setup automatically
3. Verify it works

**It's free** for public projects and takes 2 minutes.

## Behind Every Feature

When you ask for a feature, here's what happens:

### 1. Clarification
AI asks questions if needed to understand exactly what you want.

### 2. Planning
AI figures out what files to create, what packages to install, and how long it will take.

### 3. Confirmation
AI explains the plan and waits for your approval.

### 4. Building
AI:
- Installs any needed packages
- Creates the code
- Follows best practices
- Adds tests (based on your testing preference)

### 5. Testing
AI runs the development server and tests that everything works.

### 6. Verification
AI shows you the result and asks if it matches what you wanted.

### 7. Iteration
If it's not quite right, AI adjusts and tries again.

## No Terminal Commands. Ever.

Traditional development requires running commands like:
```bash
npm install
npm run dev
git commit
```

**With this template:** Your AI runs ALL commands for you. You never touch the terminal.

Your job: Describe what you want
AI's job: Make it happen

## Services Your AI Can Set Up

Your AI knows how to integrate:

- **Authentication** (Clerk) - User accounts and login
- **Database** (Convex) - Save data permanently
- **Hosting** (Vercel) - Put your app online
- **Logging** (Axiom) - Track errors and activity
- **Feedback** (Linear) - Let users report bugs

Just ask! For example: `"Add user login with Google sign-in"`

Your AI will:
1. Suggest the best service for your needs
2. Explain what it does in simple terms
3. Guide you through getting API keys
4. Run all setup commands
5. Test that it works

## Changing Your Mind

Nothing is permanent. You can:

**Change testing mode:**
```
"Change testing to complete mode"
```

**Modify features:**
```
"Make the buttons blue instead of green"
"Add a phone number field to the form"
```

**Start over:**
```
"Let's try a different approach"
```

Your AI is patient and flexible. Experiment freely!

## What Makes This Different

### Traditional Development
1. Learn programming
2. Learn frameworks
3. Read documentation
4. Write code
5. Debug errors
6. Deploy

**Time:** Months to years

### With This Template
1. Describe what you want
2. Answer a few questions
3. Your app is built

**Time:** Minutes to hours

## Summary

This template turns your AI assistant into a development partner that:
- Understands what you want (even if vague)
- Asks clarifying questions
- Runs all technical commands
- Builds features using best practices
- Tests everything
- Verifies you're happy with the result

All you do is talk. Your AI does the rest.

---

**Ready to see it in action?** Go back to your AI and say: `"Build me something cool!"`
