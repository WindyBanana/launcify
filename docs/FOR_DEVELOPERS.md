# For Developers

Technical documentation for developers who want to understand or customize the template.

## Tech Stack

- **Framework:** Next.js 16 (App Router)
- **Language:** TypeScript 5.6
- **UI:** React 19.2
- **Styling:** Tailwind CSS 3.4
- **Testing:** Vitest 2.1 + React Testing Library
- **Package Manager:** npm (compatible with pnpm/yarn)

## Project Structure

```
.
├── .ai/                           # AI assistant instructions
│   ├── MANDATORY_READ_FIRST.md   # Entry point for AI
│   ├── ASK_DONT_ASSUME.md        # Clarification guidelines
│   ├── STRICT_COMMAND_RULES.md   # Command execution rules
│   ├── onboarding/               # First-time user flow
│   ├── workflows/                # Task-specific guides
│   ├── services/                 # Third-party integrations
│   └── scripts/                  # Setup automation
│
├── app/                          # Next.js App Router
│   ├── layout.tsx               # Root layout
│   ├── page.tsx                 # Homepage
│   └── globals.css              # Global styles
│
├── components/                   # React components
│   └── ui/                      # Reusable UI components
│
├── lib/                         # Utilities and helpers
│
├── docs/                        # User documentation
│
├── .cursor/                     # Cursor configuration
├── .windsurf/                   # Windsurf configuration
├── .vscode/                     # VS Code configuration
├── .codex/                      # Codex configuration
│
├── next.config.js              # Next.js configuration
├── tailwind.config.ts          # Tailwind configuration
├── tsconfig.json               # TypeScript configuration
├── vitest.config.ts            # Vitest configuration
└── package.json                # Dependencies
```

## AI Instruction System

The `.ai/` directory contains comprehensive instructions for AI assistants.

### Core Principles

1. **Ask, Don't Assume** - AI clarifies vague requests
2. **AI Runs Commands** - Users never use terminal
3. **Non-Developer First** - Simple language, patient guidance
4. **Proactive Service Suggestions** - Right service at right time

### Key Files

**MANDATORY_READ_FIRST.md**
Entry point. AI reads this before any interaction.

**ASK_DONT_ASSUME.md**
When to ask clarifying questions, how to present options.

**STRICT_COMMAND_RULES.md**
When to run commands immediately vs. when to ask permission.

**WHEN_TO_SUGGEST_SERVICES.md**
Decision tree for recommending services (Clerk, Convex, etc.)

### Workflows

Located in `.ai/workflows/`, these guide AI through specific tasks:

- `add-feature.md` - Building new features
- `first-interaction.md` - Onboarding flow

### Service Guides

Located in `.ai/services/`, comprehensive setup guides for:

- **context7.md** - Up-to-date documentation
- **clerk.md** - Authentication
- **convex.md** - Database
- **vercel.md** - Hosting
- **axiom.md** - Logging
- **linear.md** - Feedback system

Each guide includes:
- When to suggest the service
- ELI5 explanation
- Step-by-step setup
- Code examples
- Troubleshooting

## Configuration Files

### Multiple Editor Support

The template includes configs for all major AI editors:

- `.cursor/` - Cursor
- `.windsurf/` - Windsurf
- `.vscode/` - VS Code with Copilot
- `.codex/` - OpenAI Codex
- `.continue/` - Continue
- `.zed/` - Zed
- And more...

Each contains MCP (Model Context Protocol) configuration for Context7.

**Why so many?** Users might switch editors. Each editor only reads its own folder.

### Context7 Integration

Context7 is disabled by default. To enable:

```bash
npm run setup-context7
```

This script:
1. Prompts for API key
2. Updates all editor configs
3. Renames `context7-disabled` to `context7`
4. Verifies setup

### Auto-Generated Configs

GitHub Action (`.github/workflows/update-context7-configs.yml`) runs daily to:
- Fetch supported platforms from Context7 repo
- Generate configs for new editors
- Commit updates automatically

## Testing

### Vitest Configuration

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    environment: 'jsdom',
    setupFiles: ['./vitest.setup.ts'],
  },
})
```

### Testing Modes

Users choose one of three modes:

1. **Complete** - AI writes tests for everything
2. **Smart** - AI suggests tests for critical features
3. **None** - No automatic tests

Mode is saved in `.ai/testing/current-settings.json` and respected throughout.

### Scripts

```bash
npm test              # Run tests
npm run test:ui       # Run with UI
npm run test:coverage # Run with coverage
```

## Customization

### Adding a Service Guide

1. Create `.ai/services/your-service.md`
2. Follow the existing template structure:
   - When to suggest
   - ELI5 explanation
   - Setup steps
   - Code examples
   - Troubleshooting
3. Add to `.ai/WHEN_TO_SUGGEST_SERVICES.md`

### Modifying AI Behavior

Edit files in `.ai/`:

**Change how AI asks questions:**
Edit `.ai/ASK_DONT_ASSUME.md`

**Change when AI runs commands:**
Edit `.ai/STRICT_COMMAND_RULES.md`

**Add new workflows:**
Create `.ai/workflows/your-workflow.md`

### Adding Editor Support

1. Create `.your-editor/` folder
2. Add MCP configuration (see existing for format)
3. Add to `.ai/scripts/generate-configs.js`
4. Update README if needed

## Scripts

### setup-context7.js

Enables Context7 across all AI editors.

```javascript
// Prompts for API key
// Updates all JSON and TOML configs
// Renames context7-disabled to context7
```

### generate-configs.js

Auto-generates editor configs from Context7's supported platforms.

```javascript
// Fetches from Context7 repo
// Generates configs for each platform
// Updates metadata
```

### cleanup-configs.js

Removes unused editor config folders (optional).

## Development

### Getting Started

```bash
# Install dependencies
npm install

# Start dev server
npm run dev

# Open http://localhost:3000
```

### Building

```bash
# Build for production
npm run build

# Start production server
npm start
```

### Linting

```bash
npm run lint
```

## Deployment

Optimized for Vercel but works anywhere Next.js runs.

### Vercel

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel
```

### Environment Variables

For services, add to `.env.local`:

```bash
# Clerk
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=
CLERK_SECRET_KEY=

# Convex
NEXT_PUBLIC_CONVEX_URL=

# Axiom
NEXT_PUBLIC_AXIOM_TOKEN=
NEXT_PUBLIC_AXIOM_DATASET=

# Linear
LINEAR_API_KEY=
LINEAR_TEAM_ID=
```

## Architecture Decisions

### Why Next.js 16?

- Server Components for better performance
- App Router for better file organization
- React 19 support
- Industry standard

### Why Vitest?

- Faster than Jest
- Better TypeScript support
- Works with Vite/Turbopack
- Modern test runner

### Why Tailwind?

- Utility-first, easy for AI to generate
- No CSS files to manage
- Consistent design system
- Fast prototyping

### Why TypeScript?

- Catch errors before runtime
- Better AI code generation
- Self-documenting code
- Industry best practice

## Contributing

### Adding Features

1. Test with multiple AI editors
2. Update relevant `.ai/` docs
3. Add examples to docs
4. Test with non-developer mindset

### Improving AI Instructions

1. Test changes with real users
2. Keep language simple (ELI5)
3. Add examples
4. Update MANDATORY_READ_FIRST.md if needed

## License

MIT - See LICENSE file

## Credits

- Next.js by Vercel
- React by Meta
- Context7 by Upstash
- Tailwind CSS by Tailwind Labs
- Vitest by Vitest Team

---

**Questions?** Open an issue on GitHub.
