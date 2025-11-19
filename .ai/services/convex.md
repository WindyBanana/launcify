# Service Setup: Convex Database

## When to Suggest This

**Suggest Convex when user mentions:**
- "Save data" or "store information"
- "Database" or "persistent storage"
- "Remember user choices"
- "Save posts/comments/etc."
- Real-time features (chat, notifications)

**Proactively suggest when:**
- User creates forms that should save data
- User mentions needing data across sessions
- User wants real-time updates

## What is Convex? (ELI5)

```
"Convex is like a smart filing cabinet for your app's data.

Instead of data disappearing when you refresh the page, Convex:
- Saves everything permanently
- Lets you search and find data quickly
- Updates all users in real-time (like Google Docs)
- Works automatically with your React components

It's free with 1 million function calls/month and handles all the database complexity for you."
```

## Setup Process

### Step 1: Explain to User

```
"I'll add Convex as your database. This lets you:

✅ What you get:
- Store data permanently (users, posts, etc.)
- Real-time updates (changes appear instantly)
- Built-in authentication support
- Free tier: 1 million function calls/month

⚠️ Setup requires:
- Free Convex account (1 minute signup)
- Takes about 10 minutes total

Sound good?"
```

### Step 2: Install Convex

**After user confirms, YOU run:**

```bash
pnpm install convex
```

**Tell user:**
```
"Installing Convex... (~30 seconds)"
```

### Step 3: Initialize Convex

**YOU run:**

```bash
npx convex dev
```

**This will:**
1. Prompt user to log in/sign up
2. Create a new Convex project
3. Set up local dev environment

**Tell user:**

```
"I'm initializing Convex. You'll see a browser window open.

If you don't have a Convex account:
1. Click 'Sign up with GitHub' (fastest)
2. Authorize Convex

If you already have an account:
1. Just log in

After that, come back here - I'll handle the rest!"
```

**After user authorizes:**

```
"Great! Convex is setting up your project..."

[npx convex dev will create convex/ folder and .env.local]

"Setup complete!"
```

### Step 4: YOU Create Database Schema

**YOU create convex/schema.ts:**

```typescript
import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

export default defineSchema({
  // Example: Tasks table
  tasks: defineTable({
    text: v.string(),
    isCompleted: v.boolean(),
    userId: v.optional(v.string()),
  }).index("by_user", ["userId"]),
});
```

**Tell user:**

```
"I've created a database schema for you. This defines what data you can store.

I added an example 'tasks' table. We can modify this based on what you need!"
```

### Step 5: YOU Create Query/Mutation Examples

**YOU create convex/tasks.ts:**

```typescript
import { query, mutation } from "./_generated/server";
import { v } from "convex/values";

// Get all tasks
export const get = query({
  args: {},
  handler: async (ctx) => {
    return await ctx.db.query("tasks").collect();
  },
});

// Add a new task
export const add = mutation({
  args: { text: v.string() },
  handler: async (ctx, args) => {
    const taskId = await ctx.db.insert("tasks", {
      text: args.text,
      isCompleted: false,
    });
    return taskId;
  },
});

// Toggle task completion
export const toggle = mutation({
  args: { id: v.id("tasks") },
  handler: async (ctx, args) => {
    const task = await ctx.db.get(args.id);
    if (task) {
      await ctx.db.patch(args.id, { isCompleted: !task.isCompleted });
    }
  },
});

// Delete a task
export const remove = mutation({
  args: { id: v.id("tasks") },
  handler: async (ctx, args) => {
    await ctx.db.delete(args.id);
  },
});
```

### Step 6: YOU Set Up Provider

**YOU update app/layout.tsx:**

```typescript
"use client";

import { ConvexProvider, ConvexReactClient } from "convex/react";

const convex = new ConvexReactClient(process.env.NEXT_PUBLIC_CONVEX_URL!);

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>
        <ConvexProvider client={convex}>
          {children}
        </ConvexProvider>
      </body>
    </html>
  );
}
```

### Step 7: YOU Create Example Component

**YOU create components/TaskList.tsx:**

```typescript
"use client";

import { useQuery, useMutation } from "convex/react";
import { api } from "../convex/_generated/api";
import { useState } from "react";

export default function TaskList() {
  const tasks = useQuery(api.tasks.get);
  const addTask = useMutation(api.tasks.add);
  const toggleTask = useMutation(api.tasks.toggle);
  const removeTask = useMutation(api.tasks.remove);

  const [newTask, setNewTask] = useState("");

  const handleAdd = async (e: React.FormEvent) => {
    e.preventDefault();
    if (newTask.trim()) {
      await addTask({ text: newTask });
      setNewTask("");
    }
  };

  return (
    <div className="max-w-md mx-auto p-4">
      <h1 className="text-2xl font-bold mb-4">Tasks</h1>

      <form onSubmit={handleAdd} className="flex gap-2 mb-4">
        <input
          type="text"
          value={newTask}
          onChange={(e) => setNewTask(e.target.value)}
          placeholder="Add a task..."
          className="flex-1 px-3 py-2 border rounded"
        />
        <button
          type="submit"
          className="px-4 py-2 bg-blue-500 text-white rounded"
        >
          Add
        </button>
      </form>

      {tasks === undefined ? (
        <p>Loading...</p>
      ) : (
        <ul className="space-y-2">
          {tasks.map((task) => (
            <li key={task._id} className="flex items-center gap-2">
              <input
                type="checkbox"
                checked={task.isCompleted}
                onChange={() => toggleTask({ id: task._id })}
              />
              <span className={task.isCompleted ? "line-through" : ""}>
                {task.text}
              </span>
              <button
                onClick={() => removeTask({ id: task._id })}
                className="ml-auto text-red-500"
              >
                Delete
              </button>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
```

### Step 8: YOU Test It

**YOU ensure `npx convex dev` is running:**

```bash
# Check if it's running, if not start it
npx convex dev
```

**YOU run dev server:**

```bash
pnpm run dev
```

**Tell user:**

```
"Testing Convex... Your app is running at http://localhost:3000

Try:
1. Add a task
2. Check it off
3. Refresh the page - it should still be there!

That's Convex saving your data. Does it work?"
```

## Common Use Cases

### Custom Data Model

**User says:** "I need to store blog posts"

**YOU update convex/schema.ts:**

```typescript
export default defineSchema({
  posts: defineTable({
    title: v.string(),
    content: v.string(),
    author: v.string(),
    publishedAt: v.number(),
  }).index("by_published", ["publishedAt"]),
});
```

**YOU create convex/posts.ts:**

```typescript
import { query, mutation } from "./_generated/server";
import { v } from "convex/values";

export const list = query({
  args: {},
  handler: async (ctx) => {
    return await ctx.db
      .query("posts")
      .order("desc")
      .collect();
  },
});

export const create = mutation({
  args: {
    title: v.string(),
    content: v.string(),
    author: v.string(),
  },
  handler: async (ctx, args) => {
    return await ctx.db.insert("posts", {
      ...args,
      publishedAt: Date.now(),
    });
  },
});
```

### User-Specific Data (with Clerk)

**YOU update query to filter by user:**

```typescript
import { query } from "./_generated/server";

export const getUserTasks = query({
  args: {},
  handler: async (ctx) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) return [];

    return await ctx.db
      .query("tasks")
      .filter((q) => q.eq(q.field("userId"), identity.subject))
      .collect();
  },
});
```

## For Deployment (Vercel)

**When deploying, YOU tell user:**

```
"Convex needs to be set up for production:

1. Go to https://dashboard.convex.dev
2. Find your project
3. Click 'Settings' → 'Deploy Key'
4. Copy the production URL

In Vercel:
1. Project → Settings → Environment Variables
2. Add:
   NEXT_PUBLIC_CONVEX_URL = [production URL]
3. Save
4. Redeploy

I'll push the code now..."
```

**YOU run:**

```bash
git add .
git commit -m "Add Convex database"
git push
```

## Common Issues

### "ConvexProvider not found"

**YOU check:**

```bash
npm list convex
```

**If not installed:**

```bash
pnpm install convex
```

### "npx convex dev" not running

**YOU check if process is running:**

```bash
ps aux | grep convex
```

**If not running, YOU start it:**

```bash
npx convex dev
```

**Tell user:**

```
"Convex dev server needs to be running. I've started it.

Keep this terminal open while developing!"
```

### Schema Changes Not Applied

**YOU run:**

```bash
npx convex dev --clear-all
```

**Tell user:**

```
"I'm clearing Convex's cache and reapplying the schema.
Your data will be reset - is that okay?"
```

## Real-Time Features

**User asks:** "Make it update live for all users"

**Explain:**

```
"Convex already does this! When one user adds a task,
it appears instantly for everyone else who's viewing the page.

That's the magic of Convex - real-time updates are built-in.
No extra code needed!"
```

## Summary for AI

**When user needs a database:**
1. Explain Convex in simple terms (smart filing cabinet)
2. Ask permission
3. **YOU run `pnpm install convex`**
4. **YOU run `npx convex dev`** (user logs in via browser)
5. **YOU create schema and queries**
6. **YOU set up provider**
7. **YOU create example component**
8. **YOU test it**

**User's role:** Sign up via browser, test the feature
**Your role:** Install, configure, create schema, test

**Convex dev server:** Must stay running during development
**NO SCRIPTS for users** - you handle all commands
