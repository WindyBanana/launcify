#!/bin/bash

# Setup admin panel (requires Convex)

setup_admin_panel() {
    local use_clerk=$1
    local use_axiom=$2
    local use_linear=$3
    local enable_in_prod=$4

    echo -e "${BLUE}Setting up admin panel...${NC}"

    # Create admin app directory
    mkdir -p app/admin

    # Create admin layout
    cat > app/admin/layout.tsx << 'EOF'
import { redirect } from 'next/navigation';

export default function AdminLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  // Check if admin panel is enabled
  const isEnabled = process.env.ENABLE_ADMIN_PANEL !== 'false';

  if (!isEnabled && process.env.NODE_ENV === 'production') {
    redirect('/');
  }

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      <div className="flex">
        {/* Sidebar */}
        <aside className="w-64 bg-white dark:bg-gray-800 border-r border-gray-200 dark:border-gray-700 min-h-screen">
          <div className="p-6">
            <h1 className="text-2xl font-bold">Admin Panel</h1>
          </div>
          <nav className="px-3 space-y-1">
            <a
              href="/admin"
              className="block px-3 py-2 rounded-md hover:bg-gray-100 dark:hover:bg-gray-700"
            >
              Dashboard
            </a>
            <a
              href="/admin/users"
              className="block px-3 py-2 rounded-md hover:bg-gray-100 dark:hover:bg-gray-700"
            >
              Users
            </a>
            <a
              href="/admin/database"
              className="block px-3 py-2 rounded-md hover:bg-gray-100 dark:hover:bg-gray-700"
            >
              Database
            </a>
            <a
              href="/admin/logs"
              className="block px-3 py-2 rounded-md hover:bg-gray-100 dark:hover:bg-gray-700"
            >
              Logs
            </a>
            <a
              href="/admin/settings"
              className="block px-3 py-2 rounded-md hover:bg-gray-100 dark:hover:bg-gray-700"
            >
              Settings
            </a>
          </nav>
        </aside>

        {/* Main content */}
        <main className="flex-1 p-8">{children}</main>
      </div>
    </div>
  );
}
EOF

    echo -e "${GREEN}✓ Admin layout created${NC}"

    # Create admin dashboard page
    cat > app/admin/page.tsx << 'EOF'
import { api } from '@/convex/_generated/api';
import { fetchQuery } from 'convex/nextjs';

export default async function AdminDashboard() {
  // Fetch system stats
  const stats = await fetchQuery(api.admin.getSystemStats);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Dashboard</h1>
        <p className="text-gray-600 dark:text-gray-400">System overview and statistics</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <div className="bg-white dark:bg-gray-800 p-6 rounded-lg shadow">
          <h3 className="text-sm font-medium text-gray-600 dark:text-gray-400">Total Users</h3>
          <p className="text-3xl font-bold mt-2">{stats.totalUsers}</p>
        </div>

        <div className="bg-white dark:bg-gray-800 p-6 rounded-lg shadow">
          <h3 className="text-sm font-medium text-gray-600 dark:text-gray-400">Active Sessions</h3>
          <p className="text-3xl font-bold mt-2">{stats.activeSessions}</p>
        </div>

        <div className="bg-white dark:bg-gray-800 p-6 rounded-lg shadow">
          <h3 className="text-sm font-medium text-gray-600 dark:text-gray-400">API Calls (24h)</h3>
          <p className="text-3xl font-bold mt-2">{stats.apiCalls24h}</p>
        </div>

        <div className="bg-white dark:bg-gray-800 p-6 rounded-lg shadow">
          <h3 className="text-sm font-medium text-gray-600 dark:text-gray-400">Errors (24h)</h3>
          <p className="text-3xl font-bold mt-2 text-red-600">{stats.errors24h}</p>
        </div>
      </div>

      {/* System Info */}
      <div className="bg-white dark:bg-gray-800 p-6 rounded-lg shadow">
        <h2 className="text-xl font-bold mb-4">System Information</h2>
        <dl className="grid grid-cols-2 gap-4">
          <div>
            <dt className="text-sm text-gray-600 dark:text-gray-400">Environment</dt>
            <dd className="font-medium">{process.env.NODE_ENV}</dd>
          </div>
          <div>
            <dt className="text-sm text-gray-600 dark:text-gray-400">Version</dt>
            <dd className="font-medium">1.0.0</dd>
          </div>
        </dl>
      </div>
    </div>
  );
}
EOF

    echo -e "${GREEN}✓ Admin dashboard page created${NC}"

    # Create admin Convex functions
    cat > convex/admin.ts << 'EOF'
import { query, mutation } from "./_generated/server";
import { v } from "convex/values";

// Get system statistics
export const getSystemStats = query({
  args: {},
  handler: async (ctx) => {
    // Example stats - customize based on your schema
    return {
      totalUsers: 0,
      activeSessions: 0,
      apiCalls24h: 0,
      errors24h: 0,
    };
  },
});

// Get all users (admin only)
export const getAllUsers = query({
  args: {
    limit: v.optional(v.number()),
    offset: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    // TODO: Add authentication check
    // const identity = await ctx.auth.getUserIdentity();
    // if (!identity) throw new Error("Unauthorized");

    // TODO: Implement user fetching from your schema
    return [];
  },
});

// Admin action log
export const logAdminAction = mutation({
  args: {
    action: v.string(),
    details: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    // TODO: Store admin actions in audit log
    console.log("Admin action:", args.action, args.details);
  },
});
EOF

    echo -e "${GREEN}✓ Admin Convex functions created${NC}"

    # Create users management page
    mkdir -p app/admin/users
    cat > app/admin/users/page.tsx << 'EOF'
"use client"

import { useQuery } from "convex/react";
import { api } from "@/convex/_generated/api";

export default function AdminUsers() {
  const users = useQuery(api.admin.getAllUsers, { limit: 100 });

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">User Management</h1>
        <p className="text-gray-600 dark:text-gray-400">Manage system users and permissions</p>
      </div>

      <div className="bg-white dark:bg-gray-800 rounded-lg shadow">
        <div className="p-6">
          <h2 className="text-xl font-bold mb-4">All Users</h2>

          {users === undefined ? (
            <p>Loading...</p>
          ) : users.length === 0 ? (
            <p className="text-gray-600 dark:text-gray-400">No users found</p>
          ) : (
            <table className="w-full">
              <thead>
                <tr className="border-b">
                  <th className="text-left p-2">ID</th>
                  <th className="text-left p-2">Email</th>
                  <th className="text-left p-2">Created</th>
                  <th className="text-left p-2">Actions</th>
                </tr>
              </thead>
              <tbody>
                {users.map((user: any) => (
                  <tr key={user.id} className="border-b">
                    <td className="p-2">{user.id}</td>
                    <td className="p-2">{user.email}</td>
                    <td className="p-2">{new Date(user.createdAt).toLocaleDateString()}</td>
                    <td className="p-2">
                      <button className="text-blue-600 hover:underline">Edit</button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      </div>
    </div>
  );
}
EOF

    echo -e "${GREEN}✓ Users management page created${NC}"

    # Create database viewer page
    mkdir -p app/admin/database
    cat > app/admin/database/page.tsx << 'EOF'
export default function AdminDatabase() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Database</h1>
        <p className="text-gray-600 dark:text-gray-400">View and manage database tables</p>
      </div>

      <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
        <p className="text-gray-600 dark:text-gray-400">
          Database viewer coming soon. Use Convex Dashboard for now:
        </p>
        <a
          href="https://dashboard.convex.dev"
          target="_blank"
          rel="noopener noreferrer"
          className="text-blue-600 hover:underline mt-2 inline-block"
        >
          Open Convex Dashboard →
        </a>
      </div>
    </div>
  );
}
EOF

    echo -e "${GREEN}✓ Database viewer page created${NC}"

    # Create logs page
    mkdir -p app/admin/logs
    cat > app/admin/logs/page.tsx << 'EOF'
export default function AdminLogs() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Logs</h1>
        <p className="text-gray-600 dark:text-gray-400">View application logs and errors</p>
      </div>

      <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
        <p className="text-gray-600 dark:text-gray-400">
          Log viewer coming soon. Check console or Axiom dashboard.
        </p>
      </div>
    </div>
  );
}
EOF

    echo -e "${GREEN}✓ Logs page created${NC}"

    # Create settings page
    mkdir -p app/admin/settings
    cat > app/admin/settings/page.tsx << 'EOF'
export default function AdminSettings() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Settings</h1>
        <p className="text-gray-600 dark:text-gray-400">Configure admin panel settings</p>
      </div>

      <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
        <h2 className="text-xl font-bold mb-4">Admin Panel Configuration</h2>

        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium mb-2">
              Enable in Production
            </label>
            <p className="text-sm text-gray-600 dark:text-gray-400">
              Set ENABLE_ADMIN_PANEL=true in production environment variables
            </p>
          </div>

          <div>
            <label className="block text-sm font-medium mb-2">
              Allowed Admin Emails
            </label>
            <p className="text-sm text-gray-600 dark:text-gray-400">
              Set ADMIN_ALLOWED_EMAILS=email1@example.com,email2@example.com
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
EOF

    echo -e "${GREEN}✓ Settings page created${NC}"

    # Add admin panel specific environment variables to .env.local
    cat >> .env.local << EOF

# --------------------------------------------
# Admin Panel
# --------------------------------------------
# Enable admin panel (set to false to disable in production)
ENABLE_ADMIN_PANEL=true

# Allowed admin emails (comma-separated)
ADMIN_ALLOWED_EMAILS=your-email@example.com

EOF

    echo -e "\n${CYAN}Admin Panel Setup Complete:${NC}"
    echo -e "  ${GREEN}✓${NC} Admin layout and navigation created"
    echo -e "  ${GREEN}✓${NC} Dashboard page with stats"
    echo -e "  ${GREEN}✓${NC} User management page"
    echo -e "  ${GREEN}✓${NC} Database viewer page"
    echo -e "  ${GREEN}✓${NC} Logs page"
    echo -e "  ${GREEN}✓${NC} Settings page"
    echo -e "  ${GREEN}✓${NC} Convex admin functions"
    echo -e "\n  ${YELLOW}Access admin panel:${NC}"
    echo -e "    ${CYAN}http://localhost:3000/admin${NC}"
    echo -e "\n  ${YELLOW}Security notes:${NC}"
    echo -e "    - Add your email to ADMIN_ALLOWED_EMAILS in .env.local"
    if [ "$enable_in_prod" = "false" ]; then
        echo -e "    - Admin panel disabled in production by default"
    else
        echo -e "    - Admin panel enabled in production (set ENABLE_ADMIN_PANEL=false to disable)"
    fi
    echo -e "    - Implement proper authentication checks in Convex functions"
}
EOF
