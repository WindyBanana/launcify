# Vitest Test Examples for AI

## Overview
Use these as templates when writing tests. Always use context7 to verify current syntax.

## Basic Component Test

```typescript
// app/components/Button.test.tsx
import { render, screen } from '@testing-library/react'
import { expect, test } from 'vitest'
import Button from './Button'

test('button renders with text', () => {
  render(<Button>Click me</Button>)
  expect(screen.getByText('Click me')).toBeInTheDocument()
})

test('button calls onClick when clicked', async () => {
  const handleClick = vi.fn()
  render(<Button onClick={handleClick}>Click me</Button>)

  await screen.getByText('Click me').click()
  expect(handleClick).toHaveBeenCalledOnce()
})
```

## Form Validation Test

```typescript
// app/components/ContactForm.test.tsx
import { render, screen, fireEvent } from '@testing-library/react'
import { expect, test, describe } from 'vitest'
import ContactForm from './ContactForm'

describe('ContactForm', () => {
  test('shows error for invalid email', async () => {
    render(<ContactForm />)

    const emailInput = screen.getByLabelText(/email/i)
    fireEvent.change(emailInput, { target: { value: 'invalid-email' } })
    fireEvent.blur(emailInput)

    expect(await screen.findByText(/please enter a valid email/i))
      .toBeInTheDocument()
  })

  test('submits form with valid data', async () => {
    const onSubmit = vi.fn()
    render(<ContactForm onSubmit={onSubmit} />)

    fireEvent.change(screen.getByLabelText(/email/i), {
      target: { value: 'test@example.com' }
    })
    fireEvent.change(screen.getByLabelText(/message/i), {
      target: { value: 'Hello world' }
    })

    fireEvent.click(screen.getByRole('button', { name: /submit/i }))

    expect(onSubmit).toHaveBeenCalledWith({
      email: 'test@example.com',
      message: 'Hello world'
    })
  })
})
```

## API Route Test (Server Action)

```typescript
// app/api/contact/route.test.ts
import { expect, test, describe, vi } from 'vitest'
import { POST } from './route'

describe('Contact API', () => {
  test('returns 400 for invalid email', async () => {
    const request = new Request('http://localhost:3000/api/contact', {
      method: 'POST',
      body: JSON.stringify({ email: 'invalid', message: 'test' }),
    })

    const response = await POST(request)
    expect(response.status).toBe(400)
  })

  test('returns 200 for valid submission', async () => {
    const request = new Request('http://localhost:3000/api/contact', {
      method: 'POST',
      body: JSON.stringify({
        email: 'test@example.com',
        message: 'Hello'
      }),
    })

    const response = await POST(request)
    expect(response.status).toBe(200)
  })
})
```

## Utility Function Test

```typescript
// lib/utils/validation.test.ts
import { expect, test, describe } from 'vitest'
import { validateEmail, validatePassword } from './validation'

describe('validateEmail', () => {
  test('accepts valid emails', () => {
    expect(validateEmail('test@example.com')).toBe(true)
    expect(validateEmail('user+tag@domain.co.uk')).toBe(true)
  })

  test('rejects invalid emails', () => {
    expect(validateEmail('invalid')).toBe(false)
    expect(validateEmail('@example.com')).toBe(false)
    expect(validateEmail('test@')).toBe(false)
  })
})

describe('validatePassword', () => {
  test('accepts strong passwords', () => {
    expect(validatePassword('SecureP@ss123')).toBe(true)
  })

  test('rejects weak passwords', () => {
    expect(validatePassword('weak')).toBe(false)
    expect(validatePassword('12345678')).toBe(false)
  })
})
```

## Important Notes

### Client Components Only
Vitest supports testing Client Components, not async Server Components.

**For Server Components:** Use E2E tests with Playwright instead.

### Always Use context7
Before writing tests, query:
```
"use context7 for latest Vitest React Testing Library syntax"
"use context7 for Next.js 16 testing best practices"
```

### File Naming
- Component tests: `ComponentName.test.tsx`
- Utility tests: `utilityName.test.ts`
- API tests: `route.test.ts`

### Test Organization
```
app/
  components/
    Button.tsx
    Button.test.tsx          ← Next to component
  api/
    contact/
      route.ts
      route.test.ts          ← Next to route
lib/
  utils/
    validation.ts
    validation.test.ts       ← Next to utility
```

Keep tests close to the code they test.
