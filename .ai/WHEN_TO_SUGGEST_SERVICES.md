# When to Suggest Services (AI Instructions)

## Core Principle

**Suggest services proactively but don't force them.**

When user's needs match a service, mention it as a helpful option.

## Service Suggestion Matrix

### Context7 (Documentation)

**Suggest when:**
- First interaction with template
- User asks to build a complex feature
- User mentions errors with AI-generated code
- User asks "is this code up-to-date?"

**How to suggest:**
```
"I can help you build this, but I should mention:
My training data might be outdated for Next.js 16/React 19.

Want me to set up Context7? It gives me access to current
documentation so you get accurate, up-to-date code.
It's free and takes 2 minutes."
```

**Urgency:** Low - helpful but not critical

---

### Clerk (Authentication)

**Suggest when:**
- User mentions: "login", "accounts", "sign up", "users"
- User creates features that should be user-specific
- User asks about protecting pages
- User wants to save user data

**How to suggest:**
```
"For this feature to work well, users will need accounts.

I recommend Clerk for authentication:
- Easy email + social login
- User profiles and management
- Free up to 10,000 monthly active users
- Takes about 10 minutes to set up

Want me to add it?"
```

**Urgency:** Medium - often needed for useful apps

---

### Convex (Database)

**Suggest when:**
- User mentions: "save data", "database", "remember"
- User creates forms that should persist data
- User wants data across sessions/refreshes
- User mentions real-time features

**How to suggest:**
```
"Right now, this data will disappear when you refresh.

Want to save it permanently? I recommend Convex:
- Stores data in the cloud
- Real-time updates (like Google Docs)
- Free tier: 1 million function calls/month
- Takes about 10 minutes to set up

Should I add it?"
```

**Urgency:** High - most apps need data persistence

---

### Vercel (Deployment)

**Suggest when:**
- User asks: "deploy", "go live", "how do people see this?"
- User says "production" or "launch"
- User has completed main features
- User asks about sharing the app

**How to suggest:**
```
"Your app is ready to go live!

I recommend Vercel for hosting:
- Made by the Next.js team
- Free for personal projects
- Auto-deploys when you push to GitHub
- Takes about 5 minutes

Want me to deploy it?"
```

**Urgency:** Medium - needed when ready to launch

---

### Axiom (Logging)

**Suggest when:**
- User deploys to production
- User reports bugs but can't reproduce
- User asks "why is X happening?"
- User has production users
- User mentions "errors" or "monitoring"

**How to suggest:**
```
"Your app is live - nice! To track errors and see what users are doing:

I recommend Axiom:
- See all errors in one dashboard
- Track user behavior
- Debug production issues
- Free tier: 500 GB/month

This helps catch bugs before users report them.
Want me to add it?"
```

**Urgency:** High - essential for production apps

---

### Linear (Feedback)

**Suggest when:**
- User has deployed to production
- User has users/testers
- User asks "how do I track bugs?"
- User mentions "feature requests" or "feedback"

**How to suggest:**
```
"Now that your app has users, want to let them report bugs and request features?

I recommend Linear:
- Users can report bugs directly
- Track feature requests
- Organize and prioritize issues
- Free with 250 active issues (unlimited team members)

Want me to add a feedback form?"
```

**Urgency:** Low - nice to have for launched apps

---

## Suggestion Timing

### First Interaction
1. **Immediately:** Context7 (if not set up)
2. Don't suggest anything else yet - let user build first

### During Development
1. **When relevant:** Clerk (if user needs auth)
2. **When relevant:** Convex (if user needs data)
3. Don't overwhelm - one service at a time

### Pre-Deployment
1. **Before deploying:** Vercel (when user is ready)
2. **Optional:** Axiom (explain benefits for production)

### Post-Deployment
1. **After deployed:** Axiom (if not added)
2. **After deployed:** Linear (if not added)
3. **When needed:** Custom domain, analytics, etc.

## How to Suggest Multiple Services

**WRONG - Overwhelming:**
```
"This feature needs:
- Clerk for auth
- Convex for database
- Vercel for hosting
- Axiom for logging
- Linear for feedback

Should I set them all up?"
```

**RIGHT - One at a time:**
```
"This feature needs user accounts. Let me add Clerk.
[Set up Clerk]

Great! Now to save the data permanently, we need a database.
I recommend Convex. Should I add it?"
```

## Decision Tree

```
User makes request
    ↓
Does it need auth?
    ↓ YES
    Suggest Clerk
    ↓ NO

Does it need to save data?
    ↓ YES
    Suggest Convex
    ↓ NO

Is user ready to deploy?
    ↓ YES
    Suggest Vercel → Then Axiom
    ↓ NO

Is it live with users?
    ↓ YES
    Suggest Linear (if not already added)
    ↓ NO

Continue building features
```

## Never Suggest When

### Don't Suggest Context7:
- User is overwhelmed
- Mid-urgent bug fix
- User explicitly wants simple

### Don't Suggest Clerk:
- Feature doesn't need user-specific data
- User just wants a static site

### Don't Suggest Convex:
- Feature doesn't need persistence
- User wants simple static content

### Don't Suggest Vercel:
- User just started building
- App isn't functional yet

### Don't Suggest Axiom:
- App isn't deployed yet
- Still in early development

### Don't Suggest Linear:
- App has no users yet
- Still in development

## Responding to "I don't need that"

**User says:** "I don't want authentication"

**You respond:**
```
"No problem! I'll build it without authentication.

Note: This means anyone can access and modify the data.
Is that okay for now?

You can always add auth later if needed!"
```

**Don't:** Push services they don't want
**Do:** Note trade-offs and move on

## Responding to "Set up everything"

**User says:** "Set up all the services"

**You respond:**
```
"I'll set up the essential services for a production app:

1. Clerk - User authentication
2. Convex - Database
3. Vercel - Hosting
4. Axiom - Error tracking
5. Linear - User feedback

This will take about 30 minutes total.
I'll guide you through each one step by step.

Ready to start with Clerk?"
```

**Then:** Set them up one at a time, testing each before moving to the next.

## Service Dependencies

Some services work together:

**Convex + Clerk:**
- Convex can use Clerk's auth
- Suggest setting up Clerk first

**Vercel + Axiom:**
- Axiom works best on deployed apps
- Suggest Vercel first, then Axiom

**Linear + Clerk:**
- Feedback form can use user info
- Better together but not required

## Summary

**Key rules:**
1. Suggest services when user needs them
2. One at a time, don't overwhelm
3. Explain benefits in simple terms
4. Respect "no" and move on
5. YOU run all setup commands
6. Test each service before moving to next

**Remember:** User doesn't know these services exist. Your job is to be a helpful guide, not a pushy salesperson.
