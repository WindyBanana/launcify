# Explaining Test Failures to Non-Developers

## When Tests Fail

When a test fails, the user will see technical error messages. Your job is to translate these into simple language.

## The Pattern

1. **Acknowledge the failure** (don't panic them)
2. **Explain what broke** in simple terms
3. **Show what to do** (usually: "I'll fix it")
4. **Fix it automatically** (don't make them do it)

## Examples

### Example 1: Component Test Failure

**Technical Error:**
```
FAIL app/components/ContactForm.test.tsx
● ContactForm › should validate email format

expect(received).toHaveBeenCalledWith(expected)

Expected: {"email": "test@example.com", "message": "Hello"}
Received: {"email": "test@example.com"}
```

**Your Response:**
```
⚠️ Test failed for the contact form.

What happened:
The form isn't sending the message field - only the email.

What I'll do:
I'll fix the form to include the message when submitting.

(Fixing now...)

✅ Fixed! The form now sends both email and message. Test passes.
```

### Example 2: Validation Test Failure

**Technical Error:**
```
FAIL app/components/LoginForm.test.tsx
● LoginForm › should reject invalid passwords

expect(element).toHaveTextContent(/password must be at least 8 characters/i)
Received element has text: ""
```

**Your Response:**
```
⚠️ Test failed for login validation.

What happened:
The form isn't showing an error message when someone enters
a short password.

What I'll do:
I'll add the missing error message for weak passwords.

(Fixing now...)

✅ Fixed! Now users see "Password must be at least 8 characters"
when they enter a short password.
```

## Key Principles

### 1. Never Use Technical Jargon

❌ **Bad:** "The mock function wasn't called with the expected arguments in the assertion"

✅ **Good:** "The form didn't send the data we expected"

### 2. Relate to What They Understand

❌ **Bad:** "The component didn't render with the correct props"

✅ **Good:** "The button doesn't show the right text"

### 3. Show You're Fixing It

❌ **Bad:** "You need to update the validation logic in the schema"

✅ **Good:** "I'll fix the validation to catch this error"

### 4. Confirm When Fixed

Always show:
- ✅ What you fixed
- ✅ Test now passes
- ✅ What it does correctly now

## Common Failure Types

### Rendering Failures
**Means:** Component doesn't show what we expect

**Explain as:** "The [button/form/page] isn't displaying correctly"

### Validation Failures
**Means:** Input validation isn't working

**Explain as:** "The form isn't catching [invalid emails/weak passwords/etc.]"

### API/Network Failures
**Means:** API call didn't work as expected

**Explain as:** "The connection to [database/server] isn't working right"

### State Management Failures
**Means:** Data isn't updating correctly

**Explain as:** "The [counter/form/list] isn't updating when it should"

## When You Can't Auto-Fix

Sometimes you need user input:

```
⚠️ Test failed for the pricing calculation.

What happened:
The discount code "SAVE20" should give 20% off, but it's giving 10% off.

I need your help:
What discount amount should "SAVE20" give?
- 10% (current)
- 20% (what the test expects)
- Something else?

Tell me and I'll fix it right away.
```

## After Multiple Failures

If tests keep failing:

```
I'm seeing multiple test failures. This usually means:

1. The feature is more complex than expected, OR
2. The tests need adjusting for how the feature works

Would you like me to:
A) Keep fixing until all tests pass (recommended)
B) Explain what's failing in detail so you understand
C) Remove the failing tests for now (not recommended)

What works for you?
```

## Summary

**Your job:** Be the translator between technical test output and human understanding.

**Remember:** The user doesn't care about assertions, mocks, or test runners. They care about: "Does my app work correctly?"
