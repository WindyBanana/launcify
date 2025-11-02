#!/bin/bash

# Test script for Launchify
# Runs the generator with predefined inputs to verify it works

set -e

echo "╔═══════════════════════════════════════════════════════╗"
echo "║                                                       ║"
echo "║            LAUNCHIFY TEST SCRIPT                      ║"
echo "║                                                       ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo ""

# Configuration
TEST_PROJECT_NAME="launchify-test-$(date +%s)"
PACKAGE_MANAGER="npm"

echo "Test Configuration:"
echo "  Project: $TEST_PROJECT_NAME"
echo "  Package Manager: $PACKAGE_MANAGER"
echo ""

# Warning
echo "⚠️  WARNING: This test will:"
echo "  - Create a test project: $TEST_PROJECT_NAME"
echo "  - Install dependencies"
echo "  - Run build and lint"
echo "  - Attempt to login to Vercel/Convex (if selected)"
echo ""
read -p "Continue? [y/N]: " CONFIRM

if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
    echo "Test cancelled."
    exit 0
fi

echo ""
echo "Starting test..."
echo ""

# Create test input file
cat > /tmp/launchify-test-input.txt << EOF
$TEST_PROJECT_NAME
1
1
y
n
n
n
n
y
n
n
y
EOF

echo "✓ Test inputs prepared"
echo ""

# Run the generator with test inputs
./create-project.sh < /tmp/launchify-test-input.txt

# Check if project was created
if [ -d "$TEST_PROJECT_NAME" ]; then
    echo ""
    echo "╔═══════════════════════════════════════════════════════╗"
    echo "║                                                       ║"
    echo "║          ✅ TEST COMPLETED SUCCESSFULLY              ║"
    echo "║                                                       ║"
    echo "╚═══════════════════════════════════════════════════════╝"
    echo ""
    echo "Test project created at: ./$TEST_PROJECT_NAME"
    echo ""
    echo "To clean up:"
    echo "  rm -rf $TEST_PROJECT_NAME"
    echo ""
else
    echo ""
    echo "❌ TEST FAILED: Project directory not created"
    exit 1
fi

# Cleanup test input file
rm /tmp/launchify-test-input.txt
