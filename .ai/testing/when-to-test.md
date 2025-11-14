# When to Write Tests (AI Guidelines)

## Overview
This file guides you on when to suggest or write tests based on user's testing mode.

## Check User's Testing Mode First

**Always read:** `.ai/testing/current-settings.json`

This tells you the user's preference:
- `"testingMode": "complete"` → Always write tests
- `"testingMode": "smart"` → Suggest tests strategically
- `"testingMode": "none"` → Never write tests automatically

## Mode 1: Complete Test Suite

**When:** `testingMode === "complete"`

**What to do:** Write tests for EVERY feature automatically.

### Always Test:
- ✅ New React components
- ✅ Functions with logic (calculations, transformations)
- ✅ API routes
- ✅ Forms and user inputs
- ✅ Data validation
- ✅ Error handling

### Example Flow:
```
User: "Add a contact form"

AI actions:
1. Create ContactForm.tsx component
2. Create ContactForm.test.tsx automatically
3. Write tests for:
   - Form renders correctly
   - Validation works
   - Submit handler called
   - Error states display
4. Tell user: "✅ Created contact form with tests"
```

**Don't ask permission** - just do it. User chose this mode.

---

## Mode 2: Smart Testing

**When:** `testingMode === "smart"`

**What to do:** Suggest tests for high-value scenarios, let user decide.

### Always Suggest Tests For:

#### 1. User Authentication
```
AI: "I've added authentication. Should I write tests for:
    - Login/logout flows
    - Protected routes
    - Session handling
    This ensures security features work correctly. (Takes 3 minutes)"
```

#### 2. Payment/Money Handling
```
AI: "This payment form handles money. I strongly recommend tests to prevent errors.
    Should I add them? (Takes 5 minutes)"
```

#### 3. Data Validation/Forms
```
AI: "Created the registration form. Want me to add tests?
    Tests check that invalid emails/passwords are caught.
    (Takes 2 minutes)"
```

#### 4. Complex Logic
```
AI: "This calculation is complex. Tests would help ensure it's correct.
    Should I add them? (Takes 3 minutes)"
```

### Don't Suggest Tests For:
- ❌ Simple UI components (buttons, cards)
- ❌ Static pages (about, landing pages)
- ❌ Basic styling changes
- ❌ Configuration files

### When User Says No:
Respect it, but note it:
```
AI: "Got it, skipping tests for now. You can always ask me to add them later by saying:
    'Add tests for the registration form'"
```

---

## Mode 3: No Automatic Tests

**When:** `testingMode === "none"`

**What to do:** Never write or suggest tests unless explicitly asked.

### Exception: Critical Security Warning

Even in "none" mode, warn about security risks:

```
User: "Add payment processing"

AI: "⚠️ Important: You've chosen not to use automatic testing, but payment code
    is high-risk. I strongly recommend manual testing or switching to smart
    testing mode for this feature.

    Continue without tests? (yes/no)"
```

---

## General Guidelines

### 1. Explain Test Value in Simple Terms

**Bad:** "I'll write unit tests with Jest to mock the API calls..."

**Good:** "I'll write tests that check if the form works correctly - like checking
         that error messages show up when someone enters a bad email."

### 2. Estimate Time Cost

Always tell user how much longer it takes:
- Simple component test: +1-2 minutes
- Form with validation: +3-5 minutes
- API route with logic: +5-10 minutes
- Complex feature: +10-20 minutes

### 3. Show Value After Writing Tests

```
AI: "✅ Created user registration with 8 tests covering:
    - Email validation
    - Password strength checking
    - Duplicate user prevention
    - Success/error handling

    Run 'npm test' anytime to verify everything still works!"
```

### 4. When Tests Fail

Use the guide from `.ai/testing/explaining-test-failures.md`

---

## Special Cases

### User Asks to Change Testing Mode

```
User: "Change to complete testing"

AI: "Switching to complete test suite mode. From now on, I'll automatically
    write tests for all features.

    Should I go back and add tests for existing features? (yes/no)"
```

Then update `.ai/testing/current-settings.json`

### User Asks to Add Tests Later

```
User: "Add tests for the contact form"

AI: (Even if mode is "none", honor the explicit request)
    "Adding tests for ContactForm... Done! Tests cover:
    - Form validation
    - Submit handling
    - Error states"
```

### AI is Unsure

When in doubt (e.g., moderately complex feature in "smart" mode), ask:

```
AI: "This feature is medium complexity. Tests would be helpful but not critical.
    Want me to add them? (yes/no)"
```

---

## Context7 Usage

Always use context7 for current testing syntax:
- "use context7 for latest Vitest syntax"
- "use context7 for React Testing Library best practices"
- "use context7 for Next.js 16 testing setup"

This ensures tests use current APIs.

---

## Summary Decision Tree

```
Check testing mode:

IF mode === "complete":
  → Write tests automatically
  → Don't ask permission
  → Tell user tests were added

ELSE IF mode === "smart":
  IF feature is high-value/risky:
    → Suggest tests
    → Explain benefits
    → Let user decide
  ELSE:
    → Don't suggest tests
    → Build feature quickly

ELSE IF mode === "none":
  → Never suggest tests
  → Only warn for critical security
  → Honor explicit requests

ALWAYS:
  → Explain in simple terms
  → Estimate time cost
  → Use context7 for current syntax
```
