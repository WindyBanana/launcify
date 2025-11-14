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

// Platform configurations
const PLATFORM_CONFIGS = {
  cursor: {
    path: '.cursor/mcp_settings.json',
    format: 'json',
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
    format: 'json',
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
    format: 'json',
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
    format: 'toml',
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

async function main() {
  try {
    console.log('\n🤖 Context7 Configuration Generator\n');

    const platforms = await fetchSupportedPlatforms();

    console.log(`\n📦 Generating configs for ${platforms.length} platforms\n`);

    for (const platform of platforms) {
      generateConfigFile(platform);
    }

    // Update metadata file
    const metadataPath = path.join(process.cwd(), '.ai/last-update.json');
    const metadataDir = path.dirname(metadataPath);

    if (!fs.existsSync(metadataDir)) {
      fs.mkdirSync(metadataDir, { recursive: true });
    }

    fs.writeFileSync(
      metadataPath,
      JSON.stringify({
        timestamp: new Date().toISOString(),
        platforms: platforms.map(p => p.name),
        generatedBy: 'GitHub Actions',
        source: 'https://github.com/upstash/context7'
      }, null, 2)
    );

    console.log('\n✨ All Context7 configurations updated!\n');

  } catch (error) {
    console.error('❌ Error:', error.message);
    console.error(error.stack);
    process.exit(1);
  }
}

main();
