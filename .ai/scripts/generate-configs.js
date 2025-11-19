#!/usr/bin/env node

/**
 * Context7 Configuration Generator
 *
 * This script fetches the latest supported AI editors from Context7's repository
 * and generates configuration files for each platform automatically.
 *
 * Runs via GitHub Actions daily to keep configs up-to-date.
 */

const fs = require('fs');
const path = require('path');
const https = require('https');

// Fetch function for Node.js
function fetch(url) {
  return new Promise((resolve, reject) => {
    https.get(url, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => resolve(data));
      res.on('error', reject);
    }).on('error', reject);
  });
}

// Known instruction file conventions (from Context7 README and editor docs)
const KNOWN_INSTRUCTION_FILES = {
  'cursor': '.cursorrules',
  'windsurf': '.windsurfrules',
  'claude-code': 'CLAUDE.md',
  'codex': 'CODEX.md'
};

// Template for instruction files
function createInstructionContent(editorName) {
  const displayName = editorName.toUpperCase().replace('-', ' ');
  return `# 🚨 ${displayName}: READ THIS FIRST

## Before Responding to ANY User Request

**YOU MUST READ:**
1. \`.ai/MANDATORY_READ_FIRST.md\` - Critical instructions
2. \`.ai/onboarding/first-interaction.md\` - If this is user's first request

## Key Points

- This template is for **NON-DEVELOPERS**
- Use **simple language** (explain like they're 5 years old)
- Always check \`.ai/testing/current-settings.json\` for testing preferences
- Use **context7** for up-to-date documentation: \`use context7 for Next.js 16 syntax\`
- Follow flexible rules from \`.ai/rules/flexible-rules.md\`

## Multiple Config Folders

You'll see \`.cursor/\`, \`.windsurf/\`, \`.codex/\`, etc.
**This is intentional!** Users may switch between AI editors.
Do NOT suggest removing them unless user explicitly wants to.

See: \`.ai/config-management/explaining-configs.md\`

## Workflow

1. Check if onboarding needed (\`.ai/onboarding/completed.json\` exists?)
2. If not, run onboarding workflow
3. Follow appropriate workflow from \`.ai/workflows/\`
4. Be patient, kind, and thorough

**Remember:** User is relying on you to build their dream. Don't overwhelm them with jargon!
`;
}

// Platform configurations
const PLATFORM_CONFIGS = {
  cursor: {
    path: '.cursor/mcp_settings.json',
    instructionFile: '.cursorrules',
    format: 'json',
    partOfTemplate: true,
    template: () => ({
      mcpServers: {
        "context7-disabled": {
          comment: "Context7 provides up-to-date documentation. To enable:",
          comment2: "1. Sign up at https://context7.com/dashboard for free API key",
          comment3: "2. Run: npm run setup-context7",
          comment4: "3. Restart Cursor",
          command: "npx",
          args: ["-y", "@upstash/context7-mcp", "--api-key", "YOUR_CONTEXT7_API_KEY"]
        }
      }
    })
  },
  windsurf: {
    path: '.windsurf/mcp.json',
    instructionFile: '.windsurfrules',
    format: 'json',
    partOfTemplate: true,
    template: () => ({
      mcpServers: {
        "context7-disabled": {
          comment: "Context7 provides up-to-date documentation. To enable:",
          comment2: "1. Sign up at https://context7.com/dashboard for free API key",
          comment3: "2. Run: npm run setup-context7",
          comment4: "3. Restart Windsurf",
          serverUrl: "https://mcp.context7.com/mcp",
          headers: {
            CONTEXT7_API_KEY: "YOUR_CONTEXT7_API_KEY"
          }
        }
      }
    })
  },
  vscode: {
    path: '.vscode/settings.json',
    instructionFile: null, // VS Code might have user settings - don't auto-generate
    format: 'json',
    partOfTemplate: true,
    template: () => ({
      "github.copilot.mcp.servers": {
        "context7-disabled": {
          comment: "Context7 provides up-to-date documentation. To enable:",
          comment2: "1. Sign up at https://context7.com/dashboard for free API key",
          comment3: "2. Run: npm run setup-context7",
          comment4: "3. Restart VS Code",
          type: "http",
          url: "https://mcp.context7.com/mcp",
          headers: {
            CONTEXT7_API_KEY: "YOUR_CONTEXT7_API_KEY"
          }
        }
      }
    })
  },
  copilot: {
    path: '.github/copilot.json',
    format: 'json',
    template: () => ({
      mcp: {
        servers: {
          context7: {
            command: "npx",
            args: ["-y", "@upstash/context7"]
          }
        }
      }
    })
  },
  continue: {
    path: '.continue/config.json',
    format: 'json',
    template: () => ({
      mcpServers: [{
        name: "context7",
        command: "npx",
        args: ["-y", "@upstash/context7"]
      }]
    })
  },
  idx: {
    path: '.idx/mcp.json',
    format: 'json',
    template: () => ({
      mcpServers: {
        context7: {
          command: "npx",
          args: ["-y", "@upstash/context7"]
        }
      }
    })
  },
  gemini: {
    path: '.gemini/settings.json',
    format: 'json',
    template: () => ({
      mcpServers: {
        context7: {
          command: "npx",
          args: ["-y", "@upstash/context7"]
        }
      }
    })
  },
  codex: {
    path: '.codex/config.toml',
    instructionFile: 'CODEX.md',
    format: 'toml',
    partOfTemplate: true,
    template: () => `# Context7 Configuration (DISABLED by default)
# Context7 provides up-to-date documentation for AI assistants
#
# To enable:
# 1. Sign up at https://context7.com/dashboard for free API key
# 2. Run: npm run setup-context7
# 3. Restart Codex
#
# Uncomment and add your API key:
# [mcp.servers.context7]
# command = "npx"
# args = ["-y", "@upstash/context7-mcp", "--api-key", "YOUR_CONTEXT7_API_KEY"]
`
  },
  zed: {
    path: '.zed/settings.json',
    format: 'json',
    template: () => ({
      mcpServers: {
        context7: {
          command: "npx",
          args: ["-y", "@upstash/context7"]
        }
      }
    })
  },
  warp: {
    path: '.warp/mcp.json',
    format: 'json',
    template: () => ({
      mcpServers: {
        context7: {
          command: "npx",
          args: ["-y", "@upstash/context7"]
        }
      }
    })
  },
  'lm-studio': {
    path: '.lmstudio/mcp.json',
    format: 'json',
    template: () => ({
      mcpServers: {
        context7: {
          command: "npx",
          args: ["-y", "@upstash/context7"]
        }
      }
    })
  },
  aider: {
    path: '.aider/mcp.yml',
    format: 'yaml',
    template: () => `# Auto-generated Context7 configuration
# Last updated: ${new Date().toISOString()}

mcpServers:
  context7:
    command: npx
    args:
      - "-y"
      - "@upstash/context7"
`
  },
  cline: {
    path: '.cline/config.json',
    format: 'json',
    template: () => ({
      mcpServers: {
        context7: {
          command: "npx",
          args: ["-y", "@upstash/context7"]
        }
      }
    })
  }
};

async function fetchSupportedPlatforms() {
  console.log('🔍 Fetching Context7 supported platforms...');

  try {
    // Fetch Context7's README
    const readme = await fetch(
      'https://raw.githubusercontent.com/upstash/context7/main/README.md'
    );

    const platforms = [];
    const lowerReadme = readme.toLowerCase();

    // Check which platforms are mentioned in Context7's README
    for (const [name, config] of Object.entries(PLATFORM_CONFIGS)) {
      if (lowerReadme.includes(name.replace('-', ' ')) || lowerReadme.includes(name)) {
        platforms.push({ name, ...config });
        console.log(`  ✓ Found: ${name}`);
      }
    }

    // Always include these core platforms even if not explicitly mentioned
    const corePlatforms = ['cursor', 'vscode', 'windsurf', 'codex'];
    for (const core of corePlatforms) {
      if (!platforms.find(p => p.name === core)) {
        platforms.push({ name: core, ...PLATFORM_CONFIGS[core] });
        console.log(`  ✓ Added core platform: ${core}`);
      }
    }

    return platforms;

  } catch (error) {
    console.error('❌ Error fetching Context7 info:', error.message);
    // Fallback to core platforms
    console.log('📦 Using core platforms as fallback');
    return Object.entries(PLATFORM_CONFIGS)
      .filter(([name]) => ['cursor', 'vscode', 'windsurf', 'codex', 'continue'].includes(name))
      .map(([name, config]) => ({ name, ...config }));
  }
}

function generateConfigFile(platform) {
  const { path: configPath, template, format = 'json' } = platform;
  const fullPath = path.join(process.cwd(), configPath);

  // Create directory
  const dir = path.dirname(fullPath);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }

  // Generate content
  let content;
  if (format === 'json') {
    content = JSON.stringify(template(), null, 2);
  } else {
    content = template();
  }

  // Write file
  fs.writeFileSync(fullPath, content, 'utf8');
  console.log(`✓ Generated ${configPath}`);
}

function generateInstructionFiles(editorName, knownFile = null) {
  const generatedFiles = [];

  if (knownFile) {
    // We know the convention, generate only that file
    const filePath = path.join(process.cwd(), knownFile);
    if (!fs.existsSync(filePath)) {
      fs.writeFileSync(filePath, createInstructionContent(editorName), 'utf8');
      console.log(`✓ Generated ${knownFile}`);
      generatedFiles.push(knownFile);
    }
  } else {
    // Unknown editor - use shotgun approach (generate multiple common patterns)
    const patterns = [
      `.${editorName}rules`,                    // Pattern 1: .cursorrules, .windsurfrules
      `${editorName.toUpperCase()}.md`,         // Pattern 2: CLAUDE.md, CODEX.md
      `.${editorName}/README.md`                // Pattern 3: Universal fallback
    ];

    for (const pattern of patterns) {
      const filePath = path.join(process.cwd(), pattern);
      const dir = path.dirname(filePath);

      // Create directory if needed
      if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
      }

      // Generate file
      if (!fs.existsSync(filePath)) {
        fs.writeFileSync(filePath, createInstructionContent(editorName), 'utf8');
        console.log(`✓ Generated ${pattern}`);
        generatedFiles.push(pattern);
      }
    }
  }

  return generatedFiles;
}

async function main() {
  try {
    console.log('\n🤖 Context7 Configuration Generator\n');

    const platforms = await fetchSupportedPlatforms();

    console.log(`\n📦 Generating configs for ${platforms.length} platforms\n`);

    // Track all editors and their files
    const editorTracking = {};

    for (const platform of platforms) {
      const editorName = platform.name;
      const isPartOfTemplate = platform.partOfTemplate === true;
      const knownInstructionFile = platform.instructionFile || KNOWN_INSTRUCTION_FILES[editorName];

      // Generate MCP config
      generateConfigFile(platform);

      // Generate instruction files for new platforms
      let instructionFiles = [];
      if (!isPartOfTemplate && knownInstructionFile) {
        // Known convention but new platform
        instructionFiles = generateInstructionFiles(editorName, knownInstructionFile);
      } else if (!isPartOfTemplate && !knownInstructionFile) {
        // Unknown platform - use shotgun approach
        console.log(`⚠️  New editor detected: ${editorName} (using multi-pattern approach)`);
        instructionFiles = generateInstructionFiles(editorName, null);
      }

      // Track this editor
      const folderName = path.dirname(platform.path);
      editorTracking[editorName] = {
        folder: folderName,
        mcp_config: platform.path,
        instruction_file: knownInstructionFile || null,
        instruction_files: instructionFiles.length > 0 ? instructionFiles : undefined,
        part_of_template: isPartOfTemplate,
        auto_generated: !isPartOfTemplate,
        safe_to_delete: editorName !== 'vscode' // VS Code might have user settings
      };
    }

    // Update metadata file with comprehensive tracking
    const metadataPath = path.join(process.cwd(), '.ai/last-update.json');
    const metadataDir = path.dirname(metadataPath);

    if (!fs.existsSync(metadataDir)) {
      fs.mkdirSync(metadataDir, { recursive: true });
    }

    const metadata = {
      version: '1.1.0',
      timestamp: new Date().toISOString(),
      generated_by: 'GitHub Actions',
      source: 'https://github.com/upstash/context7',
      platforms: platforms.map(p => p.name),
      editors: editorTracking,
      protected_files: [
        'README.md',
        'CONTRIBUTING.md',
        'LICENSE',
        'LICENSE.md',
        'TEMPLATE_SUMMARY.md',
        'THIRD_PARTY_LICENSES.md',
        'package.json',
        'tsconfig.json',
        'next.config.js',
        'vitest.config.ts',
        '.gitignore'
      ],
      protected_folders: [
        '.ai',
        '.github',
        'app',
        'components',
        'docs',
        'lib',
        'node_modules',
        '.next',
        '.git'
      ]
    };

    fs.writeFileSync(
      metadataPath,
      JSON.stringify(metadata, null, 2)
    );

    console.log('\n✨ All Context7 configurations updated!');
    console.log(`📝 Metadata saved to .ai/last-update.json\n`);

  } catch (error) {
    console.error('❌ Error:', error.message);
    console.error(error.stack);
    process.exit(1);
  }
}

main();
