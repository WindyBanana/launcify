# Flexible Rules System

## Overview

NOT all code needs the same level of rigor. Match your approach to user's intent.

## Three Levels of Strictness

### Level 1: Quick Prototype 🚀

**When to use:**
- User says: "quick test", "just try", "see if this works", "demo"
- Learning/experimenting
- Throwaway code

**Rules:**
- ✅ One file is OK
- ✅ `any` type is acceptable for prototypes
- ✅ Inline styles are fine
- ✅ Hard-coded data is OK
- ✅ Skip tests (unless user chose "complete" testing mode)
- ⚠️ But warn: "This is prototype code. Want me to productionize it later?"

**Example:**
```typescript
// This is OK for quick prototyping
export default function QuickTest({ data }: any) {
  return (
    <div style={{ padding: '20px' }}>
      <h1>{data.title}</h1>
      <p>Hardcoded test data works here!</p>
    </div>
  )
}
```

---

### Level 2: Feature Development 🎯 (DEFAULT)

**When to use:**
- User says: "add a feature", "build", "create"
- No specific time pressure
- Intended for actual use

**Rules:**
- ✅ Separate components properly
- ✅ TypeScript with proper types (avoid `any`)
- ✅ Props interfaces required
- ✅ Proper file structure (see `.ai/structure/`)
- ✅ Basic error handling
- ⚠️ Can skip advanced patterns (optimization, memoization)

**Example:**
```typescript
// Feature development standard
interface UserCardProps {
  user: {
    name: string
    email: string
    avatar?: string
  }
  onSelect: (id: string) => void
}

export default function UserCard({ user, onSelect }: UserCardProps) {
  return (
    <div className="user-card">
      <h3>{user.name}</h3>
      <p>{user.email}</p>
      <button onClick={() => onSelect(user.id)}>
        Select
      </button>
    </div>
  )
}
```

---

### Level 3: Production Ready 🛡️

**When to use:**
- User says: "production ready", "final version", "deploy", "launch"
- Handling sensitive data (auth, payments)
- High-traffic features

**Rules:**
- ✅ Full TypeScript (NO `any` ever)
- ✅ Comprehensive error handling
- ✅ Input validation
- ✅ Accessibility (ARIA labels, keyboard nav)
- ✅ Performance optimization
- ✅ Security best practices
- ✅ Tests required (even if user chose "none" testing mode, suggest them)

**Example:**
```typescript
// Production-ready standard
import { z } from 'zod'

const UserSchema = z.object({
  name: z.string().min(1).max(100),
  email: z.string().email(),
  avatar: z.string().url().optional()
})

type User = z.infer<typeof UserSchema>

interface UserCardProps {
  user: User
  onSelect: (id: string) => Promise<void>
  'aria-label'?: string
}

export default function UserCard({
  user,
  onSelect,
  'aria-label': ariaLabel
}: UserCardProps) {
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const handleSelect = async () => {
    try {
      setLoading(true)
      setError(null)
      await onSelect(user.id)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to select user')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div
      className="user-card"
      role="article"
      aria-label={ariaLabel || `User card for ${user.name}`}
    >
      <h3>{user.name}</h3>
      <p>{user.email}</p>
      {error && (
        <p className="error" role="alert">
          {error}
        </p>
      )}
      <button
        onClick={handleSelect}
        disabled={loading}
        aria-busy={loading}
      >
        {loading ? 'Selecting...' : 'Select'}
      </button>
    </div>
  )
}
```

---

## Auto-Detection Keywords

### Prototype Mode Triggers:
"quick", "fast", "test", "try", "demo", "example", "draft", "experiment"

### Production Mode Triggers:
"production", "final", "deploy", "launch", "publish", "live", "real users"

### Default:
If unclear, use Level 2 (Feature Development)

---

## Ask When Unclear

If user intent is ambiguous:

```
"Should I build this as:
1. Quick prototype (fast, basic) - ~5 minutes
2. Proper feature (organized, typed) - ~15 minutes
3. Production ready (complete, optimized) - ~30 minutes

Default: Option 2"
```

---

## Special Cases

### User Says "Make it production ready"

Upgrade existing code:
1. Add proper TypeScript types
2. Add error handling
3. Add input validation
4. Add accessibility
5. Add tests
6. Optimize performance

Tell user: "Upgrading to production standards. This will take X minutes..."

### User Says "Just make it work quickly"

Downgrade to prototype if currently over-engineering:
```
"I was building this with full production practices. Since you want it quick,
I'll simplify to prototype level. You can always ask me to upgrade it later!"
```

---

## The `any` Type Rule

### When `any` is acceptable:
- ✅ Quick prototypes (Level 1)
- ✅ Temporary external library types (will fix later)
- ✅ Explicitly testing something unrelated to types

### When `any` is NOT acceptable:
- ❌ Feature development (Level 2)
- ❌ Production code (Level 3)
- ❌ Forms handling user input
- ❌ API responses
- ❌ Data that affects business logic

---

## Summary Decision Tree

```
Check user intent:

Keywords match prototype?
  → Level 1 (Quick Prototype)
  → Fast, basic, can use `any`
  → Warn it's prototype code

Keywords match production?
  → Level 3 (Production Ready)
  → Full best practices
  → No shortcuts

Neither/unclear?
  → Level 2 (Feature Development)
  → Balanced approach (default)
  → Proper structure, avoid `any`

Handling sensitive data (auth/payments)?
  → Override to Level 3 regardless
  → Explain why to user
```

---

## Remember

**Goal:** Match the code quality to user's actual needs.

- Don't over-engineer a quick test
- Don't under-engineer production features
- When in doubt, ask!

The user will appreciate code that matches their intent, not code that follows rules blindly.
