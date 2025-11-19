# Service Setup: Context7 (Optional but Recommended)

## What is Context7?

Context7 is a service that provides AI assistants with **current, up-to-date documentation** for libraries and frameworks.

**Without Context7:** AI uses training data (may be months/years old, contains outdated APIs)
**With Context7:** AI gets current docs from the actual source repositories

## When to Suggest This to Users

### Suggest Context7 when:
- User is adding a complex feature
- User mentions getting errors with AI-generated code
- User asks "is this code up-to-date?"
- You notice your suggestions might be outdated

### Example Suggestion:
```
"I can help you build this, but I should mention: My training data
might be a bit outdated for [Next.js 16 / React 19 / etc.].

Want me to set up Context7? It's free and gives me access to
current documentation so you get accurate code.

Takes 2 minutes to set up."
```

## What to Tell Users (Simple Explanation)

```
"Context7 is like giving me a direct connection to the latest
instruction manuals for Next.js, React, and other tools.

Without it: I use what I remember (which might be outdated)
With it: I look up the current, correct way to do things

It's free for public projects and takes 2 minutes to set up."
```

## Setup Process (Guide Users Through This)

**IMPORTANT FOR AI: YOU run the scripts. The user should NEVER have to run terminal commands.**

### Step 1: Explain What They'll Do
```
"Here's what we'll do:
1. You sign up at context7.com (30 seconds, free)
2. You copy your API key
3. I'll run the setup for you
4. You restart your editor

I'll guide you through each step!"
```

### Step 2: Sign Up
```
"First, go to: https://context7.com/dashboard

Click 'Sign Up' (it's free)

Sign in with GitHub or email - whatever's easier for you.

Got to the dashboard? Great!"
```

### Step 3: Get API Key
```
"On the Context7 dashboard, you should see an API key.

It looks something like: ctx7_abc123...

Click the 'Copy' button next to it.

Got it copied? Perfect!"
```

### Step 4: Run Setup Script
```
"Great! Now I'll run the setup script for you.

I'm going to run: pnpm run setup-context7

It will ask for your API key - just paste it when prompted and press Enter."
```

**AI: Actually run the command using the Bash tool:**
```bash
pnpm run setup-context7
```

The script will prompt for the API key. Tell the user to paste it when they see the prompt.

### Step 5: Restart Editor
```
"Last step: Restart [Cursor / Windsurf / VS Code / etc.]

Just close and reopen it.

Done! Context7 is now active."
```

### Step 6: Test It
```
"Let's test it! Try asking me:

'use context7 to show me the latest Next.js 16 App Router example'

You should see me fetch current documentation.

Working? Awesome! Now I'll give you up-to-date code."
```

## Troubleshooting

### "I don't see an API key on the dashboard"
```
"Try refreshing the page, or look for a section called 'API Keys'
or 'Settings'. If still stuck, they might have changed their UI.

Check: https://context7.com/docs for updated instructions."
```

### "The setup script failed"
```
"Let me check the error message and fix it.

Common issues I'll check:
- Verify we're in the project directory
- Check Node.js version (needs v18 or newer)
- Verify API key format"
```

**AI: Don't ask the user to run commands. You check these things:**
```bash
node --version
pwd
```

### "It's not working after restart"
```
"Let's verify:
1. Check the config file for your editor got updated
   - Cursor: .cursor/mcp_settings.json
   - Windsurf: .windsurf/mcp.json
   - VS Code: .vscode/settings.json

2. Look for 'context7' (not 'context7-disabled')
3. Your API key should be there (not 'YOUR_CONTEXT7_API_KEY')

If it still says 'context7-disabled', the setup script didn't work.
Let me run it again for you."
```

**AI: Run the setup script again if needed.**

## Important Notes

### Free Tier Limitations
- **Free:** Public repositories only
- **Paid:** Includes private repositories

**Tell users:**
```
"Context7 is free for public code (like open-source projects
and learning projects).

If you're building a private commercial app and want Context7
for private repos, there's a paid tier.

But for now, the free version will help with all the public
libraries we're using (Next.js, React, etc.)!"
```

### What Context7 Can Access
- ✅ Public GitHub repositories
- ✅ Official documentation sites
- ✅ Package registry information
- ❌ Your private code (unless you're on paid tier)

**Tell users:**
```
"Context7 can see documentation from public sources like:
- Next.js official docs
- React documentation
- npm packages

It can't see your private code or business logic. It just helps
me know the correct, current way to use these tools."
```

## When NOT to Suggest Context7

- ❌ User is just starting and overwhelmed
- ❌ User explicitly wants to keep things simple
- ❌ Project doesn't use modern frameworks/libraries
- ❌ User is in the middle of urgent bug fix

**Wait for a good moment**, like:
- After first successful feature is built
- When user asks about "best practices"
- When you notice outdated code patterns

## Manual Setup (If Script Fails)

If `pnpm run setup-context7` doesn't work, guide users to manually edit config files:

### For Cursor Users:
```
"Open: .cursor/mcp_settings.json

Find the line: "context7-disabled"
Change it to: "context7"

Find: "YOUR_CONTEXT7_API_KEY"
Replace with your actual API key

Save and restart Cursor."
```

Similar instructions for other editors (see config files for exact locations).

## Technical Details

### Two Integration Methods

Context7 offers two ways to integrate:

#### 1. MCP Server Integration (Recommended - What We Use)
- **MCP URL**: `https://mcp.context7.com/mcp`
- Used by: Cursor, Windsurf, VS Code, Codex, etc.
- AI editors connect directly to Context7's MCP server
- Requires API key in headers or args
- This is what our setup script configures

#### 2. Direct REST API (Advanced - Not Configured)
- **API URL**: `https://context7.com/api/v1`
- For custom integrations or programmatic access
- Same API key for authentication
- Not needed for standard AI editor usage

**For this template:** We only configure MCP integration since that's what AI editors use. The direct API is available if users need custom integrations later.

### API Key Management

Users create their API key at `https://context7.com/dashboard` after signup:
1. Sign up at context7.com
2. Navigate to dashboard
3. Create API key (looks like: `ctx7_abc123...`)
4. Copy the key
5. Run `pnpm run setup-context7` and paste when prompted

**Important:** The same API key works for both MCP and direct API access.

## Verification Steps

After setup, verify Context7 is working:

### Step 1: Check Config Files
```
"Verify the setup worked by checking your editor's config file:

For Cursor: .cursor/mcp_settings.json
For Windsurf: .windsurf/mcp.json
For VS Code: .vscode/settings.json

Look for:
1. Server named 'context7' (NOT 'context7-disabled')
2. Your actual API key (NOT 'YOUR_CONTEXT7_API_KEY')
3. Correct command/URL for your editor"
```

### Step 2: Restart Editor
```
"Close and reopen your AI editor completely.

Don't just reload the window - fully quit and restart.

This ensures the MCP server connection is established."
```

### Step 3: Test the Connection
```
"Ask your AI assistant:

'Use Context7 to fetch the latest Next.js 16 documentation'

You should see:
- AI mentions using Context7
- References to current Next.js features
- Accurate, up-to-date code examples

If it works: ✅ Context7 is active!
If not: Check troubleshooting below."
```

### Step 4: Verify Up-to-Date Information
```
"Compare AI responses before and after Context7:

Without Context7: May suggest outdated patterns
With Context7: Uses current APIs and best practices

Example test:
'Show me how to create a Server Action in Next.js 16'

With Context7 active, you'll get the latest syntax."
```

## Summary for AI

**Context7:**
- Optional but recommended
- Free for public repos
- Requires 2-minute setup
- Gives you current documentation
- Prevents outdated code suggestions
- User needs to sign up at context7.com
- **YOU run `pnpm run setup-context7`** - user should NEVER run terminal commands
- **MCP integration** (not direct API) is what we configure
- Same API key works for both MCP and API access

**Your role:**
1. Suggest Context7 proactively (don't force it)
2. Guide user to get API key from dashboard
3. **YOU run `pnpm run setup-context7`** using Bash tool (NO PERMISSION NEEDED - user asked for it)
4. Tell user to restart their editor
5. **YOU verify** it works using verification steps

**When user says "Set up Context7":**
- Immediately run `pnpm run setup-context7` using Bash tool
- Guide them through pasting API key
- Verify it worked
- NO PERMISSION NEEDED - they explicitly requested it

**User's role:**
1. Sign up at context7.com
2. Copy their API key
3. Paste it when you prompt them
4. Restart their editor

**User should NEVER:**
- Run terminal commands
- Edit config files manually
- Install packages themselves
