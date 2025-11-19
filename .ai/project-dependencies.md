# Project Dependencies Manifest

## ⚠️ IMPORTANT: This File Replaces package.json

This template intentionally **does not include a package.json file**.

**Why?** When you create a project from this template, you get the **latest stable versions** of all dependencies, not outdated versions from months ago.

**Your job (AI):** On first interaction, read this file and generate a fresh package.json with the latest stable versions.

---

## Required Dependencies

These are the core runtime dependencies the project needs:

### 1. Next.js (Latest Stable)
```
Package: next
Version: latest stable (16.x or newer)
Why: React framework for web applications
Docs: https://nextjs.org/docs
```

### 2. React (Latest Stable)
```
Package: react
Version: latest stable (19.x or newer)
Why: UI library
Note: Must match react-dom version
Docs: https://react.dev
```

### 3. React DOM (Latest Stable)
```
Package: react-dom
Version: latest stable (19.x or newer)
Why: React renderer for web
Note: Must match react version
Docs: https://react.dev
```

---

## Required Dev Dependencies

These are development tools needed to build and test the project:

### TypeScript & Type Definitions

```
Packages:
- typescript (latest stable, 5.x or newer)
- @types/node (latest)
- @types/react (latest, must match react version)
- @types/react-dom (latest, must match react-dom version)

Why: Type safety and better IDE support
```

### Styling

```
Packages:
- tailwindcss (version: "^3.4.0" - pinned to v3 until v4 is fully stable)
- postcss (latest stable)
- autoprefixer (latest stable)

Why: Utility-first CSS framework

IMPORTANT: Use "^3.4.0" for tailwindcss (not "latest") to avoid breaking changes from Tailwind v4.
Tailwind v4 requires @tailwindcss/postcss and has different configuration.
Once Tailwind v4 is stable and tested, update this range.
```

### Testing

```
Packages:
- vitest (latest stable, 2.x or newer)
- @vitest/ui (latest, matches vitest version)
- @testing-library/react (latest)
- @testing-library/dom (latest)
- @vitejs/plugin-react (latest)
- jsdom (latest)

Why: Testing framework and utilities
```

### Linting

```
Packages:
- eslint (latest stable, 9.x or newer)
- eslint-config-next (latest, matches next version)

Why: Code quality and consistency
```

---

## Package Metadata

When generating package.json, use these values:

```json
{
  "name": "[folder-name]-app",
  "version": "0.1.0",
  "private": true,
  "description": "Built with AI assistance using the Launcify template",
  "packageManager": "pnpm@[detected-version]",
  "engines": {
    "node": ">=18.0.0"
  },
  "license": "MIT"
}
```

**How to determine [detected-version]:**

The packageManager field requires a specific semver version (not "latest"). To always use the latest:

1. **First, try to detect installed version:**
   ```bash
   pnpm --version
   # Returns: 10.5.2 (or whatever is currently installed)
   ```
   Use this version → `"packageManager": "pnpm@10.5.2"`

2. **If pnpm not installed, check npm registry:**
   ```bash
   npm view pnpm version
   # Returns: 10.22.0 (or whatever is latest in registry)
   ```
   Use this version → `"packageManager": "pnpm@10.22.0"`

3. **If both fail, use safe fallback:**
   ```
   "packageManager": "pnpm@9.0.0"
   ```

This ensures you always use the **latest available version**, not a hardcoded outdated one.

**Note:** Replace `[folder-name]` with the actual project directory name.

---

## Scripts

See `.ai/package-scripts.md` for the complete list of npm scripts to include.

---

## Installation Instructions (For AI)

### Step 1: Generate package.json

Create a package.json file with:
1. Metadata from above
2. Latest versions of all dependencies listed
3. Scripts from `.ai/package-scripts.md`

**How to get latest versions:**
- Use `pnpm add [package]@latest` to automatically get latest stable
- Or check npm registry for latest stable version tags

### Step 2: Install Dependencies

```bash
pnpm install
```

### Step 3: Verify

```bash
pnpm run build
```

If build succeeds, everything is set up correctly!

---

## Updating Dependencies (Future)

Users can update to newer versions anytime:

```bash
# Update all dependencies to latest
pnpm update --latest

# Or update specific package
pnpm update next@latest
```

---

## Common Issues

### Peer Dependency Warnings

If you see warnings about peer dependencies, it's usually safe to ignore them. Next.js and React manage their own peer dependencies.

### Version Conflicts

If specific versions conflict:
1. Check official Next.js documentation for compatible versions
2. React and React-DOM must always match versions
3. TypeScript types should match their corresponding package versions

---

## Why This Approach?

**Traditional templates:** Include package.json with specific versions → get outdated quickly

**This template:** Documents what's needed → AI generates fresh package.json with latest versions → always current

This ensures users start with the latest stable technology, not versions from months or years ago.
