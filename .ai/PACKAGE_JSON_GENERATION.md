# Package.json Generation - How It Works

## For AI Assistants

When a user first opens this template, **there is NO package.json file**.

This is intentional! You will create it with the latest versions.

## The Workflow Chain

### 1. User Opens Template

User creates a new project from this template and opens it in their AI editor (Cursor, Windsurf, Claude Code, etc.)

### 2. AI Reads Entry Point

The AI editor automatically reads one of these files:
- `CLAUDE.md` (Claude Code)
- `.cursorrules` (Cursor)
- `.windsurfrules` (Windsurf)
- `CODEX.md` (OpenAI Codex)

### 3. Entry Point References Onboarding

All entry point files contain:
```markdown
**YOU MUST READ:** `.ai/MANDATORY_READ_FIRST.md`
Read: `.ai/onboarding/first-interaction.md`
```

### 4. First-Interaction Instructions

`.ai/onboarding/first-interaction.md` contains detailed instructions:

```markdown
## FIRST: Generate package.json and Install Dependencies

### Step 1: Check if package.json exists
ls package.json  # Will fail - doesn't exist!

### Step 2: Generate Fresh package.json
Read these files:
1. `.ai/project-dependencies.md` - Lists all required packages
2. `.ai/package-scripts.md` - Lists all npm scripts

Then create package.json with latest versions...
```

### 5. AI Generates package.json

The AI:
1. Reads `.ai/project-dependencies.md`
2. Reads `.ai/package-scripts.md`
3. Creates `package.json` with:
   - Folder name as project name
   - `"latest"` for all dependency versions
   - All required scripts

### 6. AI Installs Dependencies

```bash
pnpm install
```

pnpm resolves `"latest"` to the current stable versions.

### 7. User Gets Latest Versions

The user now has a project with the most current versions of:
- Next.js
- React
- TypeScript
- Tailwind CSS
- Vitest
- All other dependencies

## Example Generated package.json

```json
{
  "name": "my-awesome-app",
  "version": "0.1.0",
  "private": true,
  "packageManager": "pnpm@latest",
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
  },
  "dependencies": {
    "next": "latest",
    "react": "latest",
    "react-dom": "latest"
  },
  "devDependencies": {
    "@testing-library/dom": "latest",
    "@testing-library/react": "latest",
    "@types/node": "latest",
    "@types/react": "latest",
    "@types/react-dom": "latest",
    "@vitejs/plugin-react": "latest",
    "@vitest/ui": "latest",
    "autoprefixer": "latest",
    "eslint": "latest",
    "eslint-config-next": "latest",
    "jsdom": "latest",
    "postcss": "latest",
    "tailwindcss": "latest",
    "typescript": "latest",
    "vitest": "latest"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
```

When pnpm install runs, `"latest"` becomes actual version numbers like `"16.0.3"`, `"19.2.0"`, etc.

## Why This Approach?

### Traditional Templates ❌
```
Template created: Jan 2024
- Next.js 14.0.0
- React 18.2.0

User uses template: Nov 2024
- Still gets Next.js 14.0.0 ❌ (outdated!)
- Still gets React 18.2.0 ❌ (outdated!)
```

### This Template ✅
```
Template created: Jan 2024
- No package.json in repo

User uses template: Nov 2024
- AI generates fresh package.json
- pnpm resolves "latest" to:
  - Next.js 16.0.3 ✓ (current!)
  - React 19.2.0 ✓ (current!)
```

## Verification

To verify the workflow is connected:

### Check 1: Entry Points Reference Onboarding
```bash
grep "first-interaction\|onboarding" CLAUDE.md .cursorrules .windsurfrules
```
✓ Should show references to `.ai/onboarding/first-interaction.md`

### Check 2: Onboarding References Dependency Files
```bash
grep "project-dependencies\|package-scripts" .ai/onboarding/first-interaction.md
```
✓ Should show references to `.ai/project-dependencies.md` and `.ai/package-scripts.md`

### Check 3: Package.json Doesn't Exist
```bash
ls package.json
```
✓ Should fail (file doesn't exist in template)

### Check 4: Gitignore Excludes Package Files
```bash
grep "package.json\|pnpm-lock" .gitignore
```
✓ Should show these files are ignored

## The Chain is Complete!

```
User opens template
    ↓
AI reads CLAUDE.md (or .cursorrules, etc.)
    ↓
AI reads .ai/MANDATORY_READ_FIRST.md
    ↓
AI reads .ai/onboarding/first-interaction.md
    ↓
AI reads .ai/project-dependencies.md
AI reads .ai/package-scripts.md
    ↓
AI generates package.json
    ↓
AI runs pnpm install
    ↓
User has latest versions! ✓
```

## Testing the Generation

If you want to test that generation works:

1. Delete package.json and pnpm-lock.yaml (if they exist)
2. Ask the AI: "Set up this project"
3. AI should:
   - Check for package.json (doesn't exist)
   - Read the dependency manifests
   - Create fresh package.json
   - Run pnpm install
   - Report versions installed

The generated package.json will NOT be committed to git (it's in .gitignore).

Each user gets their own fresh package.json with current versions!
