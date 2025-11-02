#!/bin/bash

# Setup shadcn/ui with dark mode support

setup_shadcn() {
    local package_manager=$1

    echo -e "${BLUE}Setting up shadcn/ui...${NC}"

    # Install dependencies
    echo -e "${BLUE}Installing required dependencies...${NC}"
    if [ "$package_manager" = "pnpm" ]; then
        pnpm add class-variance-authority clsx tailwind-merge lucide-react
        pnpm add -D @types/node
    elif [ "$package_manager" = "yarn" ]; then
        yarn add class-variance-authority clsx tailwind-merge lucide-react
        yarn add -D @types/node
    else
        npm install class-variance-authority clsx tailwind-merge lucide-react
        npm install -D @types/node
    fi

    # Create components.json
    cat > components.json << 'EOF'
{
  "$schema": "https://ui.shadcn.com/schema.json",
  "style": "default",
  "rsc": true,
  "tsx": true,
  "tailwind": {
    "config": "tailwind.config.ts",
    "css": "app/globals.css",
    "baseColor": "slate",
    "cssVariables": true,
    "prefix": ""
  },
  "aliases": {
    "components": "@/components",
    "utils": "@/lib/utils",
    "ui": "@/components/ui",
    "lib": "@/lib",
    "hooks": "@/hooks"
  }
}
EOF

    echo -e "${GREEN}✓ components.json created${NC}"

    # Create lib/utils.ts with cn utility
    mkdir -p lib
    cat > lib/utils.ts << 'EOF'
import { type ClassValue, clsx } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}
EOF

    echo -e "${GREEN}✓ lib/utils.ts created${NC}"

    # Update tailwind.config.ts with shadcn theme
    cat > tailwind.config.ts << 'EOF'
import type { Config } from "tailwindcss";

const config: Config = {
  darkMode: ["class"],
  content: [
    "./pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        border: "hsl(var(--border))",
        input: "hsl(var(--input))",
        ring: "hsl(var(--ring))",
        background: "hsl(var(--background))",
        foreground: "hsl(var(--foreground))",
        primary: {
          DEFAULT: "hsl(var(--primary))",
          foreground: "hsl(var(--primary-foreground))",
        },
        secondary: {
          DEFAULT: "hsl(var(--secondary))",
          foreground: "hsl(var(--secondary-foreground))",
        },
        destructive: {
          DEFAULT: "hsl(var(--destructive))",
          foreground: "hsl(var(--destructive-foreground))",
        },
        muted: {
          DEFAULT: "hsl(var(--muted))",
          foreground: "hsl(var(--muted-foreground))",
        },
        accent: {
          DEFAULT: "hsl(var(--accent))",
          foreground: "hsl(var(--accent-foreground))",
        },
        popover: {
          DEFAULT: "hsl(var(--popover))",
          foreground: "hsl(var(--popover-foreground))",
        },
        card: {
          DEFAULT: "hsl(var(--card))",
          foreground: "hsl(var(--card-foreground))",
        },
      },
      borderRadius: {
        lg: "var(--radius)",
        md: "calc(var(--radius) - 2px)",
        sm: "calc(var(--radius) - 4px)",
      },
    },
  },
  plugins: [require("tailwindcss-animate")],
};

export default config;
EOF

    echo -e "${GREEN}✓ tailwind.config.ts updated${NC}"

    # Install tailwindcss-animate
    if [ "$package_manager" = "pnpm" ]; then
        pnpm add -D tailwindcss-animate
    elif [ "$package_manager" = "yarn" ]; then
        yarn add -D tailwindcss-animate
    else
        npm install -D tailwindcss-animate
    fi

    # Update globals.css with theme variables
    if [ -f "app/globals.css" ]; then
        cat > app/globals.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
    --card: 0 0% 100%;
    --card-foreground: 222.2 84% 4.9%;
    --popover: 0 0% 100%;
    --popover-foreground: 222.2 84% 4.9%;
    --primary: 222.2 47.4% 11.2%;
    --primary-foreground: 210 40% 98%;
    --secondary: 210 40% 96.1%;
    --secondary-foreground: 222.2 47.4% 11.2%;
    --muted: 210 40% 96.1%;
    --muted-foreground: 215.4 16.3% 46.9%;
    --accent: 210 40% 96.1%;
    --accent-foreground: 222.2 47.4% 11.2%;
    --destructive: 0 84.2% 60.2%;
    --destructive-foreground: 210 40% 98%;
    --border: 214.3 31.8% 91.4%;
    --input: 214.3 31.8% 91.4%;
    --ring: 222.2 84% 4.9%;
    --radius: 0.5rem;
  }

  .dark {
    --background: 222.2 84% 4.9%;
    --foreground: 210 40% 98%;
    --card: 222.2 84% 4.9%;
    --card-foreground: 210 40% 98%;
    --popover: 222.2 84% 4.9%;
    --popover-foreground: 210 40% 98%;
    --primary: 210 40% 98%;
    --primary-foreground: 222.2 47.4% 11.2%;
    --secondary: 217.2 32.6% 17.5%;
    --secondary-foreground: 210 40% 98%;
    --muted: 217.2 32.6% 17.5%;
    --muted-foreground: 215 20.2% 65.1%;
    --accent: 217.2 32.6% 17.5%;
    --accent-foreground: 210 40% 98%;
    --destructive: 0 62.8% 30.6%;
    --destructive-foreground: 210 40% 98%;
    --border: 217.2 32.6% 17.5%;
    --input: 217.2 32.6% 17.5%;
    --ring: 212.7 26.8% 83.9%;
  }
}

@layer base {
  * {
    @apply border-border;
  }
  body {
    @apply bg-background text-foreground;
  }
}
EOF
        echo -e "${GREEN}✓ app/globals.css updated with theme variables${NC}"
    fi

    # Install common shadcn components
    echo -e "${BLUE}Installing common shadcn/ui components...${NC}"

    # Use npx to install components
    npx shadcn@latest add button -y --overwrite 2>/dev/null || echo -e "${YELLOW}⚠️  Button component installation skipped${NC}"
    npx shadcn@latest add card -y --overwrite 2>/dev/null || echo -e "${YELLOW}⚠️  Card component installation skipped${NC}"
    npx shadcn@latest add dialog -y --overwrite 2>/dev/null || echo -e "${YELLOW}⚠️  Dialog component installation skipped${NC}"
    npx shadcn@latest add dropdown-menu -y --overwrite 2>/dev/null || echo -e "${YELLOW}⚠️  Dropdown component installation skipped${NC}"
    npx shadcn@latest add input -y --overwrite 2>/dev/null || echo -e "${YELLOW}⚠️  Input component installation skipped${NC}"
    npx shadcn@latest add label -y --overwrite 2>/dev/null || echo -e "${YELLOW}⚠️  Label component installation skipped${NC}"
    npx shadcn@latest add select -y --overwrite 2>/dev/null || echo -e "${YELLOW}⚠️  Select component installation skipped${NC}"
    npx shadcn@latest add toast -y --overwrite 2>/dev/null || echo -e "${YELLOW}⚠️  Toast component installation skipped${NC}"

    # Create dark mode toggle component
    mkdir -p components
    cat > components/theme-toggle.tsx << 'EOF'
"use client"

import * as React from "react"
import { Moon, Sun } from "lucide-react"
import { useTheme } from "next-themes"

export function ThemeToggle() {
  const { theme, setTheme } = useTheme()

  return (
    <button
      onClick={() => setTheme(theme === "light" ? "dark" : "light")}
      className="inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 hover:bg-accent hover:text-accent-foreground h-10 w-10"
    >
      <Sun className="h-[1.2rem] w-[1.2rem] rotate-0 scale-100 transition-all dark:-rotate-90 dark:scale-0" />
      <Moon className="absolute h-[1.2rem] w-[1.2rem] rotate-90 scale-0 transition-all dark:rotate-0 dark:scale-100" />
      <span className="sr-only">Toggle theme</span>
    </button>
  )
}
EOF

    echo -e "${GREEN}✓ Theme toggle component created${NC}"

    # Install next-themes
    if [ "$package_manager" = "pnpm" ]; then
        pnpm add next-themes
    elif [ "$package_manager" = "yarn" ]; then
        yarn add next-themes
    else
        npm install next-themes
    fi

    # Create theme provider
    cat > components/theme-provider.tsx << 'EOF'
"use client"

import * as React from "react"
import { ThemeProvider as NextThemesProvider } from "next-themes"
import { type ThemeProviderProps } from "next-themes/dist/types"

export function ThemeProvider({ children, ...props }: ThemeProviderProps) {
  return <NextThemesProvider {...props}>{children}</NextThemesProvider>
}
EOF

    echo -e "${GREEN}✓ Theme provider created${NC}"

    echo -e "\n${CYAN}shadcn/ui Setup Complete:${NC}"
    echo -e "  ${GREEN}✓${NC} Components installed"
    echo -e "  ${GREEN}✓${NC} Dark mode configured"
    echo -e "  ${GREEN}✓${NC} Theme toggle component created"
    echo -e "  ${GREEN}✓${NC} Tailwind theme configured"
    echo -e "\n  ${YELLOW}Next steps:${NC}"
    echo -e "    1. Wrap your app with ThemeProvider in layout.tsx"
    echo -e "    2. Add ThemeToggle component to your navigation"
    echo -e "    3. Install more components: ${CYAN}npx shadcn@latest add <component>${NC}"
    echo -e "\n  ${YELLOW}More components:${NC} https://ui.shadcn.com/docs/components"
}
EOF
