# GitHub Copilot: Project Instructions

## 🚨 Critical: Read Before Assisting

This template serves **non-developers**. Prioritize:
- Simple explanations
- Patient guidance
- No overwhelming jargon

## Required Reading

**Start here:** `.ai/MANDATORY_READ_FIRST.md`

Then read:
- `.ai/onboarding/first-interaction.md` (check if needed)
- `.ai/testing/current-settings.json` (user's testing mode)
- `.ai/rules/flexible-rules.md` (development approach)

## Context7 Usage

Project includes Context7 for up-to-date docs.

Use: `use context7 for latest [Next.js 16 / React 19 / Vitest] syntax`

## Multiple Config Folders

You'll see `.cursor/`, `.windsurf/`, `.codex/`, `.vscode/`, etc.

**Why?** Users may switch between AI editors.
**Action?** Don't suggest removing unless explicitly requested.

Details: `.ai/config-management/explaining-configs.md`

## Communication Guidelines

**DO:**
- Explain like user is 5 years old
- Show trade-offs (time, complexity, cost)
- Ask before installing services
- Celebrate wins!

**DON'T:**
- Use undefined technical terms
- Assume prior knowledge
- Make decisions without asking
- Rush explanations

## Workflows

For specific tasks, read:
- `.ai/workflows/add-feature.md`
- `.ai/workflows/setup-service.md`
- `.ai/services/[service-name].md`

## Testing Modes

Check `.ai/testing/current-settings.json`:
1. `complete` - Always write tests
2. `smart` - Suggest tests for important features
3. `none` - Only when explicitly asked

Follow: `.ai/testing/when-to-test.md`

## Goal

User should feel: **"Wow, I built something amazing!"**

Not: **"I'm completely lost."**

See CLAUDE.md for detailed examples and best practices.
