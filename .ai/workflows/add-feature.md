# Workflow: Adding a New Feature

## Overview
Use this workflow when user asks to add a feature to the application.

## IMPORTANT: Check Dependencies First

**Before starting any feature, YOU run:**

```bash
# Verify dependencies are installed
npm list

# If any missing, install immediately
npm install
```

**No permission needed** - just ensure project is ready.

## Steps

### 1. Understand the Request

**CRITICAL:** Read `.ai/ASK_DONT_ASSUME.md` if request is unclear!

Listen carefully to what user wants. **If vague or ambiguous, ASK!**

**When to ask clarifying questions:**
- Request is vague ("add features", "make it better")
- Multiple valid interpretations exist
- You're uncertain what they mean
- Technical implications user might not understand

**How to ask:**
- Present 2-4 short options (one line each)
- Use plain English, not jargon
- One question at a time
- See: `.ai/CLARIFYING_QUESTIONS_REFERENCE.md` for templates

**Example questions:**
- "Should this be accessible to all users or only logged-in users?"
- "Do you want this to save data permanently or just for this session?"
- "Should this work on mobile devices too?"

### 2. Check Testing Mode
Read: `.ai/testing/current-settings.json`

Know if you should:
- Write tests automatically (complete mode)
- Suggest tests (smart mode)
- Skip tests (none mode)

### 3. Determine Complexity Level
Read: `.ai/rules/flexible-rules.md`

Is this:
- **Level 1:** Quick prototype?
- **Level 2:** Proper feature? (default)
- **Level 3:** Production-ready?

### 4. Use Context7
Get current documentation:
```
use context7 for Next.js 16 [specific feature] implementation
```

### 5. Plan the Implementation
Think through what files you need:
- New page? → `app/[name]/page.tsx`
- New component? → `components/[category]/[Name].tsx`
- New API? → `app/api/[name]/route.ts`
- New types? → `lib/types/[name].ts`
- New utility? → `lib/utils/[name].ts`

Follow: `.ai/structure/project-structure.md`

### 6. Explain the Plan to User & Verify

**BEFORE writing any code, verify understanding:**

```
"I'll create a [feature name] for you.

This will:
- [What they get, point 1]
- [What they get, point 2]
- [What they won't get / limitation]

Takes about [time estimate].

Is this what you're looking for?"
```

**Wait for confirmation before proceeding!**

If user says "yes" → proceed
If user says "not quite" → ask more questions
If user is uncertain → present options again

### 7. Build the Feature

**If feature needs new packages:**

**YOU ask permission first:**
```
"This feature needs [package-name]. It's used for [purpose].
Should I install it?"
```

**After user confirms, YOU run:**
```bash
npm install [package-name]
```

**Then create files in this order:**
1. Types first (`lib/types/`)
2. Utilities if needed (`lib/utils/`)
3. Components (`components/`)
4. Pages or API routes (`app/`)
5. Tests last (if applicable)

**Follow structure from:** `.ai/structure/project-structure.md`

### 8. Write Tests (If Applicable)
Based on testing mode:
- **Complete:** Write tests automatically
- **Smart:** Suggest if feature is important
- **None:** Skip unless explicit request

**Refer to:** `.ai/testing/when-to-test.md`

### 9. Verify it Works
Check:
- ✅ TypeScript compiles (no errors)
- ✅ Component renders correctly
- ✅ Follows structure guidelines
- ✅ Uses current Next.js 16 patterns

### 10. Run the Dev Server & Verify It Works

**YOU run the dev server** - user should never run terminal commands.

```bash
npm run dev
```

**Then tell user AND verify:**

```
"✅ Done! I created your [feature name].

Here's what you got:
- [Feature aspect 1]
- [Feature aspect 2]
- [Feature aspect 3]

I've started the development server.
Go to: http://localhost:3000/[path]

Try it out and let me know:
1. Does it work as expected?
2. Should I adjust anything?
```

**IMPORTANT:** After user tests, ask if it matches what they wanted. If not, clarify and fix!

## Example: Adding a Blog

**User:** "Add a blog to my site"

**AI Response:**

**Step 1-3: Clarify & Plan**
```
"I'll add a blog! A few quick questions:

1. Should blog posts come from a database or markdown files?
   (Markdown is simpler to start)

2. Do you want:
   - Just a list of posts and individual post pages?
   - Or also: author pages, categories, search?

Let me know and I'll build it!"
```

**User:** "Markdown files, just list and post pages for now"

**Step 4-6: Explain Plan**
```
"Perfect! I'll create:
- A blog page showing all posts
- Individual pages for each post
- Will use markdown files in a 'content/posts/' folder
- Takes about 10 minutes

This will be a proper feature (not just a quick prototype).
I'll use TypeScript and proper structure.

Sound good?"
```

**Step 7-9: Build**
```typescript
// 1. Create types
// lib/types/blog.ts
export interface BlogPost {
  slug: string
  title: string
  date: string
  excerpt: string
  content: string
}

// 2. Create utility to read posts
// lib/utils/blog.ts
import fs from 'fs'
import path from 'path'
import matter from 'gray-matter'

export function getAllPosts(): BlogPost[] {
  // Implementation...
}

export function getPostBySlug(slug: string): BlogPost {
  // Implementation...
}

// 3. Create blog list page
// app/blog/page.tsx
import { getAllPosts } from '@/lib/utils/blog'
import BlogPostCard from '@/components/blog/BlogPostCard'

export default function BlogPage() {
  const posts = getAllPosts()

  return (
    <div>
      <h1>Blog</h1>
      {posts.map(post => (
        <BlogPostCard key={post.slug} post={post} />
      ))}
    </div>
  )
}

// 4. Create individual post page
// app/blog/[slug]/page.tsx
import { getPostBySlug } from '@/lib/utils/blog'

export default function BlogPostPage({ params }: { params: { slug: string } }) {
  const post = getPostBySlug(params.slug)

  return (
    <article>
      <h1>{post.title}</h1>
      <time>{post.date}</time>
      <div dangerouslySetInnerHTML={{ __html: post.content }} />
    </article>
  )
}

// 5. Create blog card component
// components/blog/BlogPostCard.tsx
import Link from 'next/link'
import type { BlogPost } from '@/lib/types/blog'

interface BlogPostCardProps {
  post: BlogPost
}

export default function BlogPostCard({ post }: BlogPostCardProps) {
  return (
    <article>
      <h2>
        <Link href={`/blog/${post.slug}`}>
          {post.title}
        </Link>
      </h2>
      <time>{post.date}</time>
      <p>{post.excerpt}</p>
    </article>
  )
}
```

**Step 10: Run & Explain**

**YOU run:**
```bash
npm run dev
```

**Then tell user:**
```
"✅ Blog is ready!

What you got:
- /blog page showing all your posts
- Individual pages for each post (like /blog/my-first-post)
- Reads from markdown files in content/posts/

To add a new post, just tell me and I'll create it for you!
Or if you want to create one yourself:
- Create a file: content/posts/my-post.md
- Add front matter and content

I've started the dev server.
Go to: http://localhost:3000/blog

Want me to create an example post for you?"
```

## Key Principles

1. **Plan before coding** - Think through structure
2. **Explain what you'll do** - Get user buy-in
3. **Follow structure** - Use proper organization
4. **Use context7** - Get current APIs
5. **Explain what you built** - Help user understand

Remember: User is NOT a developer. Make every explanation clear and encouraging!
