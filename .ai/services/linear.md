# Service Setup: Linear for Customer Feedback

## When to Suggest This

**Suggest Linear when user mentions:**
- "Let users report bugs"
- "Feedback form" or "feature requests"
- "How do I track issues?"
- "Users want to suggest features"
- App has launched and has users

**Proactively suggest when:**
- User deploys app to production
- User asks "how do I know what users want?"
- User has authentication set up (users can submit feedback)

## What is Linear? (ELI5)

```
"Linear is like a suggestion box for your app.

Users can:
- Report bugs they find
- Request new features
- Upvote others' suggestions

You can:
- See all feedback in one place
- Prioritize what to build next
- Update users when you fix/build something
- Track your progress on each issue

It's free with 250 active issues (unlimited team members) and keeps you organized!"
```

## Setup Process

### Step 1: Explain to User

```
"I'll add a feedback system with Linear. This lets users:

✅ What you get:
- Bug report form
- Feature request system
- Track all issues in Linear dashboard
- Notify users when you fix things
- Free with 250 active issues (unlimited team members)

⚠️ Setup requires:
- Free Linear account (1 minute)
- API key from Linear
- Takes about 10 minutes

Sound good?"
```

### Step 2: Install SDK

**After user confirms, YOU run:**

```bash
pnpm install @linear/sdk
```

**Tell user:**
```
"Installing Linear SDK..."
```

### Step 3: Guide User to Setup Linear

```
"Let's set up Linear:

1. Go to: https://linear.app
2. Click 'Get Started' → Sign up with GitHub (fastest)
3. Create a workspace:
   - Name: [Your App Name]
   - Click 'Continue'
4. Create your first team:
   - Name: 'Product' or 'Engineering'
   - Click 'Create team'
5. Get your API key:
   - Click Settings → API → Personal API keys
   - Click 'Create key'
   - Name: 'App Feedback Integration'
   - Click 'Create'
   - Copy the key

Got the key? Paste it when I prompt you..."
```

### Step 4: YOU Add to .env.local

**YOU update .env.local:**

```bash
cat >> .env.local << 'EOF'

# Linear
LINEAR_API_KEY=[user-provides-key]
LINEAR_TEAM_ID=[user-provides-team-id]
EOF
```

**YOU guide user to get team ID:**

```
"Now I need your Team ID:

In Linear:
1. Go to your team settings
2. Look at the URL: linear.app/[workspace]/team/[TEAM_ID]/...
3. Copy that TEAM_ID part

Paste it here:
[Wait for input]

Perfect!"
```

### Step 5: YOU Create Linear Client

**YOU create lib/linear.ts:**

```typescript
import { LinearClient } from '@linear/sdk';

if (!process.env.LINEAR_API_KEY) {
  throw new Error('LINEAR_API_KEY is not set');
}

export const linearClient = new LinearClient({
  apiKey: process.env.LINEAR_API_KEY,
});

export const LINEAR_TEAM_ID = process.env.LINEAR_TEAM_ID || '';

// Helper to create a bug report
export async function createBugReport({
  title,
  description,
  userEmail,
}: {
  title: string;
  description: string;
  userEmail?: string;
}) {
  const team = await linearClient.team(LINEAR_TEAM_ID);

  const labels = await team.labels();
  const bugLabel = labels.nodes.find((l) => l.name.toLowerCase() === 'bug');

  return await linearClient.createIssue({
    teamId: LINEAR_TEAM_ID,
    title,
    description: `${description}\n\n---\nReported by: ${userEmail || 'Anonymous'}`,
    priority: 3, // Medium priority
    labelIds: bugLabel ? [bugLabel.id] : [],
  });
}

// Helper to create a feature request
export async function createFeatureRequest({
  title,
  description,
  userEmail,
}: {
  title: string;
  description: string;
  userEmail?: string;
}) {
  const team = await linearClient.team(LINEAR_TEAM_ID);

  const labels = await team.labels();
  const featureLabel = labels.nodes.find(
    (l) => l.name.toLowerCase() === 'feature'
  );

  return await linearClient.createIssue({
    teamId: LINEAR_TEAM_ID,
    title,
    description: `${description}\n\n---\nRequested by: ${userEmail || 'Anonymous'}`,
    priority: 4, // Low priority initially
    labelIds: featureLabel ? [featureLabel.id] : [],
  });
}
```

### Step 6: YOU Create API Routes

**YOU create app/api/feedback/bug/route.ts:**

```typescript
import { NextResponse } from 'next/server';
import { createBugReport } from '@/lib/linear';

export async function POST(request: Request) {
  try {
    const { title, description, email } = await request.json();

    if (!title || !description) {
      return NextResponse.json(
        { error: 'Title and description required' },
        { status: 400 }
      );
    }

    const issue = await createBugReport({
      title,
      description,
      userEmail: email,
    });

    return NextResponse.json({
      success: true,
      issueId: issue.issue?.id,
      message: 'Bug report submitted successfully',
    });
  } catch (error) {
    console.error('Error creating bug report:', error);
    return NextResponse.json(
      { error: 'Failed to submit bug report' },
      { status: 500 }
    );
  }
}
```

**YOU create app/api/feedback/feature/route.ts:**

```typescript
import { NextResponse } from 'next/server';
import { createFeatureRequest } from '@/lib/linear';

export async function POST(request: Request) {
  try {
    const { title, description, email } = await request.json();

    if (!title || !description) {
      return NextResponse.json(
        { error: 'Title and description required' },
        { status: 400 }
      );
    }

    const issue = await createFeatureRequest({
      title,
      description,
      userEmail: email,
    });

    return NextResponse.json({
      success: true,
      issueId: issue.issue?.id,
      message: 'Feature request submitted successfully',
    });
  } catch (error) {
    console.error('Error creating feature request:', error);
    return NextResponse.json(
      { error: 'Failed to submit feature request' },
      { status: 500 }
    );
  }
}
```

### Step 7: YOU Create Feedback Form

**YOU create components/FeedbackForm.tsx:**

```typescript
'use client';

import { useState } from 'react';

export default function FeedbackForm() {
  const [type, setType] = useState<'bug' | 'feature'>('bug');
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [email, setEmail] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [success, setSuccess] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);

    try {
      const endpoint = type === 'bug' ? '/api/feedback/bug' : '/api/feedback/feature';

      const res = await fetch(endpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ title, description, email }),
      });

      if (res.ok) {
        setSuccess(true);
        setTitle('');
        setDescription('');
        setEmail('');
        setTimeout(() => setSuccess(false), 3000);
      }
    } catch (error) {
      console.error('Error submitting feedback:', error);
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="max-w-2xl mx-auto p-6">
      <h2 className="text-2xl font-bold mb-4">Send Feedback</h2>

      <div className="flex gap-4 mb-6">
        <button
          onClick={() => setType('bug')}
          className={`px-4 py-2 rounded ${
            type === 'bug'
              ? 'bg-red-500 text-white'
              : 'bg-gray-200 text-gray-700'
          }`}
        >
          Report a Bug
        </button>
        <button
          onClick={() => setType('feature')}
          className={`px-4 py-2 rounded ${
            type === 'feature'
              ? 'bg-blue-500 text-white'
              : 'bg-gray-200 text-gray-700'
          }`}
        >
          Request a Feature
        </button>
      </div>

      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label className="block font-medium mb-2">
            {type === 'bug' ? 'Bug Title' : 'Feature Title'}
          </label>
          <input
            type="text"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            required
            className="w-full px-3 py-2 border rounded"
            placeholder={
              type === 'bug'
                ? 'Button doesn\'t work on mobile'
                : 'Add dark mode'
            }
          />
        </div>

        <div>
          <label className="block font-medium mb-2">Description</label>
          <textarea
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            required
            rows={6}
            className="w-full px-3 py-2 border rounded"
            placeholder={
              type === 'bug'
                ? 'Describe what happened and what you expected...'
                : 'Describe the feature and how it would help...'
            }
          />
        </div>

        <div>
          <label className="block font-medium mb-2">Email (optional)</label>
          <input
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            className="w-full px-3 py-2 border rounded"
            placeholder="your@email.com"
          />
          <p className="text-sm text-gray-600 mt-1">
            We'll notify you when we address this
          </p>
        </div>

        <button
          type="submit"
          disabled={submitting}
          className="w-full px-6 py-3 bg-blue-500 text-white rounded font-medium hover:bg-blue-600 disabled:opacity-50"
        >
          {submitting ? 'Submitting...' : 'Submit Feedback'}
        </button>

        {success && (
          <p className="text-green-600 text-center font-medium">
            Thank you! We've received your feedback.
          </p>
        )}
      </form>
    </div>
  );
}
```

### Step 8: YOU Add Feedback Page

**YOU create app/feedback/page.tsx:**

```typescript
import FeedbackForm from '@/components/FeedbackForm';

export default function FeedbackPage() {
  return (
    <main className="min-h-screen py-12">
      <FeedbackForm />
    </main>
  );
}
```

### Step 9: YOU Test It

**YOU ensure Linear labels exist:**

```
"Before testing, make sure you have labels in Linear:

1. Go to Linear → Settings → Labels
2. Create two labels if they don't exist:
   - Name: 'Bug', Color: Red
   - Name: 'Feature', Color: Blue

Done? Great! Now let's test..."
```

**YOU run:**

```bash
pnpm run dev
```

**Tell user:**

```
"Testing Linear integration...

Go to: http://localhost:3000/feedback

Try:
1. Report a test bug
2. Submit it
3. Go to Linear → Your team inbox
4. You should see the issue!

See it? If yes, Linear is working!"
```

## Common Use Cases

### Add Feedback Button to App

**YOU add to layout/header:**

```typescript
import Link from 'next/link';

export default function Header() {
  return (
    <header>
      <nav>
        <Link
          href="/feedback"
          className="px-3 py-2 text-sm bg-gray-100 rounded"
        >
          Send Feedback
        </Link>
      </nav>
    </header>
  );
}
```

### Get User Info from Clerk

**YOU update to include user info:**

```typescript
import { currentUser } from '@clerk/nextjs/server';

export async function POST(request: Request) {
  const user = await currentUser();

  const issue = await createBugReport({
    title,
    description,
    userEmail: user?.emailAddresses[0]?.emailAddress || 'Anonymous',
  });
}
```

## For Deployment (Vercel)

**When deploying:**

```
"For Linear to work on Vercel:

In Vercel dashboard:
1. Project → Settings → Environment Variables
2. Add:
   LINEAR_API_KEY = [your-api-key]
   LINEAR_TEAM_ID = [your-team-id]
3. Save
4. Redeploy

I'll push the code..."
```

**YOU run:**

```bash
git add .
git commit -m "Add Linear feedback integration"
git push
```

## Managing Feedback

**Tell user how to use Linear:**

```
"To manage feedback in Linear:

1. Go to https://linear.app
2. Your team inbox shows all new issues
3. You can:
   - Assign issues to yourself
   - Set priority (Urgent → Low)
   - Add to cycles/projects
   - Comment and update status
   - Close when fixed

Set up views:
- Active → Settings → Views → New View
- Filter: Status is "Todo" or "In Progress"
- Group by: Priority
```

## Summary for AI

**When user needs feedback system:**
1. Explain Linear (suggestion box for app)
2. Ask permission
3. **YOU run `pnpm install @linear/sdk`**
4. Guide user to get API key and team ID
5. **YOU create Linear client and helpers**
6. **YOU create API routes**
7. **YOU create feedback form**
8. **YOU test it**

**User's role:** Sign up, get keys, manage issues
**Your role:** Install, configure, create forms, test

**NO SCRIPTS for users** - you do everything
