#!/usr/bin/env node

/**
 * Config Cleanup Script
 *
 * Removes unused AI editor configuration folders and files, keeping only
 * the one the user is currently using.
 *
 * Uses .ai/last-update.json to safely track what can be deleted.
 *
 * WARNING: This is NOT recommended unless user is absolutely certain
 * they will only ever use one AI editor.
 */

const fs = require('fs');
const path = require('path');
const readline = require('readline');

// Load editor metadata from tracking file
function loadEditorMetadata() {
  const metadataPath = path.join(process.cwd(), '.ai/last-update.json');

  if (!fs.existsSync(metadataPath)) {
    console.error('❌ Cannot find .ai/last-update.json');
    console.error('   This file tracks which configs are safe to delete.');
    console.error('   Run: node .ai/scripts/generate-configs.js');
    process.exit(1);
  }

  try {
    const content = fs.readFileSync(metadataPath, 'utf8');
    return JSON.parse(content);
  } catch (error) {
    console.error('❌ Error reading metadata:', error.message);
    process.exit(1);
  }
}

function detectCurrentEditor(metadata) {
  // Check environment variables
  if (process.env.CURSOR_PROJECT) return 'cursor';
  if (process.env.WINDSURF_PROJECT) return 'windsurf';
  if (process.env.VSCODE_PID) return 'vscode';
  if (process.env.ZED_PROJECT) return 'zed';

  // Check which config folder has been accessed recently
  const editorFolders = Object.entries(metadata.editors || {}).map(([name, config]) => ({
    name,
    folder: config.folder
  }));

  const stats = editorFolders.map(({ name, folder }) => {
    const fullPath = path.join(process.cwd(), folder);
    if (fs.existsSync(fullPath)) {
      try {
        const stat = fs.statSync(fullPath);
        return { editor: name, accessed: stat.atimeMs };
      } catch (e) {
        return null;
      }
    }
    return null;
  }).filter(Boolean);

  // Return most recently accessed
  if (stats.length > 0) {
    stats.sort((a, b) => b.accessed - a.accessed);
    return stats[0].editor;
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

  // Load metadata for safe deletion tracking
  const metadata = loadEditorMetadata();
  const current = detectCurrentEditor(metadata);

  if (!current) {
    console.log('\n❌ Could not detect current editor. Aborting for safety.');
    console.log('   (This is good! It means you can keep all configs.)\n');
    return;
  }

  console.log(`\n✓ Detected editor: ${current}\n`);

  // Build list of files/folders that can be safely deleted
  const toDelete = {
    folders: [],
    files: []
  };

  let editorCount = 0;
  for (const [editorName, config] of Object.entries(metadata.editors || {})) {
    // Skip current editor
    if (editorName === current) continue;

    // Only delete if explicitly marked as safe
    if (config.safe_to_delete !== true) {
      console.log(`⚠️  Skipping ${editorName} (not marked as safe to delete)`);
      continue;
    }

    editorCount++;

    // Add folder if it exists
    if (config.folder && fs.existsSync(path.join(process.cwd(), config.folder))) {
      toDelete.folders.push(config.folder);
    }

    // Add instruction file(s) if they exist
    if (config.instruction_file) {
      const filePath = path.join(process.cwd(), config.instruction_file);
      if (fs.existsSync(filePath)) {
        toDelete.files.push(config.instruction_file);
      }
    }

    if (config.instruction_files) {
      for (const file of config.instruction_files) {
        const filePath = path.join(process.cwd(), file);
        if (fs.existsSync(filePath)) {
          toDelete.files.push(file);
        }
      }
    }
  }

  if (toDelete.folders.length === 0 && toDelete.files.length === 0) {
    console.log('\n✓ Nothing to clean up. All configs are for your current editor.\n');
    return;
  }

  // Show what will be deleted
  console.log(`Found ${editorCount} other editor(s) to remove:\n`);

  if (toDelete.folders.length > 0) {
    console.log('Folders to delete:');
    toDelete.folders.forEach(f => console.log(`  - ${f}/`));
  }

  if (toDelete.files.length > 0) {
    console.log('\nFiles to delete:');
    toDelete.files.forEach(f => console.log(`  - ${f}`));
  }
  console.log('');

  const confirmed = await confirm(
    `Keep ONLY ${current} configs and delete ${toDelete.folders.length + toDelete.files.length} items? (yes/no): `
  );

  if (!confirmed) {
    console.log('\n✓ Keeping all configurations (recommended!)');
    console.log('  You can switch between AI editors anytime.');
    console.log('  Each editor ignores folders it doesn\'t use.\n');
    return;
  }

  console.log('\n🧹 Cleaning up unused configurations...\n');

  let removed = 0;

  // Delete folders
  for (const folder of toDelete.folders) {
    const fullPath = path.join(process.cwd(), folder);
    try {
      fs.rmSync(fullPath, { recursive: true, force: true });
      console.log(`  ✓ Removed ${folder}/`);
      removed++;
    } catch (error) {
      console.log(`  ✗ Failed to remove ${folder}/: ${error.message}`);
    }
  }

  // Delete files
  for (const file of toDelete.files) {
    const fullPath = path.join(process.cwd(), file);
    try {
      fs.unlinkSync(fullPath);
      console.log(`  ✓ Removed ${file}`);
      removed++;
    } catch (error) {
      console.log(`  ✗ Failed to remove ${file}: ${error.message}`);
    }
  }

  console.log(`\n✨ Cleaned up ${removed} items.`);
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
