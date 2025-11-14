#!/usr/bin/env node

/**
 * Config Cleanup Script
 *
 * Removes unused AI editor configuration folders, keeping only the one
 * the user is currently using.
 *
 * WARNING: This is NOT recommended unless user is absolutely certain
 * they will only ever use one AI editor.
 */

const fs = require('fs');
const path = require('path');
const readline = require('readline');

const CONFIG_FOLDERS = [
  '.cursor',
  '.windsurf',
  '.codex',
  '.vscode',
  '.continue',
  '.gemini',
  '.idx',
  '.zed',
  '.warp',
  '.lmstudio',
  '.aider',
  '.cline'
];

function detectCurrentEditor() {
  // Check environment variables
  if (process.env.CURSOR_PROJECT) return 'cursor';
  if (process.env.WINDSURF_PROJECT) return 'windsurf';
  if (process.env.VSCODE_PID) return 'vscode';
  if (process.env.ZED_PROJECT) return 'zed';

  // Check which config folder has been accessed recently
  const stats = CONFIG_FOLDERS.map(folder => {
    const fullPath = path.join(process.cwd(), folder);
    if (fs.existsSync(fullPath)) {
      try {
        const stat = fs.statSync(fullPath);
        return { folder, accessed: stat.atimeMs };
      } catch (e) {
        return null;
      }
    }
    return null;
  }).filter(Boolean);

  // Return most recently accessed
  if (stats.length > 0) {
    stats.sort((a, b) => b.accessed - a.accessed);
    return stats[0].folder.replace('.', '');
  }

  return null;
}

async function confirm(question) {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
  });

  return new Promise(resolve => {
    rl.question(question, answer => {
      rl.close();
      resolve(answer.toLowerCase() === 'yes');
    });
  });
}

async function cleanup() {
  console.log('\n⚠️  CONFIGURATION CLEANUP WARNING\n');
  console.log('═'.repeat(60));
  console.log('\nThis template includes configs for ALL AI editors so you can');
  console.log('switch between Cursor, Windsurf, Claude Code, Codex, etc.\n');
  console.log('If you clean up, Context7 will ONLY work in your current editor.');
  console.log('Other editors will get outdated documentation and broken code.\n');
  console.log('═'.repeat(60));

  const current = detectCurrentEditor();

  if (!current) {
    console.log('\n❌ Could not detect current editor. Aborting for safety.');
    console.log('   (This is good! It means you can keep all configs.)\n');
    return;
  }

  console.log(`\n✓ Detected editor: ${current}\n`);

  // Count how many configs exist
  const existing = CONFIG_FOLDERS.filter(folder =>
    fs.existsSync(path.join(process.cwd(), folder))
  );

  console.log(`You currently have ${existing.length} editor configs:`);
  existing.forEach(folder => console.log(`  - ${folder}`));
  console.log('');

  const confirmed = await confirm(
    `Keep ONLY .${current}/ and delete the other ${existing.length - 1} configs? (yes/no): `
  );

  if (!confirmed) {
    console.log('\n✓ Keeping all configurations (recommended!)');
    console.log('  You can switch between AI editors anytime.');
    console.log('  Each editor ignores folders it doesn\'t use.\n');
    return;
  }

  console.log('\n🧹 Cleaning up unused configurations...\n');

  let removed = 0;
  for (const folder of CONFIG_FOLDERS) {
    if (folder === `.${current}`) continue;

    const fullPath = path.join(process.cwd(), folder);
    if (fs.existsSync(fullPath)) {
      try {
        fs.rmSync(fullPath, { recursive: true, force: true });
        console.log(`  ✓ Removed ${folder}/`);
        removed++;
      } catch (error) {
        console.log(`  ✗ Failed to remove ${folder}/: ${error.message}`);
      }
    }
  }

  console.log(`\n✨ Cleaned up ${removed} configurations.`);
  console.log(`⚠️  Context7 now ONLY works in ${current}.\n`);

  // Create a restore script
  const restoreScript = `#!/bin/bash
# Restore all AI editor configurations
echo "Restoring all AI editor configurations..."
echo ""

# Run the config generator to recreate all configs
if [ -f ".ai/scripts/generate-configs.js" ]; then
    node .ai/scripts/generate-configs.js
    echo ""
    echo "✓ Restored! Context7 now works in all editors again."
else
    echo "❌ Cannot find config generator script."
    echo "   You may need to re-clone from the template repository."
fi
`;

  const restorePath = path.join(process.cwd(), '.ai/scripts/restore-configs.sh');
  fs.writeFileSync(restorePath, restoreScript, { mode: 0o755 });

  console.log('💡 To restore all configs later, run:');
  console.log('   bash .ai/scripts/restore-configs.sh');
  console.log('   or');
  console.log('   node .ai/scripts/generate-configs.js\n');
}

// Handle Ctrl+C gracefully
process.on('SIGINT', () => {
  console.log('\n\n✓ Cancelled. All configurations kept.\n');
  process.exit(0);
});

cleanup().catch(error => {
  console.error('\n❌ Error:', error.message);
  process.exit(1);
});
