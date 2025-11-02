# Error Handling & Resume System

## Overview

Launchify now includes a comprehensive error handling and resume system that:
- ✅ Tracks progress through checkpoints
- ✅ Allows resuming from where you left off
- ✅ Offers recovery options when steps fail
- ✅ Provides service-specific error guidance
- ✅ Validates environment before starting
- ✅ Supports rollback of failed setups

## Current Implementation Status

### ✅ Implemented Features

#### 1. Build Validation (Step 12)
Located in `create-project.sh` lines 366-416:
- TypeScript type checking
- ESLint validation
- Production build test
- **Note**: Currently shows warnings but doesn't block

#### 2. Test Script
`test-generator.sh` - Automated testing:
- Creates test project with predefined inputs
- Validates TypeScript, ESLint, and build
- Runs end-to-end verification

#### 3. Error Handling Framework
`scripts/error-handling.sh` - Comprehensive error handling:
- State tracking and checkpoints
- Resume functionality
- Recovery options
- Service-specific error messages
- Environment validation
- Rollback capability

### 📋 To Be Integrated

The error handling framework is **created but not yet integrated** into `create-project.sh`.

## How It Works

### State Tracking

When setup starts, a hidden directory `.launchify-state/` is created:

```
.launchify-state/
├── progress.state    # Current step number
└── config.state      # Project configuration
```

### Resume Flow

```bash
# First run fails at step 8
./create-project.sh
# ... fails at Convex setup ...

# Second run detects previous attempt
./create-project.sh

╔════════════════════════════════════════════════════╗
║   🔄 RESUME DETECTED                               ║
╚════════════════════════════════════════════════════╝

Previous setup detected:
  Project: my-saas-app
  Last completed step: 7
  Time: 2025-11-02 15:30:45

Resume from step 8? [Y/n]:
```

### Recovery Options

When a step fails, user gets 4 choices:

```bash
╔════════════════════════════════════════════════════╗
║   ⚠️  STEP FAILED: Setting up Convex              ║
╚════════════════════════════════════════════════════╝

Recovery Options:
  1) Retry - Try this step again
  2) Skip - Skip this step and continue
  3) Manual - Mark as completed (I fixed it manually)
  4) Abort - Exit setup (you can resume later)

Choose option [1-4]:
```

### Service-Specific Error Messages

Each service provides helpful error context:

```bash
╔════════════════════════════════════════════════════╗
║   ⚠️  CLERK SETUP FAILED                          ║
╚════════════════════════════════════════════════════╝

Clerk setup failed. This is usually because:
  • Invalid API keys
  • Network connectivity issues
  • Svix API rate limiting

You can:
  1. Complete Clerk setup manually later (See SETUP_GUIDE.md)
  2. Retry with correct credentials

Continue without Clerk? [y/N]:
```

## Integration Plan

### Phase 1: Add Basic Error Handling (Recommended Next Step)

Add to `create-project.sh`:

```bash
# At the top, after sourcing other scripts
source "$SCRIPT_DIR/scripts/error-handling.sh"

# Change from:
set -e  # Exit on error

# To:
set -E  # ERR trap is inherited by shell functions
trap 'handle_error $? $LINENO' ERR

# Before Step 1, add:
validate_environment || exit 1
load_state
init_state_tracking "$PROJECT_NAME"

# Wrap critical steps:
if ! should_skip_step 8; then
    if ! setup_convex "$PROJECT_NAME" "$PACKAGE_MANAGER"; then
        handle_service_error "Convex" || exit 1
    fi
    mark_step_completed 8
fi

# At the end:
cleanup_state
```

### Phase 2: Wrap All Service Setups

Wrap each service with error handling:

```bash
# Vercel
if $USE_VERCEL && ! should_skip_step 8; then
    if ! setup_vercel "$PROJECT_NAME"; then
        handle_service_error "Vercel" || exit 1
    fi
    mark_step_completed 8
fi

# Convex
if $USE_CONVEX && ! should_skip_step 9; then
    if ! setup_convex "$PROJECT_NAME" "$PACKAGE_MANAGER"; then
        handle_service_error "Convex" || exit 1
    fi
    mark_step_completed 9
fi

# Clerk
if $USE_CLERK && ! should_skip_step 10; then
    if ! setup_clerk "$USE_CONVEX" "$USE_VERCEL" "$PROJECT_NAME"; then
        handle_service_error "Clerk" || exit 1
    fi
    mark_step_completed 10
fi
```

### Phase 3: Make Build Validation Stricter

Currently build validation shows warnings but continues. Make it more strict:

```bash
# In Step 12, change from:
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Production build successful${NC}"
else
    echo -e "${RED}✗ Build failed${NC}"
fi

# To:
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Production build successful${NC}"
else
    echo -e "${RED}✗ Build failed${NC}"
    echo ""
    echo -e "${YELLOW}Your project has build errors that must be fixed.${NC}"
    read -p "Continue anyway (not recommended)? [y/N]: " continue_choice
    if [[ ! $continue_choice =~ ^[Yy]$ ]]; then
        rollback_project "$PROJECT_NAME"
        exit 1
    fi
fi
```

## Benefits

### For Users

**Without Error Handling:**
```bash
# User runs script
./create-project.sh
# ... 15 minutes of setup ...
# Clerk API fails
# ERROR: Script exits
# User has to start completely over
```

**With Error Handling:**
```bash
# User runs script
./create-project.sh
# ... 15 minutes of setup ...
# Clerk API fails

⚠️  CLERK SETUP FAILED
Recovery Options:
  1) Retry
  2) Skip - Skip this step and continue
  3) Manual - I'll fix it later
  4) Abort

# User chooses 3 (Manual)
# Setup continues with other services
# User completes Clerk manually later using SETUP_GUIDE.md
```

### For Debugging

- State files preserve configuration for debugging
- Can inspect exactly where setup failed
- Resume without re-entering all choices
- Faster iteration during development

## Testing Error Handling

### Test Resume Functionality

```bash
# Simulate failure by killing script
./create-project.sh
# Press Ctrl+C during Convex setup

# Resume
./create-project.sh
# Should detect previous attempt and offer resume
```

### Test Recovery Options

```bash
# Simulate service failure
# Edit scripts/setup-clerk.sh to add: exit 1

./create-project.sh
# When Clerk fails, test each recovery option:
# 1. Retry (should fail again)
# 2. Skip (should continue)
# 3. Manual (should mark complete)
# 4. Abort (should save state)
```

### Test Rollback

```bash
./create-project.sh
# When build fails, choose to rollback
# Verify project directory is deleted
```

## Environment Validation

Before setup starts, validates:
- ✅ Node.js installed
- ✅ Package manager available (npm/pnpm/yarn)
- ✅ Git installed
- ✅ Sufficient disk space (500MB+)
- ⚠️ Warns about low disk space

## State File Format

### progress.state
```
10
```
Just the last completed step number.

### config.state
```bash
PROJECT_NAME="my-saas-app"
PACKAGE_MANAGER="npm"
FRAMEWORK="nextjs"
USE_VERCEL=true
USE_CONVEX=true
USE_CLERK=true
USE_AXIOM=false
USE_LINEAR=false
USE_SHADCN=true
USE_AI=false
AI_PROVIDER="none"
USE_ADMIN=false
ADMIN_PROD_ENABLED=false
TIMESTAMP=1699024845
```

All configuration preserved for resume.

## Fallback Strategies

### Service Failures

| Service | Fallback Strategy |
|---------|------------------|
| **Vercel** | Manual linking later with `vercel link` |
| **Convex** | Manual init with `npx convex dev` |
| **Clerk** | Manual setup via dashboard (see SETUP_GUIDE.md) |
| **Axiom** | Manual CLI setup with `axiom auth login` |
| **Linear** | Manual API key entry (see SETUP_GUIDE.md) |

### Build Failures

1. **Option 1**: Fix errors and re-run build
2. **Option 2**: Continue anyway (not recommended)
3. **Option 3**: Rollback and start fresh

## Cleanup

State is automatically cleaned up on successful completion:

```bash
✓ Git repository initialized
✓ State tracking cleaned up

╔═══════════════════════════════════════════════════╗
║          🎉 PROJECT SETUP COMPLETE! 🎉           ║
╚═══════════════════════════════════════════════════╝
```

## Security Considerations

- State files stored in hidden directory (`.launchify-state/`)
- State files contain no secrets (only configuration)
- State directory added to `.gitignore` automatically
- State cleaned up on successful completion
- No sensitive data persisted to disk

## Future Enhancements

Potential improvements:
- [ ] Parallel service setup with dependency management
- [ ] Automatic retry with exponential backoff
- [ ] Health checks after each service setup
- [ ] Undo/redo functionality
- [ ] State encryption for sensitive configs
- [ ] Cloud state sync for team setups
- [ ] Automated issue reporting on failures

## Comparison

### Current System (Without Integration)

| Scenario | Behavior |
|----------|----------|
| Service fails | Script exits immediately |
| User input wrong | Start over from beginning |
| Network timeout | Lose all progress |
| Build errors | Continue anyway (unsafe) |

### With Error Handling (After Integration)

| Scenario | Behavior |
|----------|----------|
| Service fails | Offer recovery options + helpful error message |
| User input wrong | Resume from checkpoint |
| Network timeout | Retry or skip, preserve progress |
| Build errors | Block or confirm override |

## Recommendation

**Integrate error handling system in phases:**

1. ✅ **Phase 1** (Quick Win): Add basic resume functionality and environment validation
2. ✅ **Phase 2** (Medium): Wrap all service setups with error handling
3. ✅ **Phase 3** (Polish): Stricter build validation and rollback

This provides users with a professional, resilient setup experience while maintaining the existing automation.
