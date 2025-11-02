# 🚀 Launchify

**Transform your idea into a production-ready project**

Interactive project template generator with feature toggles. Pick your services, customize your stack, and get a fully configured Next.js project ready to launch. **Fully automates** Vercel, Convex, Clerk (via Svix API), and Axiom setup. Provides guided config for Linear (GraphQL API).

---

## 🚀 Features

- **📦 Multiple Package Managers**: Choose between npm, pnpm, or yarn
- **🎨 Framework Selection**: Next.js 15 (more coming soon)
- **🔧 Service Integration**: Pick exactly what you need
  - ✅ **Vercel** - Deployment (auto-configured with dev/prod environments)
  - ✅ **Convex** - Serverless backend/database (auto-configured with dev/prod deployments)
  - ✅ **Clerk** - Authentication (fully automated via Svix API + webhook setup)
  - ✅ **Axiom** - Observability (auto-configured with CLI)
  - 📋 **Linear** - Issue/project tracking (guided GraphQL setup)
- **🎨 UI & Features**: Optional enhancements
  - ✅ **shadcn/ui** - Beautiful component library with dark mode support
  - ✅ **AI Integration** - OpenAI and/or Anthropic with ready-to-use utilities
  - ✅ **Admin Panel** - Full-featured admin dashboard (requires Convex)
- **⚡ Automated Setup**: CLIs handle everything automatically where possible
- **📝 Guided Manual Setup**: Clear instructions for services without CLIs
- **🌍 Dual Environments**: Development and production configurations out of the box
- **🔐 Environment Variables**: Auto-generated `.env` files with helpful comments
- **📚 Documentation**: Complete setup guides included in generated project

---

## 📋 Prerequisites & Platform Support

**🐧 Platform Compatibility:**
- ✅ **Linux** - Fully supported (tested on Ubuntu/Debian)
- ⚠️ **WSL (Windows Subsystem for Linux)** - Should work, but not fully tested
  - Browser OAuth flows may need manual intervention
  - Use WSL 2 for best compatibility
- ⚠️ **macOS** - Partially supported
  - Axiom CLI requires Homebrew (`brew install axiomhq/tap/axiom`)
  - Other CLIs should work
  - Some Linux-specific commands may need adjustments
- ❌ **Windows (native)** - Not supported
  - Use WSL instead

**Required:**
- **Node.js 18+** (required)
- **Git** (required)
- **npm/pnpm/yarn** (at least one)
- **Bash shell** (default on Linux/macOS/WSL)

The script will check for these and help you install missing dependencies. Service CLIs will be installed automatically if you select those services.

---

## 🎯 Quick Start

```bash
# 1. Clone this repository
git clone <this-repo-url>
cd launchify

# 2. Make the script executable
chmod +x create-project.sh

# 3. Run the generator
./create-project.sh

# 4. Follow the interactive prompts
```

---

## 📖 Usage

### Interactive Setup

When you run `./create-project.sh`, you'll be guided through:

1. **Project Name**: Enter your project name (lowercase, hyphens only)
2. **Package Manager**: Choose npm, pnpm, or yarn
3. **Framework**: Select Next.js (more frameworks coming soon)
4. **Service Selection**: Toggle services on/off
   - Vercel for deployment
   - Convex for backend/database
   - Clerk for authentication
   - Axiom for observability
   - Linear for project management
5. **Confirmation**: Review your choices
6. **Automated Setup**: Sit back while everything is configured

### Example Session

```bash
$ ./create-project.sh

╔═══════════════════════════════════════════════════════╗
║                                                       ║
║     FULLSTACK PROJECT TEMPLATE GENERATOR             ║
║     Zero-config setup for production-ready apps      ║
║                                                       ║
╚═══════════════════════════════════════════════════════╝

📝 Step 1: Project Configuration
Enter project name: my-saas-app
✓ Project name: my-saas-app

📦 Step 2: Package Manager
Select your package manager:
  1) npm (default)
  2) pnpm
  3) yarn
Choice [1-3]: 1
✓ Package manager: npm

🎨 Step 3: Framework
Select your framework:
  1) Next.js 15 + TypeScript + Tailwind (recommended)
Choice [1]: 1
✓ Framework: nextjs

🔧 Step 4: Service Selection
Select services to integrate (y/n):
  Vercel (Deployment) [Y/n]: y
  Convex (Backend/Database) [Y/n]: y
  Clerk (Authentication) [Y/n]: y
  Axiom (Observability) [y/N]: n
  Linear (Project Management) [y/N]: n

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 Configuration Summary:
  Project: my-saas-app
  Package Manager: npm
  Framework: nextjs
  Services:
    ✓ Vercel
    ✓ Convex
    ✓ Clerk
    ✗ Axiom
    ✗ Linear
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Proceed with setup? [Y/n]: y

🔍 Checking Dependencies...
✓ Node.js v20.10.0
✓ npm 10.2.3
✓ Git 2.43.0
✓ Vercel CLI 33.0.1
✓ All critical dependencies satisfied

🚀 Creating Project...
✓ Next.js project created

🔷 Setting up Vercel...
✓ Logged in to Vercel
✓ Vercel project linked

🔶 Setting up Convex...
✓ Convex development deployment initialized

📝 Generating Environment Files...
✓ .env.local created
✓ .env.production.template created

📚 Creating Setup Guides...
✓ SETUP_GUIDE.md created

🔧 Initializing Git Repository...
✓ Git repository initialized

╔═══════════════════════════════════════════════════════╗
║                                                       ║
║          🎉 PROJECT SETUP COMPLETE! 🎉               ║
║                                                       ║
╚═══════════════════════════════════════════════════════╝

📂 Project created at: ./my-saas-app

Next steps:
  1. cd my-saas-app
  2. Read SETUP_GUIDE.md and configure Clerk
  3. Review .env.local and add any missing API keys
  4. npm run dev - Start development server
  5. git remote add origin <your-repo-url>
  6. git push -u origin main

✨ Happy coding!
```

---

## 🔧 What Gets Generated

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

## 🎛️ Service Details

### Automated Setup (Via CLI)

#### Vercel
- ✅ Auto-login via browser
- ✅ Project creation/linking
- ✅ `vercel.json` configuration
- 🌍 **Environments**:
  - Development: Preview deployments (all branches)
  - Production: Main branch deployments

#### Convex
- ✅ Auto-installation of `convex` package (local, not global)
- ✅ Development deployment initialization (via `npx convex`)
- ✅ Schema and example files
- ✅ Auto-populated `.env.local`
- 💡 **Note**: No global CLI installation needed - uses `npx convex` commands
- 🌍 **Environments**:
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
- 📋 Detailed setup guide in `SETUP_GUIDE.md`
- 📋 Dashboard links and instructions
- 📋 Webhook configuration guide
- 📋 Separate dev and production instances
- 🔑 **Required**: Manual API key entry in `.env.local`

#### Linear
- 📋 GraphQL API setup guide
- 📋 API key generation instructions
- 📋 Example queries and mutations
- 📋 Webhook setup (optional)
- 🔑 **Required**: Manual API key entry in `.env.local`

### UI & Feature Enhancements

#### shadcn/ui + Dark Mode
- ✅ Automatic component library setup
- ✅ Pre-installed common components (button, card, dialog, input, etc.)
- ✅ Dark mode with theme toggle component
- ✅ Tailwind CSS theme configured
- ✅ `components.json` auto-generated
- 📦 **Installed**: `class-variance-authority`, `clsx`, `tailwind-merge`, `lucide-react`, `next-themes`
- 🎨 **Ready to use**: `ThemeToggle` component and `ThemeProvider`
- 📚 **Add more**: `npx shadcn@latest add <component>`

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
- 🔑 **API keys**: Auto-added to `.env.local` with helpful comments

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
- 🔒 **Security**: Dev-only by default, optional production enable
- 📍 **Access**: `http://localhost:3000/admin`

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

## 📝 After Setup

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

## 🛠️ Customization

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

## 🐛 Troubleshooting

### "Command not found: vercel"

The Vercel CLI wasn't installed properly.

```bash
npm install -g vercel
```

### "Convex initialization failed"

Make sure you're logged in:

```bash
npx convex login
npx convex dev --once --configure=new
```

### "Axiom CLI not found"

Install manually:

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

### Environment variables not working

1. Make sure `.env.local` exists
2. Check that values don't have TODO placeholders
3. Restart your dev server after changing env vars
4. For Vercel deployment, set vars in Vercel dashboard

---

## 📚 Resources

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

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork this repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

---

## 📄 License

MIT License - feel free to use this for any project!

---

## 🙏 Credits

Built for developers who want to spend time building features, not configuring boilerplate.

---

## 🗺️ Roadmap

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

**Happy coding! 🚀**

Questions or issues? Open an issue on GitHub.
