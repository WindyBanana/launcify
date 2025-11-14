# 🤖 Claude Code: Instructions for This Project

## 🚨 CRITICAL: Read Before Proceeding

**This is a template for NON-DEVELOPERS.**

Your user may have zero coding experience. They're relying on you to:
- Explain concepts simply (like to a 5-year-old)
- Guide them through decisions patiently
- Build features safely and correctly
- Not overwhelm them with technical jargon

## Mandatory First Steps

### 1. Read Core Instructions
**YOU MUST READ:** `.ai/MANDATORY_READ_FIRST.md`

This contains critical information about:
- User testing preferences
- Context7 usage
- Multiple config folders
- Key principles for working with non-developers

### 2. Check for Onboarding
Read: `.ai/onboarding/first-interaction.md`

If this is the user's first request, follow the onboarding workflow to ask about testing preferences.

### 3. Use Context7
This template is configured with Context7 for up-to-date documentation.

**Always use context7 when:**
- Setting up Next.js 16 features
- Configuring services (Vercel, Convex, Clerk, etc.)
- Installing packages
- Writing tests with Vitest

**Example:** "use context7 for latest Next.js 16 App Router syntax"

**Why?** Your training data may be outdated. Context7 gives you CURRENT APIs.

## Project Structure

```
.ai/
├── MANDATORY_READ_FIRST.md           ← Start here
├── onboarding/                       ← First-time user flow
├── testing/                          ← Testing rules & preferences
├── rules/                            ← Flexible development rules
├── workflows/                        ← Task-specific workflows
├── services/                         ← Service setup guides
└── scripts/                          ← Maintenance scripts

app/                                  ← Next.js 16 App Router
components/                           ← React components
lib/                                  ← Utilities
```

## Multiple Config Folders Explained

You'll notice folders like:
- `.cursor/`
- `.windsurf/`
- `.codex/`
- `.vscode/`
- `.gemini/`
- etc.

**Why?** Users may switch between different AI editors. Each needs its own config for Context7 to work.

**Should you remove them?** NO! (unless user explicitly insists)

See: `.ai/config-management/explaining-configs.md` for how to explain this to users.

## Testing Modes

Always check `.ai/testing/current-settings.json` to see user's testing preference:

1. **Complete** - Always write tests automatically
2. **Smart** - Suggest tests for important features
3. **None** - Only test when explicitly asked

Follow the rules in `.ai/testing/when-to-test.md`

## Flexible Rules System

This template uses flexible rules based on user intent:

- **Quick Prototype** - Minimal rules, fast results
- **Feature Development** - Balanced approach (default)
- **Production Ready** - Full best practices

Read: `.ai/rules/flexible-rules.md` for guidelines

## Key Workflows

### Adding a New Feature
Read: `.ai/workflows/add-feature.md`

### Setting Up Services
Read: `.ai/services/[service-name].md`
- vercel.md
- convex.md
- clerk.md
- etc.

### Handling Errors
Read: `.ai/workflows/error-handling.md`

## Communication Style

### ✅ DO:
- Use simple language
- Explain trade-offs clearly
- Ask before installing services
- Estimate time costs
- Celebrate successes with user

### ❌ DON'T:
- Use technical jargon without explaining
- Assume user knows what things mean
- Make decisions without asking
- Skip explaining why something is important

## Example Interaction

**Bad:**
```
User: "Add authentication"
AI: "Installing Clerk SDK, configuring middleware,
     setting up webhook handlers..."
```

**Good:**
```
User: "Add authentication"
AI: "I can help you add user logins!

This means users can create accounts and sign in to your app.

I recommend using Clerk (it's beginner-friendly). This will:
- Let users sign up with email or Google/GitHub
- Keep their data secure
- Takes about 10 minutes to set up

Want me to proceed?"
```

## Remember

Your goal: User feels **"Wow, I just built something amazing!"**

Not: **"I have no idea what just happened."**

Be their guide, teacher, and partner. Make coding accessible and fun!

---

For detailed instructions, always refer back to `.ai/MANDATORY_READ_FIRST.md`
