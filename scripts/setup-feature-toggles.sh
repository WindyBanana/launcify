#!/bin/bash

# Setup for the Feature Toggle Dashboard

setup_feature_toggles() {
    echo -e "${BLUE}Setting up Feature Toggle Dashboard...${NC}"

    # 1. Create Convex schema and functions
    echo -e "${CYAN}  -> Creating Convex files...${NC}"
    cat > convex/featureFlags.ts << 'EOF'
import { mutation, query } from "./_generated/server";
import { v } from "convex/values";

// Get all feature flags
export const list = query({ 
  handler: async (ctx) => {
    return await ctx.db.query("featureFlags").collect();
  },
});

// Toggle a feature flag
export const toggle = mutation({
  args: { id: v.id("featureFlags"), isEnabled: v.boolean() },
  handler: async (ctx, args) => {
    await ctx.db.patch(args.id, { isEnabled: args.isEnabled });
  },
});
EOF

    # 2. Add the featureFlags table to the main schema
    # Check if table already exists
    if ! grep -q "featureFlags:" convex/schema.ts 2>/dev/null; then
        # Add import statement if not present
        if ! grep -q "import { defineTable }" convex/schema.ts 2>/dev/null; then
            sed -i '1i import { defineTable } from "convex/server";' convex/schema.ts
        fi
        
        # Insert the table definition
        sed -i '/^export default defineSchema({/a \
  featureFlags: defineTable({ name: v.string(), isEnabled: v.boolean() }).index("by_name", ["name"]),
' convex/schema.ts
        echo -e "${GREEN}✓ Added featureFlags table to schema${NC}"
    else
        echo -e "${BLUE}ℹ️  featureFlags table already in schema${NC}"
    fi


    # 3. Create the React hook
    echo -e "${CYAN}  -> Creating React hook...${NC}"
    mkdir -p hooks
    cat > hooks/use-feature-flag.ts << 'EOF'
import { useQuery } from "convex/react";
import { api } from "@/convex/_generated/api";

export const useFeatureFlag = (flagName: string): boolean => {
  const flags = useQuery(api.featureFlags.list);
  const flag = flags?.find(f => f.name === flagName);
  return flag?.isEnabled ?? false;
};
EOF

    # 4. Create the dashboard UI page
    echo -e "${CYAN}  -> Creating dashboard UI page...${NC}"
    mkdir -p app/admin/feature-toggles
    cat > app/admin/feature-toggles/page.tsx << 'EOF'
"use client";

import { useQuery, useMutation } from "convex/react";
import { api } from "@/convex/_generated/api";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Switch } from "@/components/ui/switch";
import { Label } from "@/components/ui/label";

export default function FeatureTogglesPage() {
  const flags = useQuery(api.featureFlags.list);
  const toggleFlag = useMutation(api.featureFlags.toggle);

  const handleToggle = (id: any, isEnabled: boolean) => {
    toggleFlag({ id, isEnabled });
  };

  return (
    <Card>
      <CardHeader>
        <CardTitle>Feature Toggles</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        {flags?.map((flag) => (
          <div key={flag._id} className="flex items-center justify-between p-2 border rounded-lg">
            <Label htmlFor={flag.name} className="text-lg">{flag.name}</Label>
            <Switch
              id={flag.name}
              checked={flag.isEnabled}
              onCheckedChange={(isChecked) => handleToggle(flag._id, isChecked)}
            />
          </div>
        ))}
        {flags?.length === 0 && <p>No feature flags found.</p>}
      </CardContent>
    </Card>
  );
}
EOF

    # 5. Seed initial data
    echo -e "${CYAN}  -> Seeding initial data...${NC}"
    # We'll add an initializer to seed some data if the table is empty.
    if [ ! -f convex/_initializers.ts ]; then
        touch convex/_initializers.ts
    fi
    cat >> convex/_initializers.ts << 'EOF'

// Seed feature flags
import { internal } from "./_generated/api";

export const seedFeatureFlags = internal.mutation({
    handler: async (ctx) => {
        const flags = await ctx.db.query("featureFlags").collect();
        if (flags.length > 0) return;

        console.log("Seeding feature flags...");
        await ctx.db.insert("featureFlags", { name: "new-checkout-flow", isEnabled: false });
        await ctx.db.insert("featureFlags", { name: "beta-dashboard", isEnabled: true });
    }
});
EOF

    echo -e "${GREEN}✓ Feature Toggle Dashboard setup complete.${NC}"
    echo ""
    echo -e "${CYAN}Next steps:${NC}"
    echo -e "  1. Deploy Convex schema: ${GREEN}npx convex dev${NC}"
    echo -e "  2. Seed initial data: ${GREEN}npx convex run _initializers:seedFeatureFlags${NC}"
    echo -e "  3. Access dashboard: ${CYAN}http://localhost:3000/admin/feature-toggles${NC}"
    echo ""
}
