# AI Instructions Overview

This directory contains comprehensive instructions for AI assistants helping non-developers build applications.

## 🚨 Start Here

1. **MANDATORY_READ_FIRST.md** - Read this before anything else
2. **ASK_DONT_ASSUME.md** - Critical: When unsure, ASK! Never assume
3. **STRICT_COMMAND_RULES.md** - When/how to run terminal commands
4. **WHEN_TO_SUGGEST_SERVICES.md** - When to recommend services

## 📁 Directory Structure

```
.ai/
├── MANDATORY_READ_FIRST.md          ← Start here
├── ASK_DONT_ASSUME.md               ← When to ask questions
├── STRICT_COMMAND_RULES.md          ← Command execution rules
├── AI_RUNS_COMMANDS.md              ← Overview of AI-runs-everything
├── WHEN_TO_SUGGEST_SERVICES.md      ← Service recommendation guide
├── CLARIFYING_QUESTIONS_REFERENCE.md ← Quick question templates
├── CONTEXT7_VERIFICATION.md         ← Testing Context7 setup
├── CONTEXT7_STATUS.md               ← Context7 implementation status
│
├── onboarding/                      ← First-time user experience
│   ├── first-interaction.md         ← Initial setup flow
│   └── testing-choice.md            ← Testing mode options
│
├── workflows/                       ← Step-by-step task guides
│   └── add-feature.md               ← How to build features
│
├── testing/                         ← Testing strategies
│   └── when-to-test.md              ← Testing decision tree
│
├── rules/                           ← Code quality levels
│   └── flexible-rules.md            ← Prototype/Feature/Production
│
├── structure/                       ← Project organization
│   └── project-structure.md         ← File/folder conventions
│
├── services/                        ← Third-party integrations
│   ├── context7.md                  ← Documentation service
│   ├── clerk.md                     ← Authentication
│   ├── convex.md                    ← Database
│   ├── vercel.md                    ← Hosting
│   ├── axiom.md                     ← Logging
│   └── linear.md                    ← Feedback system
│
├── scripts/                         ← Setup automation
│   ├── setup-context7.js            ← Enable Context7
│   ├── generate-configs.js          ← Auto-generate configs
│   └── cleanup-configs.js           ← Remove unused configs
│
└── examples/                        ← Reference examples
    └── good-clarifying-conversations.md ← How to ask questions
```

## Core Principles

### 1. ASK, DON'T ASSUME
- Vague request? → Ask for specifics
- Multiple options? → Present 2-4 choices (short summaries)
- Uncertain? → Clarify before building
- See: `ASK_DONT_ASSUME.md`

### 2. AI RUNS ALL COMMANDS
- User NEVER runs terminal commands
- YOU run everything using Bash tool
- See: `STRICT_COMMAND_RULES.md`

### 3. NON-DEVELOPER FIRST
- Use plain English, not jargon
- Explain concepts simply (like to a 5-year-old)
- Be patient and encouraging
- Verify understanding frequently

### 4. PROACTIVE SERVICE SUGGESTIONS
- Suggest services when user needs them
- Don't force or overwhelm
- One service at a time
- See: `WHEN_TO_SUGGEST_SERVICES.md`

## Quick Reference

### When User's First Request
1. Read: `onboarding/first-interaction.md`
2. YOU run: `npm install` (automatic)
3. Present testing mode options
4. Save their choice
5. Proceed with their request

### When Building Features
1. Read: `workflows/add-feature.md`
2. Ask clarifying questions if vague
3. Verify understanding before building
4. YOU run all commands
5. Test and verify it works
6. Confirm with user after building

### When User Needs Services
1. Read: `WHEN_TO_SUGGEST_SERVICES.md`
2. Identify what they need
3. Suggest appropriate service
4. Explain benefits simply
5. YOU run setup commands
6. Guide them through API keys/signups
7. Test and verify

### When Uncertain
1. Read: `ASK_DONT_ASSUME.md`
2. Read: `CLARIFYING_QUESTIONS_REFERENCE.md`
3. Ask specific questions (max 3-4 options)
4. Use short summaries, not long explanations
5. Verify understanding
6. Proceed only after clarity

## Common Scenarios

### "Add a form"
→ See: `CLARIFYING_QUESTIONS_REFERENCE.md` (What kind of form?)

### "Make it better"
→ Ask: "What specifically needs improvement?" (Design? Features? Speed?)

### "Add authentication"
→ Suggest: Clerk (see: `services/clerk.md`)

### "Save data"
→ Suggest: Convex (see: `services/convex.md`)

### "Make it live"
→ Suggest: Vercel (see: `services/vercel.md`)

### "Track errors"
→ Suggest: Axiom (see: `services/axiom.md`)

### "User feedback"
→ Suggest: Linear (see: `services/linear.md`)

## Remember

- **When in doubt, ASK**
- **YOU run all commands**
- **Verify before and after**
- **Short summaries, not walls of text**
- **One question at a time**
- **Be patient and kind**

Your goal: User feels understood, confident, and empowered - not confused or overwhelmed.
