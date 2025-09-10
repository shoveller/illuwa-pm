# Add Storybook Story Command

## Description
Automatically generates a Storybook story file for React components using the add-storyfile.sh script. Supports both Next.js App Router and regular React components with appropriate naming conventions.

## Trigger Phrases
- "add story for [component]"
- "create story file for [component]" 
- "generate storybook story for [component]"
- "make story for [component]"
- "add storybook for [component]"

## Implementation

```typescript
// When user mentions creating/adding a story for a component
async function handleAddStoryRequest(componentPath: string) {
  // Validate component path
  if (!componentPath.includes('.tsx') && !componentPath.includes('.jsx')) {
    return "Please specify a React component file (.tsx or .jsx)"
  }
  
  // Convert relative to absolute path if needed
  const absolutePath = componentPath.startsWith('/') 
    ? componentPath 
    : path.resolve(process.cwd(), componentPath)
  
  // Execute the add-storyfile.sh script
  const scriptPath = './.claude/scripts/illuwa/add-storyfile.sh'
  
  try {
    const result = await execBash(`${scriptPath} "${absolutePath}"`)
    return `Story file created successfully!\n${result.stdout}`
  } catch (error) {
    return `Error creating story file: ${error.stderr || error.message}`
  }
}
```

## Usage Examples

**User:** "Can you add a story for src/components/Button.tsx?"
**Claude:** [Executes script and reports success]

**User:** "Create a storybook story for the page component at src/app/rsc/crypto/page.tsx"
**Claude:** [Generates crypto-page.stories.tsx with App Router naming]

**User:** "I need stories for my LoginForm component"
**Claude:** "Please specify the full path to your LoginForm component file (.tsx or .jsx)"

## Features
-  Automatic project type detection (Next.js vs Vite)
-  App Router namespace support (crypto-page.stories.tsx)
-  Storybook installation validation
-  File existence checking
-  Overwrite confirmation
-  Appropriate import statements (@storybook/nextjs vs @storybook/react-vite)

## Script Location
`.claude/scripts/illuwa/add-storyfile.sh`