#!/usr/bin/env node

/**
 * Context7 Setup Script
 *
 * Enables Context7 across all AI editor configurations by:
 * 1. Prompting for Context7 API key
 * 2. Updating all config files with the API key
 * 3. Renaming "context7-disabled" to "context7" to activate it
 */

const fs = require('fs');
const path = require('path');
const readline = require('readline');

const CONFIG_FILES = [
  {
    path: '.cursor/mcp_settings.json',
    type: 'json',
    editor: 'Cursor'
  },
  {
    path: '.windsurf/mcp.json',
    type: 'json',
    editor: 'Windsurf'
  },
  {
    path: '.vscode/settings.json',
    type: 'json',
    editor: 'VS Code / Copilot'
  },
  {
    path: '.codex/config.toml',
    type: 'toml',
    editor: 'OpenAI Codex'
  }
];

async function promptForApiKey() {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
  });

  console.log('\n🔑 Context7 Setup\n');
  console.log('Context7 provides up-to-date documentation for AI assistants.');
  console.log('This helps prevent outdated code and hallucinations.\n');
  console.log('📍 Get your FREE API key at: https://context7.com/dashboard');
  console.log('   (Sign up takes ~30 seconds)\n');

  return new Promise(resolve => {
    rl.question('Enter your Context7 API key: ', answer => {
      rl.close();
      resolve(answer.trim());
    });
  });
}

function updateJSONConfig(filePath, apiKey) {
  const fullPath = path.join(process.cwd(), filePath);

  if (!fs.existsSync(fullPath)) {
    console.log(`  ⚠️  ${filePath} not found, skipping`);
    return false;
  }

  try {
    const content = fs.readFileSync(fullPath, 'utf8');
    const config = JSON.parse(content);

    // Find the disabled context7 config
    let updated = false;

    // For different config structures
    if (config.mcpServers && config.mcpServers['context7-disabled']) {
      // Rename key and update API key
      const serverConfig = config.mcpServers['context7-disabled'];
      delete serverConfig.comment;
      delete serverConfig.comment2;
      delete serverConfig.comment3;
      delete serverConfig.comment4;

      // Update API key in args or headers
      if (serverConfig.args) {
        const keyIndex = serverConfig.args.indexOf('YOUR_CONTEXT7_API_KEY');
        if (keyIndex !== -1) {
          serverConfig.args[keyIndex] = apiKey;
        }
      }
      if (serverConfig.headers && serverConfig.headers.CONTEXT7_API_KEY) {
        serverConfig.headers.CONTEXT7_API_KEY = apiKey;
      }

      // Rename from context7-disabled to context7
      config.mcpServers['context7'] = serverConfig;
      delete config.mcpServers['context7-disabled'];
      updated = true;
    }

    // For Copilot format
    if (config['github.copilot.mcp.servers'] &&
        config['github.copilot.mcp.servers']['context7-disabled']) {
      const serverConfig = config['github.copilot.mcp.servers']['context7-disabled'];
      delete serverConfig.comment;
      delete serverConfig.comment2;
      delete serverConfig.comment3;
      delete serverConfig.comment4;

      if (serverConfig.headers && serverConfig.headers.CONTEXT7_API_KEY) {
        serverConfig.headers.CONTEXT7_API_KEY = apiKey;
      }

      config['github.copilot.mcp.servers']['context7'] = serverConfig;
      delete config['github.copilot.mcp.servers']['context7-disabled'];
      updated = true;
    }

    if (updated) {
      fs.writeFileSync(fullPath, JSON.stringify(config, null, 2), 'utf8');
      return true;
    }

    return false;
  } catch (error) {
    console.log(`  ❌ Error updating ${filePath}: ${error.message}`);
    return false;
  }
}

function updateTOMLConfig(filePath, apiKey) {
  const fullPath = path.join(process.cwd(), filePath);

  if (!fs.existsSync(fullPath)) {
    console.log(`  ⚠️  ${filePath} not found, skipping`);
    return false;
  }

  try {
    let content = fs.readFileSync(fullPath, 'utf8');

    // Uncomment the config and replace API key
    content = content.replace(/^# \[mcp\.servers\.context7\]/gm, '[mcp.servers.context7]');
    content = content.replace(/^# command/gm, 'command');
    content = content.replace(/^# args/gm, 'args');
    content = content.replace('YOUR_CONTEXT7_API_KEY', apiKey);

    // Remove the "disabled" comments
    const lines = content.split('\n').filter(line =>
      !line.includes('DISABLED') &&
      !line.includes('To enable:') &&
      !line.includes('Sign up at') &&
      !line.includes('Run: npm') &&
      !line.includes('Restart Codex') &&
      !line.includes('Uncomment and add')
    );

    content = lines.join('\n');

    fs.writeFileSync(fullPath, content, 'utf8');
    return true;
  } catch (error) {
    console.log(`  ❌ Error updating ${filePath}: ${error.message}`);
    return false;
  }
}

async function main() {
  // Check if already set up
  const cursorPath = path.join(process.cwd(), '.cursor/mcp_settings.json');
  if (fs.existsSync(cursorPath)) {
    const content = JSON.parse(fs.readFileSync(cursorPath, 'utf8'));
    if (content.mcpServers && content.mcpServers.context7) {
      console.log('\n✅ Context7 is already enabled!\n');
      console.log('To update your API key, edit the config files directly:');
      CONFIG_FILES.forEach(f => console.log(`  - ${f.path}`));
      console.log('');
      return;
    }
  }

  const apiKey = await promptForApiKey();

  if (!apiKey || apiKey === '' || apiKey === 'YOUR_CONTEXT7_API_KEY') {
    console.log('\n❌ Invalid API key. Setup cancelled.\n');
    console.log('Get your API key at: https://context7.com/dashboard\n');
    return;
  }

  console.log('\n📝 Updating configurations...\n');

  let successCount = 0;
  for (const config of CONFIG_FILES) {
    process.stdout.write(`  ${config.editor}... `);

    let success = false;
    if (config.type === 'json') {
      success = updateJSONConfig(config.path, apiKey);
    } else if (config.type === 'toml') {
      success = updateTOMLConfig(config.path, apiKey);
    }

    if (success) {
      console.log('✅');
      successCount++;
    } else {
      console.log('⚠️ ');
    }
  }

  console.log(`\n✨ Setup complete! Context7 enabled in ${successCount} editor(s).\n`);
  console.log('📌 Next steps:');
  console.log('  1. Restart your AI editor (Cursor, Windsurf, VS Code, etc.)');
  console.log('  2. Try asking: "use context7 to show me latest Next.js examples"');
  console.log('  3. Your AI will now use current, accurate documentation!\n');
  console.log('🧪 Verification:');
  console.log('  Check .ai/CONTEXT7_VERIFICATION.md for a complete testing checklist\n');
  console.log('💡 Note: Context7 is free for public repositories.');
  console.log('   For private repos, check: https://context7.com/pricing\n');
}

main().catch(error => {
  console.error('\n❌ Setup failed:', error.message);
  process.exit(1);
});
