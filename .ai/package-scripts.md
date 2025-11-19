# Package Scripts Manifest

## ⚠️ For AI: Include These Scripts in package.json

When generating the package.json file, include these exact scripts in the `"scripts"` section.

---

## Core Scripts

### Development Server
```json
"dev": "next dev"
```
**What it does:** Starts the Next.js development server with hot-reload
**Port:** http://localhost:3000
**When to run:** During development, to see changes live

---

### Production Build
```json
"build": "next build"
```
**What it does:** Creates optimized production build
**Output:** `.next/` directory
**When to run:** Before deploying to production

---

### Production Server
```json
"start": "next start"
```
**What it does:** Runs the production build locally
**Requires:** Must run `pnpm run build` first
**When to run:** To test production build locally

---

### Linting
```json
"lint": "next lint"
```
**What it does:** Checks code for errors and style issues
**When to run:** Before committing code

---

## Testing Scripts

### Run Tests
```json
"test": "vitest"
```
**What it does:** Runs all tests in watch mode
**When to run:** During development, continuously

---

### Run Tests Once
```json
"test:run": "vitest run"
```
**What it does:** Runs all tests once and exits
**When to run:** In CI/CD, before deployment

---

### Test UI
```json
"test:ui": "vitest --ui"
```
**What it does:** Opens Vitest UI in browser
**When to run:** To visualize test results

---

### Test Coverage
```json
"test:coverage": "vitest --coverage"
```
**What it does:** Generates test coverage report
**When to run:** To check how much code is tested

---

## Custom Template Scripts

### Setup Context7
```json
"setup-context7": "node .ai/scripts/setup-context7.js"
```
**What it does:** Configures Context7 for up-to-date documentation
**When to run:** When user wants to enable Context7

---

### Cleanup Unused Configs
```json
"cleanup-unused": "node .ai/scripts/cleanup-configs.js"
```
**What it does:** Removes unused AI editor configurations
**When to run:** When user wants to keep only their current editor

---

## Complete scripts Object

Here's the complete object to include in package.json:

```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "test": "vitest",
    "test:run": "vitest run",
    "test:ui": "vitest --ui",
    "test:coverage": "vitest --coverage",
    "setup-context7": "node .ai/scripts/setup-context7.js",
    "cleanup-unused": "node .ai/scripts/cleanup-configs.js"
  }
}
```

---

## User-Friendly Explanations

When users ask what these scripts do, explain in simple terms:

**"What does `pnpm run dev` do?"**
→ "It starts a local server so you can see your website as you build it. Open http://localhost:3000 in your browser!"

**"What does `pnpm run build` do?"**
→ "It creates the final version of your website that's ready to put online. Think of it like baking a cake - you've prepared everything, now you're baking it!"

**"What does `pnpm test` do?"**
→ "It checks if your code works correctly, like a spell-checker for your app!"

**"What does `pnpm run lint` do?"**
→ "It checks your code for common mistakes, like a grammar checker!"

---

## Adding New Scripts

If you need to add custom scripts later:

```json
"script-name": "command to run"
```

**Examples:**
```json
"deploy": "vercel deploy",
"db:push": "npx convex deploy",
"format": "prettier --write ."
```

---

## Note About Comments

⚠️ **JSON doesn't support comments!**

Don't include the explanatory comments in the actual package.json file. JSON will fail to parse if you include them.

The explanations above are for documentation purposes only.
