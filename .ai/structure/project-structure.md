# Project Structure Guide for AI

## MANDATORY: Follow This Structure

This guide ensures consistent, scalable project organization.

## Directory Structure

```
app/                          # Next.js 16 App Router
├── (auth)/                   # Route group: Auth pages
│   ├── login/
│   │   └── page.tsx
│   └── signup/
│       └── page.tsx
├── (marketing)/              # Route group: Public pages
│   ├── about/
│   ├── pricing/
│   └── contact/
├── (dashboard)/              # Route group: Protected pages
│   ├── layout.tsx            # Dashboard layout
│   ├── page.tsx              # Dashboard home
│   └── settings/
├── api/                      # API routes
│   ├── auth/
│   ├── users/
│   └── contact/
├── layout.tsx                # Root layout
├── page.tsx                  # Home page
└── globals.css               # Global styles

components/                   # React components
├── ui/                       # Base UI components (shadcn/ui)
│   ├── button.tsx
│   ├── card.tsx
│   ├── input.tsx
│   └── ...
├── forms/                    # Form components
│   ├── ContactForm.tsx
│   ├── LoginForm.tsx
│   └── ...
├── layout/                   # Layout components
│   ├── Header.tsx
│   ├── Footer.tsx
│   ├── Sidebar.tsx
│   └── ...
├── marketing/                # Marketing-specific components
│   ├── Hero.tsx
│   ├── Features.tsx
│   └── ...
└── dashboard/                # Dashboard-specific components
    ├── Stats.tsx
    ├── Chart.tsx
    └── ...

lib/                          # Utilities and helpers
├── utils/                    # Utility functions
│   ├── format.ts
│   ├── validation.ts
│   └── ...
├── hooks/                    # Custom React hooks
│   ├── useAuth.ts
│   ├── useDebounce.ts
│   └── ...
├── services/                 # API/external service integrations
│   ├── api.ts
│   ├── database.ts
│   └── ...
└── types/                    # TypeScript type definitions
    ├── user.ts
    ├── api.ts
    └── ...

public/                       # Static assets
├── images/
├── icons/
└── fonts/

.ai/                          # AI assistant instructions
├── MANDATORY_READ_FIRST.md
├── onboarding/
├── testing/
├── rules/
├── workflows/
└── services/
```

---

## File Creation Rules

### Rule 1: New Page

**User asks:** "Add an about page"

**Actions:**
1. Create: `app/about/page.tsx` (or `app/(marketing)/about/page.tsx`)
2. Create components: `components/marketing/AboutHero.tsx`, etc. (if needed)
3. Create types: `lib/types/about.ts` (if custom data needed)

**Example:**
```typescript
// app/about/page.tsx
import AboutHero from '@/components/marketing/AboutHero'
import TeamSection from '@/components/marketing/TeamSection'

export const metadata = {
  title: 'About Us',
  description: 'Learn about our company'
}

export default function AboutPage() {
  return (
    <>
      <AboutHero />
      <TeamSection />
    </>
  )
}
```

### Rule 2: New Component

**User asks:** "Add a pricing card"

**Decision tree:**
1. Is it a base UI element? → `components/ui/`
2. Is it a form? → `components/forms/`
3. Is it for marketing? → `components/marketing/`
4. Is it for dashboard? → `components/dashboard/`
5. Is it layout-related? → `components/layout/`

**Example:**
```typescript
// components/marketing/PricingCard.tsx
interface PricingCardProps {
  title: string
  price: number
  features: string[]
  highlighted?: boolean
}

export default function PricingCard({
  title,
  price,
  features,
  highlighted = false
}: PricingCardProps) {
  return (
    <div className={highlighted ? 'pricing-card-highlighted' : 'pricing-card'}>
      <h3>{title}</h3>
      <p className="price">${price}/month</p>
      <ul>
        {features.map((feature, i) => (
          <li key={i}>{feature}</li>
        ))}
      </ul>
    </div>
  )
}
```

### Rule 3: New Form

**User asks:** "Add a contact form"

**Actions:**
1. Create: `components/forms/ContactForm.tsx`
2. Create API: `app/api/contact/route.ts`
3. Create types: `lib/types/contact.ts`
4. Create validation: `lib/utils/validation.ts` (add validation function)
5. Create test: `components/forms/ContactForm.test.tsx` (if testing enabled)

**Example:**
```typescript
// lib/types/contact.ts
export interface ContactFormData {
  name: string
  email: string
  message: string
}

// components/forms/ContactForm.tsx
'use client'

import { useState } from 'react'
import type { ContactFormData } from '@/lib/types/contact'

export default function ContactForm() {
  const [formData, setFormData] = useState<ContactFormData>({
    name: '',
    email: '',
    message: ''
  })
  const [status, setStatus] = useState<'idle' | 'loading' | 'success' | 'error'>('idle')

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setStatus('loading')

    try {
      const res = await fetch('/api/contact', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData)
      })

      if (!res.ok) throw new Error('Failed to submit')

      setStatus('success')
      setFormData({ name: '', email: '', message: '' })
    } catch (error) {
      setStatus('error')
    }
  }

  return (
    <form onSubmit={handleSubmit}>
      {/* Form fields */}
    </form>
  )
}

// app/api/contact/route.ts
import { NextResponse } from 'next/server'
import type { ContactFormData } from '@/lib/types/contact'

export async function POST(request: Request) {
  try {
    const data: ContactFormData = await request.json()

    // Validate
    if (!data.email || !data.message) {
      return NextResponse.json(
        { error: 'Missing required fields' },
        { status: 400 }
      )
    }

    // Process (send email, save to DB, etc.)
    // ...

    return NextResponse.json({ success: true })
  } catch (error) {
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}
```

### Rule 4: Utility Function

**User asks:** "Add email validation"

**Actions:**
1. Add to: `lib/utils/validation.ts`
2. Add types: `lib/types/validation.ts` (if complex)
3. Add test: `lib/utils/validation.test.ts` (if testing enabled)

**Example:**
```typescript
// lib/utils/validation.ts
export function validateEmail(email: string): boolean {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  return emailRegex.test(email)
}

export function validatePassword(password: string): boolean {
  // At least 8 chars, 1 uppercase, 1 lowercase, 1 number
  return (
    password.length >= 8 &&
    /[A-Z]/.test(password) &&
    /[a-z]/.test(password) &&
    /[0-9]/.test(password)
  )
}
```

---

## Naming Conventions

### Files

| Type | Convention | Example |
|------|------------|---------|
| Pages | `page.tsx` | `app/about/page.tsx` |
| Layouts | `layout.tsx` | `app/(dashboard)/layout.tsx` |
| Components | `PascalCase.tsx` | `ContactForm.tsx` |
| Utilities | `camelCase.ts` | `formatDate.ts` |
| Types | `camelCase.ts` | `user.ts` |
| Tests | `*.test.tsx` | `ContactForm.test.tsx` |
| API Routes | `route.ts` | `app/api/users/route.ts` |

### Exports

```typescript
// Components: default export
export default function ContactForm() {}

// Utilities: named exports
export function formatDate() {}
export function parseDate() {}

// Types: named exports
export interface User {}
export type UserRole = 'admin' | 'user'
```

---

## Route Groups (Next.js 16)

Use route groups to organize pages without affecting URLs:

```
app/
├── (auth)/          # URL: /login, /signup
│   ├── login/
│   └── signup/
├── (marketing)/     # URL: /about, /pricing
│   ├── about/
│   └── pricing/
└── (dashboard)/     # URL: /dashboard, /settings
    ├── layout.tsx   # Shared dashboard layout
    ├── page.tsx
    └── settings/
```

---

## TypeScript Patterns

### Props Interfaces

```typescript
// Always define props interface
interface ComponentNameProps {
  // Required props first
  title: string
  onClick: () => void

  // Optional props last
  className?: string
  children?: React.ReactNode
}

export default function ComponentName({
  title,
  onClick,
  className,
  children
}: ComponentNameProps) {
  // Component code
}
```

### Type Imports

```typescript
// Use type imports for types only
import type { User } from '@/lib/types/user'
import type { ComponentProps } from 'react'

// Regular imports for values
import { formatDate } from '@/lib/utils/format'
```

---

## Before Creating ANY File

Ask yourself:
1. **What category?** (component/utility/page/type)
2. **Existing file to modify?** (Don't create if you can extend)
3. **Right location?** (Follow structure above)
4. **Proper naming?** (Follow conventions above)
5. **Easy to find later?** (Will make sense in 50 files)

When in doubt, check `.ai/examples/` for similar patterns.

---

## Use Context7

Always verify current Next.js 16 patterns:
- `use context7 for Next.js 16 App Router file structure`
- `use context7 for Next.js 16 route groups`
- `use context7 for Next.js 16 API routes`
