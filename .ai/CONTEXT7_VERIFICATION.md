# Context7 Setup Verification Checklist

**FOR AI ASSISTANTS ONLY**

This checklist guides you (the AI) through verifying Context7 is properly configured. Users should NEVER run these commands - YOU run them.

## Pre-Setup Verification

Before running `npm run setup-context7`, YOU verify:

- [ ] User has a Context7 account at https://context7.com
- [ ] User has created an API key in the dashboard
- [ ] User has their API key ready to paste
- [ ] YOU check you're in the project root directory (`pwd`)
- [ ] YOU check Node.js v18 or newer is installed (`node --version`)

## Post-Setup Verification

After YOU run `npm run setup-context7`, YOU check:

### 1. Config Files Updated

**For Cursor users:**
- [ ] YOU read `.cursor/mcp_settings.json` using the Read tool
- [ ] YOU verify server is named `"context7"` (NOT `"context7-disabled"`)
- [ ] YOU verify the actual API key is in the `args` array (NOT `"YOUR_CONTEXT7_API_KEY"`)
- [ ] YOU verify no `comment`, `comment2`, etc. fields exist

**For Windsurf users:**
- [ ] YOU read `.windsurf/mcp.json` using the Read tool
- [ ] YOU verify server is named `"context7"` (NOT `"context7-disabled"`)
- [ ] YOU verify the actual API key is in `headers.CONTEXT7_API_KEY`
- [ ] YOU verify `serverUrl` is `"https://mcp.context7.com/mcp"`

**For VS Code/Copilot users:**
- [ ] YOU read `.vscode/settings.json` using the Read tool
- [ ] YOU verify server is named `"context7"` under `github.copilot.mcp.servers`
- [ ] YOU verify the actual API key is in `headers.CONTEXT7_API_KEY`
- [ ] YOU verify `url` is `"https://mcp.context7.com/mcp"`

**For Codex users:**
- [ ] YOU read `.codex/config.toml` using the Read tool
- [ ] YOU verify `[mcp.servers.context7]` section is uncommented
- [ ] YOU verify the actual API key is in the args array
- [ ] YOU verify no comment lines remain above the config

### 2. Editor Restart

- [ ] YOU tell the user to completely quit their AI editor (Cursor/Windsurf/VS Code/etc.)
- [ ] YOU tell them to wait 3 seconds
- [ ] YOU tell them to reopen their AI editor
- [ ] YOU tell them to open this project

### 3. Functional Testing

**Test 1: Basic Context7 Query**
- [ ] YOU tell the user: "Let's test Context7. Ask me: 'Use Context7 to show me the latest Next.js 16 documentation'"
- [ ] YOU should be able to use Context7
- [ ] YOU mention using Context7 in your response
- [ ] YOU include current Next.js 16 features

**Test 2: Verify Current Information**
- [ ] YOU suggest: "Try asking me: 'What's new in React 19?'"
- [ ] YOU reference Context7 for up-to-date info
- [ ] YOU include React 19 features (Actions, useOptimistic, etc.)

**Test 3: Framework-Specific Query**
- [ ] YOU suggest: "Try: 'Show me how to create a Server Component in Next.js 16'"
- [ ] YOU use Context7 to fetch current syntax
- [ ] YOU provide code examples using Next.js 16 conventions

## Troubleshooting

### Setup Script Failed

**Error: "Invalid API key"**
- YOU check for typos in the API key
- YOU ensure it starts with `ctx7_`
- YOU tell user to verify key is active in Context7 dashboard

**Error: "File not found"**
- YOU run `pwd` to verify you're in the project root
- YOU run `ls -la .cursor .windsurf .vscode` to verify config folders exist

**Error: "Node version too old"**
- YOU run `node --version` to check
- YOU tell user Node.js needs to be upgraded to v18 or newer

### Context7 Not Working After Setup

**You (AI) can't access Context7:**
- YOU verify config files were updated (see checklist above)
- YOU ensure user restarted their editor completely
- YOU check the editor's MCP server status (if available in logs)

**"Connection failed" or similar error:**
- YOU tell user to check their internet connection
- YOU verify `https://mcp.context7.com/mcp` URL is correct in configs
- YOU tell user to verify API key hasn't been revoked in dashboard

**You (AI) still give outdated information:**
- YOU check if Context7 is disabled (server name is "context7-disabled")
- YOU verify server name is "context7" in config files
- YOU check for typos in MCP URL

### Manual Verification Steps

If automated setup doesn't work, YOU manually verify:

1. **YOU check JSON syntax using Bash:**
   ```bash
   # For Cursor
   cat .cursor/mcp_settings.json | jq .

   # For Windsurf
   cat .windsurf/mcp.json | jq .

   # For VS Code
   cat .vscode/settings.json | jq .
   ```

   Should show valid JSON with no syntax errors.

2. **YOU check API key format:**
   - Should start with `ctx7_`
   - Should be ~40-50 characters long
   - No spaces or newlines

3. **YOU check network connectivity using Bash:**
   ```bash
   curl -I https://mcp.context7.com/mcp
   ```

   Should return HTTP 200 or similar (not connection refused).

## Success Criteria

Context7 is working correctly when:

✅ Config files show `"context7"` (not disabled)
✅ Your actual API key is present in configs
✅ AI explicitly mentions using Context7
✅ Responses include current, up-to-date information
✅ Code examples use latest framework versions
✅ No connection errors in editor logs

## Additional Notes

### MCP vs Direct API

This template configures **MCP integration only**:
- **MCP URL**: `https://mcp.context7.com/mcp` ✅ Configured
- **Direct API**: `https://context7.com/api/v1` ❌ Not configured (not needed)

The direct API is for custom integrations. AI editors use MCP, which is what we've set up.

### API Key Security

Your API key is stored in:
- `.cursor/mcp_settings.json`
- `.windsurf/mcp.json`
- `.vscode/settings.json`
- `.codex/config.toml`

These files are in `.gitignore` and won't be committed to version control.

**Never commit your API key to GitHub.**

### Re-running Setup

If user needs to update or change their API key, YOU:

```bash
# YOU re-run the setup script
npm run setup-context7
```

**Do not** tell the user to run this themselves.

### When User Asks for Help

YOU (the AI) should:
1. Check this verification checklist first
2. Read `.ai/services/context7.md` for detailed guides
3. Use WebFetch to check https://context7.com/docs for official documentation
4. Run diagnostic commands yourself (never ask user to run them)

---

**Last Updated:** 2025-01-14
**Template Version:** 2.0.0
