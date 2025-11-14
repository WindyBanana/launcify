# First Interaction Workflow

## When to Use This
Use this workflow when:
- User has just opened this template for the first time
- No `.ai/testing/current-settings.json` file exists
- User asks for anything before testing preference is set

## FIRST: Install Dependencies Automatically

**Before anything else, YOU run:**

```bash
# Check if node_modules exists
ls node_modules

# If missing or user's first request, install immediately
npm install
```

**Tell user while installing:**
```
"Welcome! I'm setting up your project... (installing dependencies)"
```

**After install completes:**
```
"Ready! Now let me help you get started..."
```

**DO NOT ask permission** - just install. User expects the project to work.

## Onboarding Steps

### Step 1: Warm Welcome
Greet the user warmly and explain what this template does.

**Example:**
```
Hi! Welcome to your AI-powered development template!

I'm here to help you build your app, and I'll guide you through
everything step by step. You don't need to know how to code -
just tell me what you want to build, and I'll create it.

Before we start, I need to ask you one quick question about testing...
```

### Step 2: Present Testing Options
Read and present: `.ai/onboarding/testing-choice.md`

This is CRITICAL. User's choice affects how you work throughout the entire project.

**Present the three options clearly** (see testing-choice.md for exact wording).

### Step 3: Save User's Choice
Based on their answer, create `.ai/testing/current-settings.json`:

**Option 1: Complete Test Suite**
```json
{
  "testingMode": "complete",
  "autoWriteTests": true,
  "explainTestFailures": true,
  "createdAt": "2024-01-15T10:30:00Z",
  "userChoice": "Always write tests for every feature"
}
```

**Option 2: Smart Testing**
```json
{
  "testingMode": "smart",
  "autoWriteTests": false,
  "suggestTests": true,
  "explainTestFailures": true,
  "createdAt": "2024-01-15T10:30:00Z",
  "userChoice": "AI suggests tests, user decides"
}
```

**Option 3: No Automatic Tests**
```json
{
  "testingMode": "none",
  "autoWriteTests": false,
  "suggestTests": false,
  "explainTestFailures": false,
  "createdAt": "2024-01-15T10:30:00Z",
  "userChoice": "Fast prototyping, no automatic tests"
}
```

### Step 4: Confirm and Explain Next Steps
After saving their choice:

**Example:**
```
Perfect! I've set up testing the way you want.

{IF complete}: I'll automatically write tests for every feature to keep your app safe and bug-free.

{IF smart}: I'll suggest adding tests when it makes sense, and you can decide each time.

{IF none}: I'll focus on building features quickly without automatic tests.

Now, what would you like to build? Tell me about your idea!
```

### Step 5: Mark Onboarding Complete
Create `.ai/onboarding/completed.json`:
```json
{
  "completedAt": "2024-01-15T10:30:00Z",
  "testingMode": "smart",
  "contextSeven": "available"
}
```

### Step 6: Listen to User's Idea
Now listen carefully to what they want to build and follow the appropriate workflow from `.ai/workflows/`.

## Important Notes

### If User Asks to Skip Onboarding
Gently explain why it's important:

"I understand you're eager to start! This one question just takes 10 seconds and helps me work the way you prefer. It's about whether you want automatic testing for your code. Should I explain what that means?"

### If User Doesn't Understand Testing
Use the ELI5 explanation from `.ai/onboarding/testing-choice-explained.md`

### If User Changes Their Mind Later
No problem! They can always change settings:

"Want to change your testing preference? Just say:
- 'Change testing to complete'
- 'Change testing to smart'
- 'Change testing to none'"

Then update `.ai/testing/current-settings.json` accordingly.

## After Onboarding

From now on, every interaction should:
1. **ASK if uncertain** - Read `.ai/ASK_DONT_ASSUME.md`
2. Check `.ai/testing/current-settings.json` for testing mode
3. Use context7 for up-to-date documentation
4. Follow flexible rules from `.ai/rules/`
5. Be patient and explain concepts simply
6. Verify understanding before and after building

## Next Workflow
After onboarding, proceed to:
- `.ai/workflows/understand-user-request.md`
