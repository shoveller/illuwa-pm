#!/bin/bash

# Story file generation script
# Usage: ./add-storyfile.sh /path/to/component.tsx

set -e

# Check if Storybook is installed
PROJECT_ROOT=$(pwd)
if [ ! -f "$PROJECT_ROOT/package.json" ]; then
    echo "Error: package.json not found. Make sure you're in a project root directory."
    exit 1
fi

# Check for Storybook dependencies
STORYBOOK_INSTALLED=false
if grep -q '"@storybook/' "$PROJECT_ROOT/package.json"; then
    STORYBOOK_INSTALLED=true
elif [ -d "$PROJECT_ROOT/.storybook" ]; then
    STORYBOOK_INSTALLED=true
fi

if [ "$STORYBOOK_INSTALLED" = false ]; then
    echo "Error: Storybook is not installed in this project."
    echo "Please install Storybook first:"
    echo "  CI=true pnpm create storybook@latest --yes --skip-install --package-manager pnpm"
    exit 1
fi

# Input parameter validation
if [ $# -ne 1 ]; then
    echo "Usage: $0 <component-file-absolute-path>"
    echo "Example: $0 /Users/user/project/src/components/Button.tsx"
    exit 1
fi

COMPONENT_FILE_PATH="$1"

# Check if file exists
if [ ! -f "$COMPONENT_FILE_PATH" ]; then
    echo "Error: File does not exist: $COMPONENT_FILE_PATH"
    exit 1
fi

# Check file extension (.tsx or .jsx only)
if [[ ! "$COMPONENT_FILE_PATH" =~ \.(tsx|jsx)$ ]]; then
    echo "Error: Only React component files (.tsx or .jsx) are supported"
    exit 1
fi

# Extract directory and filename from file path
COMPONENT_DIR=$(dirname "$COMPONENT_FILE_PATH")
COMPONENT_FILENAME=$(basename "$COMPONENT_FILE_PATH")

# Create STORY_FILE_NAME by removing extension (implements substringBefore(fileName(),"."))
COMPONENT_NAME="${COMPONENT_FILENAME%.*}"

# Check if it's a Next.js project with App Router
IS_NEXTJS=false
IS_APP_ROUTER=false

if grep -q '"next"' "$PROJECT_ROOT/package.json"; then
    IS_NEXTJS=true
    # Check if it's App Router by looking for src/app directory
    if [[ "$COMPONENT_FILE_PATH" == *"/src/app/"* ]]; then
        IS_APP_ROUTER=true
    fi
fi

# Generate story file name based on project type
if [ "$IS_APP_ROUTER" = true ]; then
    # For App Router: include parent directory namespace
    # Example: src/app/rsc/crypto/page.tsx -> crypto-page.stories.tsx
    PARENT_DIR=$(basename "$COMPONENT_DIR")
    STORY_FILE_NAME="$PARENT_DIR-$COMPONENT_NAME"
    STORYBOOK_IMPORT="@storybook/nextjs"
else
    # For regular components: use component name only
    # Example: hello.tsx -> hello.stories.tsx
    STORY_FILE_NAME="$COMPONENT_NAME"
    if [ "$IS_NEXTJS" = true ]; then
        STORYBOOK_IMPORT="@storybook/nextjs"
    else
        STORYBOOK_IMPORT="@storybook/react-vite"
    fi
fi

# Generate story file path
STORY_FILE_PATH="$COMPONENT_DIR/$STORY_FILE_NAME.stories.tsx"

# Check if story file already exists
if [ -f "$STORY_FILE_PATH" ]; then
    echo "Warning: Story file already exists: $STORY_FILE_PATH"
    read -p "Do you want to overwrite? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        exit 0
    fi
fi

# Generate story file template
cat > "$STORY_FILE_PATH" << EOF
import type { Meta, StoryObj } from '$STORYBOOK_IMPORT'
import $COMPONENT_NAME from './$COMPONENT_NAME'

const meta = {
  component: $COMPONENT_NAME,
} satisfies Meta<typeof $COMPONENT_NAME>

export default meta

type Story = StoryObj<typeof meta>

export const Success: Story = {}
EOF

echo "Success: Story file created: $STORY_FILE_PATH"
echo "Component: $COMPONENT_FILENAME"
echo "Story name: $STORY_FILE_NAME"
echo "Storybook: $STORYBOOK_IMPORT"
if [ "$IS_APP_ROUTER" = true ]; then
    echo "App Router: Namespace '$PARENT_DIR' included"
fi