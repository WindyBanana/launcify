# Launchify

**Transform your idea into a production-ready project in minutes**

Automated Next.js project generator with smart resume, progress tracking, and configuration presets. Never lose progress, choose from pre-built templates, and get a fully configured production-ready app.

---

## 🚀 Quick Start

### 1. Clone and Run
```bash
# Clone the repository
git clone https://github.com/yourusername/launchify.git
cd launchify

# Run from parent directory (recommended)
cd ..
./launchify/create-project.sh
```

### 2. Choose Your Path
- **Fast Track**: Pick a preset (SaaS Starter, Blog, AI App, or Minimal)
- **Custom**: Select exactly what you need from the interactive menu

### 3. Done!
Your production-ready Next.js app is created with:
- ✅ All services configured and connected
- ✅ Environment variables set up
- ✅ TypeScript, ESLint, and build verified
- ✅ Git repository initialized
- ✅ Ready to deploy to Vercel

**Total time: 5-15 minutes** (depending on services selected)

### What You Get

```bash
your-project/
├── .env.local              # All API keys configured
├── app/                    # Next.js 15 App Router
├── components/             # shadcn/ui components (optional)
├── convex/                 # Backend functions (optional)
├── lib/                    # Utilities & helpers
├── SETUP_GUIDE.md          # Step-by-step instructions
└── README.md               # Project documentation
```

### Try it in Dry Run Mode
```bash
./launchify/create-project.sh --dry-run
```
Preview exactly what will happen without making any changes.

---

## What's New in v2.0

**Major improvements:**
- **Checkpoint/Resume** - Never lose progress, resume from any failure point
- **Progress Tracking** - Visual progress bar with estimated time remaining
- **Configuration Presets** - Quick-start templates (SaaS, Blog, AI App, Minimal)
- **Config Export/Import** - Save and reuse successful configurations
- **Full Logging** - All output saved to `~/.launchify/logs/` for debugging
- ✅ **Health Checks** - Automated verification after setup completes

---

## Table of Contents
- [🚀 Quick Start](#-quick-start) - Get running in 5 minutes
- [What's New](#whats-new-in-v20) - v2.0 improvements
- [Features](#features) - What you get
- [Prerequisites](#prerequisites--platform-support) - System requirements
- [Configuration Presets](#configuration-presets) - Quick-start templates
- [Usage Examples](#usage-examples) - See it in action
- [Troubleshooting](#troubleshooting) - Resume, logs, and fixes
- [Contributing](#contributing) - Help improve Launchify

---

## Features

### Reliability & Recovery
- **Checkpoint/Resume System**: If setup fails, resume from where you left off - no need to start over
  - Progress automatically saved at each of 14 steps
  - Just run `./create-project.sh` again to continue
  - Works even if you press Ctrl+C or terminal crashes
  - Clear resume prompt shows exactly where you left off
- **Comprehensive Logging**: All output saved to `~/.launchify/logs/project-name-timestamp.log`
  - Automatic log cleanup (keeps last 10)
  - Full command output captured for debugging
- **Progress Tracking**: Visual progress bar showing current step and estimated time remaining
  - Real-time ETA calculation based on actual step durations
  - Shows "Progress automatically saved (Ctrl+C safe)" at every step
- **Error Recovery**: Smart error handling with retry, skip, or manual completion options
  - 4 clear options when something fails: Retry, Skip, Manual Fix, or Abort
  - Detailed instructions shown for each service error
  - Log file location provided for troubleshooting
- **State Persistence**: Configuration saved automatically for resume
  - No manual save required - happens automatically
  - State file location: `.launchify-state/`

### User Experience
- **Configuration Presets**: 
  - **SaaS Starter**: Full-stack app with all services
  - **Blog/Content**: Lightweight content-focused site
  - **AI Application**: AI-powered app with OpenAI/Anthropic
  - **Minimal**: Just the basics
  - **Custom**: Choose features individually
- **Config Export/Import**: Save successful configurations for future projects
- **Post-Setup Health Check**: Automated verification that everything works
- **Dry Run Mode**: Preview what will happen with `--dry-run`

### Service Integration

- **Interactive TUI Dashboard**: Beautiful checkbox/radio button interface (whiptail/dialog)
  - Visual feature selection with real-time summary
  - Automatic fallback to CLI mode if TUI unavailable
  - Works on Linux and macOS
- **Cross-Platform Support**: Automatic platform detection and tool installation
  - Linux: apt, yum, pacman support
  - macOS: Auto-installs Homebrew if needed
  - Intelligent package manager detection
- **Multiple Package Managers**: Choose between npm, pnpm, or yarn
- **Framework Selection**: Next.js 15 (more coming soon)
- **Service Integration**: Pick exactly what you need
  - ✅ **Vercel** - Deployment (auto-configured with dev/prod environments)
  - ✅ **Convex** - Serverless backend/database (auto-configured with dev/prod deployments)
  - ✅ **Clerk** - Authentication (fully automated via Svix API + webhook setup)
  - ✅ **Axiom** - Observability (auto-configured with CLI)
  - **Linear** - Issue/project tracking (guided GraphQL setup)
- **UI & Features**: Optional enhancements
  - ✅ **shadcn/ui** - Beautiful component library with dark mode support
  - ✅ **AI Integration** - OpenAI and/or Anthropic with ready-to-use utilities
  - ✅ **Admin Panel** - Full-featured admin dashboard (requires Convex)
- **Automated Setup**: CLIs handle everything automatically where possible
- **Guided Manual Setup**: Clear instructions for services without CLIs
- **Dual Environments**: Development and production configurations out of the box
- **Environment Variables**: Auto-generated `.env` files with helpful comments
- **Documentation**: Complete setup guides included in generated project

---

## Prerequisites & Platform Support

**Platform Compatibility:**
- ✅ **Linux** - Fully supported (tested on Ubuntu/Debian)
  - Auto-detects package manager (apt, yum, pacman)
  - Interactive TUI dashboard with whiptail/dialog
- ✅ **macOS** - Fully supported
  - Auto-installs Homebrew if not present
  - Cross-platform tool installation via brew
  - Interactive TUI dashboard with dialog
- ⚠️ **WSL (Windows Subsystem for Linux)** - Should work, but not fully tested
  - Browser OAuth flows may need manual intervention
  - Use WSL 2 for best compatibility
- ❌ **Windows (native)** - Not supported
  - Use WSL instead

**Required:**
- **Node.js 18+** (required)
- **Git** (required)
- **npm/pnpm/yarn** (at least one)
- **Bash shell** (default on Linux/macOS/WSL)

The script will check for these and help you install missing dependencies. Service CLIs will be installed automatically if you select those services.

---

### Interactive TUI Dashboard (Recommended)

On Linux and macOS, Launchify provides a beautiful Terminal UI (TUI) dashboard:

- **Visual Feature Selection**: Checkbox-based service and feature selection
- **Radio Button Choices**: Package manager and AI provider selection
- **Real-time Summary**: See your configuration before proceeding
- **Keyboard Navigation**: Space to select, Enter to confirm, Arrow keys to navigate

The TUI automatically falls back to CLI mode if whiptail/dialog is not available.

### Interactive Setup

When you run `./create-project.sh`, you'll be guided through:

1. **Platform Detection**: Auto-detects Linux/macOS and installs required tools
2. **Project Name**: Enter your project name (lowercase, hyphens only)
3. **Package Manager**: Choose npm, pnpm, or yarn (TUI or CLI)
4. **Framework**: Select Next.js (more frameworks coming soon)
5. **Feature Selection**: Toggle services and features (TUI dashboard or CLI)
   - Services: Vercel, Convex, Clerk, Axiom, Linear
   - UI: shadcn/ui with dark mode
   - AI: OpenAI, Anthropic, or both
   - Admin: Full-featured admin panel
6. **Confirmation**: Review your configuration summary
7. **Automated Setup**: Sit back while everything is configured
   - Vercel secrets set automatically via API
   - Clerk webhooks configured via Svix API
   - All environment variables populated

### Using Configuration Presets

```bash
$ ./create-project.sh

WELCOME TO LAUNCHIFY

Quick Start with Configuration Presets

Choose a preset configuration to get started quickly,
or select Custom to choose features individually.

Available Presets:

1. SaaS Starter - Full-featured SaaS application
   ✓ Vercel + Convex + Clerk + Axiom
   ✓ shadcn/ui + Admin Panel + Feature Toggles
   ✓ GitHub CI/CD

2. Blog/Content Site - Lightweight content-focused site
   ✓ Vercel + shadcn/ui + GitHub
   ✗ No backend/auth (keep it simple)

3. AI Application - AI-powered app
   ✓ Vercel + Convex + Clerk + Axiom
   ✓ OpenAI & Anthropic integration
   ✓ shadcn/ui + GitHub

4. Minimal - Just the basics
   ✓ Next.js + Vercel only
   ✗ No additional services

5. Custom - Choose features individually

Select preset [1-5]: 1

✓ Loaded preset: saas-starter

Configuration Summary:
  Framework: nextjs
  Vercel: ✓
  Convex: ✓
  Clerk: ✓
  ...

Use this configuration? [Y/n]: y

═══════════════════════════════════════════════════════════
Progress: [████████░░░░] 57%
Step 8/14: Setting up Admin Panel
Estimated time remaining: 3m 24s
Progress automatically saved (Ctrl+C safe)
═══════════════════════════════════════════════════════════

Setting up Admin Panel...

Step 10: Generating Environment Files...
✓ .env.local created
✓ .env.production.template created

Step 11: Creating Setup Guides...
✓ SETUP_GUIDE.md created

Step 13: Initializing Git Repository...
✓ Git repository initialized

🚀 PROJECT SETUP COMPLETE!

Project created at: ./my-saas-app

Next steps:
  1. cd my-saas-app
  2. Read SETUP_GUIDE.md and configure Clerk
  3. Review .env.local and add any missing API keys
  4. npm run dev - Start development server
  5. git remote add origin <your-repo-url>
  6. git push -u origin main

Happy coding!
```

---

## What Gets Generated

After running the script, your project will have:

### Project Structure

```
my-saas-app/
├── app/                          # Next.js app directory
├── components/                   # React components
├── lib/                          # Utilities and helpers
│   ├── axiom.ts                 # (if Axiom selected)
│   └── ...
├── convex/                       # (if Convex selected)
│   ├── schema.ts                # Database schema
│   └── example.ts               # Example query
├── .env.local                    # Development environment variables
├── .env.production.template      # Production env template
├── SETUP_GUIDE.md               # Manual setup instructions
├── vercel.json                   # (if Vercel selected)
├── convex.json                   # (if Convex selected)
├── package.json                  # Dependencies and scripts
└── README.md                     # Project-specific readme
```

### Environment Files

**`.env.local`** (Development):
- Pre-filled with service URLs and placeholders
- Helpful comments showing where to get each value
- Convex URLs auto-populated
- Clear TODOs for values you need to add manually

**`.env.production.template`**:
- Template for production variables
- Instructions to set in Vercel dashboard
- Not committed to git

### Setup Guides

**`SETUP_GUIDE.md`** includes:
- Step-by-step Clerk setup (dev + production)
- Linear GraphQL integration guide
- Links to official documentation
- Example code snippets
- Verification checklist

---

## Service Details

### Automated Setup (Via CLI)

#### Vercel
- ✅ Auto-login via browser
- ✅ Project creation/linking
- ✅ `vercel.json` configuration
- ✅ **Automated production secrets** via Vercel REST API
  - Sets Clerk, Convex, Axiom secrets automatically
  - Supports encrypted, plain, and sensitive variable types
  - Targets production, preview, and development environments
  - Graceful fallback to manual instructions if API unavailable
- **Environments**:
  - Development: Preview deployments (all branches)
  - Production: Main branch deployments

#### Convex
- ✅ Auto-installation of `convex` package (local, not global)
- ✅ Development deployment initialization (via `npx convex`)
- ✅ Schema and example files
- ✅ Auto-populated `.env.local`
- **Note**: No global CLI installation needed - uses `npx convex` commands
- **Environments**:
  - Development: Auto-created dev deployment
  - Production: Manual deployment (`npx convex deploy --prod`)

#### Axiom
- ✅ CLI installation (Linux/macOS)
- ✅ Auto-login via browser
- ✅ Dataset creation
- ✅ API token generation (where possible)
- ✅ Client library installation
- ✅ Helper utility creation (`lib/axiom.ts`)

### Guided Manual Setup

#### Clerk
- Detailed setup guide in `SETUP_GUIDE.md`
- Dashboard links and instructions
- Webhook configuration guide
- Separate dev and production instances
- **Required**: Manual API key entry in `.env.local`

#### Linear
- GraphQL API setup guide
- API key generation instructions
- Example queries and mutations
- Webhook setup (optional)
- **Required**: Manual API key entry in `.env.local`

### UI & Feature Enhancements

#### shadcn/ui + Dark Mode
- ✅ Automatic component library setup
- ✅ Pre-installed common components (button, card, dialog, input, etc.)
- ✅ Dark mode with theme toggle component
- ✅ Tailwind CSS theme configured
- ✅ `components.json` auto-generated
- **Installed**: `class-variance-authority`, `clsx`, `tailwind-merge`, `lucide-react`, `next-themes`
- **Ready to use**: `ThemeToggle` component and `ThemeProvider`
- **Add more**: `npx shadcn@latest add <component>`

#### AI Integration
Supports OpenAI, Anthropic (Claude), or both providers.

**What's included:**
- ✅ SDK installation (`openai` and/or `@anthropic-ai/sdk`)
- ✅ Unified helper utilities in `lib/ai/`
  - `lib/ai/openai.ts` - OpenAI helpers (chat, streaming, embeddings)
  - `lib/ai/anthropic.ts` - Anthropic helpers (messages, streaming)
  - `lib/ai/index.ts` - Unified API that works with either provider
- ✅ Example API route: `app/api/ai/chat/route.ts`
- ✅ Example React component: `components/examples/ai-chat-example.tsx`
- ✅ Support for streaming responses
- **API keys**: Auto-added to `.env.local` with helpful comments

**Usage:**
```typescript
import { generateText, streamText } from '@/lib/ai';

// Simple generation
const response = await generateText('Your prompt here', {
  systemPrompt: 'You are a helpful assistant',
  provider: 'openai', // or 'anthropic' or auto-detect
});

// Streaming
for await (const chunk of streamText('Your prompt', options)) {
  console.log(chunk);
}
```

#### Admin Panel
**Requires Convex** - Full-featured dashboard for managing your application.

**Features:**
- ✅ Dashboard with system statistics
- ✅ User management interface (if Clerk enabled)
- ✅ Database viewer (links to Convex dashboard)
- ✅ Logs viewer (links to Axiom if enabled)
- ✅ Settings configuration
- ✅ Responsive sidebar navigation
- ✅ Dark mode support (if shadcn/ui enabled)
- **Security**: Dev-only by default, optional production enable
- **Access**: `http://localhost:3000/admin`

**Files created:**
- `app/admin/layout.tsx` - Admin layout with sidebar
- `app/admin/page.tsx` - Dashboard with stats
- `app/admin/users/page.tsx` - User management
- `app/admin/database/page.tsx` - Database viewer
- `app/admin/logs/page.tsx` - Logs viewer
- `app/admin/settings/page.tsx` - Settings page
- `convex/admin.ts` - Admin Convex functions

**Environment variables:**
```bash
ENABLE_ADMIN_PANEL=true  # Set to false to disable in production
ADMIN_ALLOWED_EMAILS=you@example.com,admin@example.com
```

---

## After Setup

### 1. Configure Manual Services

If you selected Clerk or Linear:
```bash
cd your-project
cat SETUP_GUIDE.md  # Read the setup guide
```

Follow the instructions to:
- Create Clerk applications (dev + prod)
- Get Clerk API keys
- Configure Linear API access
- Add keys to `.env.local`

### 2. Start Development

```bash
npm run dev          # Start Next.js dev server
npx convex dev       # Start Convex (in another terminal, if using Convex)
```

Your app will be running at `http://localhost:3000`

### 3. Push to GitHub

```bash
git remote add origin https://github.com/yourusername/your-repo.git
git push -u origin main
```

### 4. Deploy to Production

Vercel will automatically deploy when you push to main branch.

For Convex production deployment:
```bash
npx convex deploy --prod
```

Add production environment variables in Vercel dashboard.

---

## Customization

### Adding More Frameworks

To add support for other frameworks:

1. Create template in `templates/your-framework/`
2. Add framework option in `create-project.sh`
3. Update `create_project()` function in `scripts/utils.sh`

### Adding More Services

To add new service integrations:

1. Create setup script: `scripts/setup-yourservice.sh`
2. Add CLI check in `scripts/check-dependencies.sh`
3. Add CLI install in `scripts/install-clis.sh`
4. Add service toggle in `create-project.sh`
5. Update env generation in `scripts/utils.sh`

---

## Troubleshooting

### Setup Failed - Can I Resume?

**Yes!** The checkpoint system automatically saves your progress:

```bash
# Just run the script again
./create-project.sh

# You'll see:
# PREVIOUS SETUP DETECTED
# Found saved progress: my-project
# Last completed step: 5 of 14
# Resume from step 6? [Y/n]:
```

Progress is saved at every step. Even if you press Ctrl+C or your terminal crashes, you can resume exactly where you left off.

### Where Are My Logs?

All setup output is automatically saved:

```bash
# View the latest log
ls -lt ~/.launchify/logs/

# Logs are named: project-name_YYYY-MM-DD_HH-MM-SS.log
cat ~/.launchify/logs/my-project_2025-11-03_14-23-45.log
```

Logs are kept for debugging. The system automatically keeps the last 10 logs.

### How Do I Start Over?

```bash
# Delete the checkpoint state
rm -rf .launchify-state/

# Run the script again
./create-project.sh
```

### Step Failed - What Are My Options?

When a step fails, you get 4 options:

1. **Retry** - Try the step again right now
2. **Skip** - Continue without this step (may cause issues)
3. **Manual** - Fix it yourself, then mark as complete
4. **Abort** - Stop here, fix it later, then resume

The script shows clear instructions for each option.

### Common Issues

#### "Command not found: vercel"
```bash
npm install -g vercel
```

#### "Convex initialization failed"
```bash
npx convex login
npx convex dev --once --configure=new
```

#### "Axiom CLI not found"
**Linux:**
```bash
curl -L https://github.com/axiomhq/cli/releases/latest/download/axiom_linux_amd64 -o axiom
chmod +x axiom
sudo mv axiom /usr/local/bin/
```

**macOS:**
```bash
brew install axiomhq/tap/axiom
```

#### Environment variables not working
1. Check `.env.local` exists
2. Remove TODO placeholders
3. Restart dev server
4. For production, set in Vercel dashboard

### Still Stuck?

1. Check logs: `~/.launchify/logs/`
2. Review the generated `SETUP_GUIDE.md` in your project
3. See [ERROR_HANDLING_GUIDE.md](ERROR_HANDLING_GUIDE.md) for advanced recovery
4. Open an issue with your log file

---

## Resources

### Official Documentation

- **Next.js**: https://nextjs.org/docs
- **Vercel**: https://vercel.com/docs
- **Convex**: https://docs.convex.dev
- **Clerk**: https://clerk.com/docs
- **Axiom**: https://axiom.co/docs
- **Linear**: https://developers.linear.app

### Package Managers

- **npm**: https://docs.npmjs.com
- **pnpm**: https://pnpm.io
- **yarn**: https://yarnpkg.com

---

## Contributing

Contributions are welcome! Please:

1. Fork this repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

---

## License

MIT License - feel free to use this for any project!

---

## Credits

Built for developers who want to spend time building features, not configuring boilerplate.

---

## Roadmap

- [ ] Support for more frameworks (React, Vue, Svelte)
- [ ] Support for more backends (Supabase, Firebase, PlanetScale)
- [ ] Support for more auth providers (Auth0, NextAuth)
- [ ] Windows support
- [ ] Interactive TUI (Terminal UI)
- [ ] Project templates library
- [ ] CI/CD pipeline generation
- [ ] Docker configuration option
- [ ] Testing setup (Jest, Playwright)
- [ ] Monitoring setup (Sentry)

---

**Happy coding!**

Questions or issues? Open an issue on GitHub.
