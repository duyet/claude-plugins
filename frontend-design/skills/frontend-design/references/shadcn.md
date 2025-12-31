# shadcn/ui Reference

> shadcn/ui is NOT a component library—it's how you build your component library. You get actual component code that you own and can modify.

## Core Principles

1. **Open Code**: Full transparency, easy customization, AI-readable
2. **Composition**: Common, composable interface across all components
3. **Distribution**: Flat-file schema + CLI for easy installation
4. **Beautiful Defaults**: Great design out-of-the-box, easily customizable
5. **AI-Ready**: Open code structure for LLMs to understand and improve

## Installation & Setup

```bash
# Using npx (npm)
npx shadcn@latest init

# Using bunx (bun)
bunx shadcn@latest init

# Using pnpm
pnpm dlx shadcn@latest init

# Using yarn
yarn dlx shadcn@latest init
```

Or with your package manager's equivalent:

```bash
# Add components
<npx/bunx/pnpm dlx/yarn dlx> shadcn@latest add button card dialog

# View component before installing
<npx/bunx/pnpm dlx/yarn dlx> shadcn@latest view button card

# Search registry
<npx/bunx/pnpm dlx/yarn dlx> shadcn@latest search @shadcn -q "button"
```

## components.json Configuration

The `components.json` file controls how shadcn/ui integrates with your project:

```json
{
  "$schema": "https://ui.shadcn.com/schema.json",
  "style": "new-york",           // Design style (cannot change after init)
  "tailwind": {
    "config": "tailwind.config.js",
    "css": "app/globals.css",
    "baseColor": "neutral",      // neutral, gray, zinc, stone, slate
    "cssVariables": true,        // Use CSS variables for theming
    "prefix": ""                 // Tailwind prefix if needed
  },
  "rsc": true,                   // React Server Components support
  "tsx": true,                   // TypeScript vs JavaScript
  "aliases": {
    "utils": "@/lib/utils",
    "components": "@/components",
    "ui": "@/components/ui",     // Where UI components are installed
    "lib": "@/lib",
    "hooks": "@/hooks"
  },
  "registries": {                // Multiple registry support
    "@shadcn": "https://ui.shadcn.com/r/{name}.json",
    "@v0": "https://v0.dev/chat/b/{name}"
  }
}
```

### Configuration Fields

| Field | Description | Cannot Change After Init |
|-------|-------------|-------------------------|
| `style` | Design style variant | Yes |
| `tailwind.baseColor` | Base color palette | Yes |
| `tailwind.cssVariables` | Use CSS variables vs utilities | Yes |
| `tailwind.prefix` | Tailwind class prefix | No |
| `rsc` | React Server Components | No |
| `tsx` | TypeScript vs JavaScript | No |

## Theming System

### Color Convention

Simple `background` and `foreground` pattern:

```tsx
// Background and foreground colors
<div className="bg-background text-foreground">Hello</div>
<div className="bg-primary text-primary-foreground">Primary</div>
<div className="bg-muted text-muted-foreground">Muted</div>
```

The `background` suffix is omitted when the variable is used for the background color of the component.

### CSS Variables (Recommended)

```css
:root {
  --radius: 0.625rem;
  --background: oklch(1 0 0);
  --foreground: oklch(0.145 0 0);
  --card: oklch(1 0 0);
  --card-foreground: oklch(0.145 0 0);
  --popover: oklch(1 0 0);
  --popover-foreground: oklch(0.145 0 0);
  --primary: oklch(0.205 0 0);
  --primary-foreground: oklch(0.985 0 0);
  --secondary: oklch(0.97 0 0);
  --secondary-foreground: oklch(0.205 0 0);
  --muted: oklch(0.97 0 0);
  --muted-foreground: oklch(0.556 0 0);
  --accent: oklch(0.97 0 0);
  --accent-foreground: oklch(0.205 0 0);
  --destructive: oklch(0.577 0.245 27.325);
  --border: oklch(0.922 0 0);
  --input: oklch(0.922 0 0);
  --ring: oklch(0.708 0 0);
  --chart-1: oklch(0.646 0.222 41.116);
  --chart-2: oklch(0.6 0.118 184.704);
  --chart-3: oklch(0.398 0.07 227.392);
  --chart-4: oklch(0.828 0.189 84.429);
  --chart-5: oklch(0.769 0.188 70.08);
  --sidebar: oklch(0.985 0 0);
  --sidebar-foreground: oklch(0.145 0 0);
  --sidebar-primary: oklch(0.205 0 0);
  --sidebar-primary-foreground: oklch(0.985 0 0);
  --sidebar-accent: oklch(0.97 0 0);
  --sidebar-accent-foreground: oklch(0.205 0 0);
  --sidebar-border: oklch(0.922 0 0);
  --sidebar-ring: oklch(0.708 0 0);
}

.dark {
  --background: oklch(0.145 0 0);
  --foreground: oklch(0.985 0 0);
  --card: oklch(0.205 0 0);
  --card-foreground: oklch(0.985 0 0);
  --popover: oklch(0.269 0 0);
  --popover-foreground: oklch(0.985 0 0);
  --primary: oklch(0.922 0 0);
  --primary-foreground: oklch(0.205 0 0);
  --secondary: oklch(0.269 0 0);
  --secondary-foreground: oklch(0.985 0 0);
  --muted: oklch(0.269 0 0);
  --muted-foreground: oklch(0.708 0 0);
  --accent: oklch(0.371 0 0);
  --accent-foreground: oklch(0.985 0 0);
  --destructive: oklch(0.704 0.191 22.216);
  --border: oklch(1 0 0 / 10%);
  --input: oklch(1 0 0 / 15%);
  --ring: oklch(0.556 0 0);
  --chart-1: oklch(0.488 0.243 264.376);
  --chart-2: oklch(0.696 0.17 162.48);
  --chart-3: oklch(0.769 0.188 70.08);
  --chart-4: oklch(0.627 0.265 303.9);
  --chart-5: oklch(0.645 0.246 16.439);
  --sidebar: oklch(0.205 0 0);
  --sidebar-foreground: oklch(0.985 0 0);
  --sidebar-primary: oklch(0.488 0.243 264.376);
  --sidebar-primary-foreground: oklch(0.985 0 0);
  --sidebar-accent: oklch(0.269 0 0);
  --sidebar-accent-foreground: oklch(0.985 0 0);
  --sidebar-border: oklch(1 0 0 / 10%);
  --sidebar-ring: oklch(0.439 0 0);
}
```

### Adding Custom Colors

```css
:root {
  --warning: oklch(0.84 0.16 84);
  --warning-foreground: oklch(0.28 0.07 46);
}

.dark {
  --warning: oklch(0.41 0.11 46);
  --warning-foreground: oklch(0.99 0.02 95);
}

@theme inline {
  --color-warning: var(--warning);
  --color-warning-foreground: var(--warning-foreground);
}

/* Usage */
<div className="bg-warning text-warning-foreground" />
```

### Base Color Options

Available base colors for `tailwind.baseColor`:

| Color | Description |
|-------|-------------|
| `neutral` | Pure grayscale, no hue bias |
| `gray` | Slightly cool gray with blue tint |
| `zinc` | Cool gray with slight purple/blue tint |
| `stone` | Warm gray with yellow/beige tint |
| `slate` | Cool gray with strong blue tint |

### Utility Classes vs CSS Variables

**CSS Variables (Recommended)**:
```tsx
<div className="bg-background text-foreground" />
```

**Utility Classes**:
```tsx
<div className="bg-zinc-950 dark:bg-white dark:text-zinc-950" />
```

Set `tailwind.cssVariables: false` in `components.json` to use utility classes.

## Dark Mode Setup (Next.js)

### 1. Install next-themes

```bash
# npm
npm install next-themes

# bun
bun add next-themes

# pnpm
pnpm add next-themes

# yarn
yarn add next-themes
```

### 2. Create Theme Provider

```tsx
// components/theme-provider.tsx
"use client"

import * as React from "react"
import { ThemeProvider as NextThemesProvider } from "next-themes"

export function ThemeProvider({
  children,
  ...props
}: React.ComponentProps<typeof NextThemesProvider>) {
  return <NextThemesProvider {...props}>{children}</NextThemesProvider>
}
```

### 3. Wrap Root Layout

```tsx
// app/layout.tsx
import { ThemeProvider } from "@/components/theme-provider"

export default function RootLayout({ children }: RootLayoutProps) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body>
        <ThemeProvider
          attribute="class"
          defaultTheme="system"
          enableSystem
          disableTransitionOnChange
        >
          {children}
        </ThemeProvider>
      </body>
    </html>
  )
}
```

The `suppressHydrationWarning` prop is required on the `html` tag to prevent hydration mismatch warnings when rendering theme classes.

## Component Categories

### Form & Input

| Component | Description | Dependencies |
|-----------|-------------|--------------|
| **Form** | Building forms with React Hook Form + Zod validation | react-hook-form, zod |
| **Field** | Field component with labels and error messages | - |
| **Button** | Button with multiple variants | - |
| **Button Group** | Group multiple buttons together | - |
| **Input** | Text input component | - |
| **Input Group** | Input with prefix/suffix addons | - |
| **Input OTP** | One-time password input | input-otp |
| **Textarea** | Multi-line text input | - |
| **Checkbox** | Checkbox input | @radix-ui/react-checkbox |
| **Radio Group** | Radio button group | @radix-ui/react-radio-group |
| **Select** | Select dropdown | @radix-ui/react-select |
| **Switch** | Toggle switch | @radix-ui/react-switch |
| **Slider** | Slider input | @radix-ui/react-slider |
| **Calendar** | Calendar for date selection | react-day-picker |
| **Date Picker** | Date picker combining input + calendar | calendar |
| **Combobox** | Searchable select with autocomplete | cmdk |
| **Label** | Form label | - |

### Layout & Navigation

| Component | Description | Dependencies |
|-----------|-------------|--------------|
| **Accordion** | Collapsible accordion | @radix-ui/react-accordion |
| **Breadcrumb** | Breadcrumb navigation | - |
| **Navigation Menu** | Accessible nav with dropdowns | @radix-ui/react-navigation-menu |
| **Sidebar** | Collapsible sidebar for layouts | - |
| **Tabs** | Tabbed interface | @radix-ui/react-tabs |
| **Separator** | Visual divider | - |
| **Scroll Area** | Custom scrollable area | @radix-ui/react-scroll-area |
| **Resizable** | Resizable panel layout | react-resizable-panels |

### Overlays & Dialogs

| Component | Description | Dependencies |
|-----------|-------------|--------------|
| **Dialog** | Modal dialog | @radix-ui/react-dialog |
| **Alert Dialog** | Confirmation dialog | @radix-ui/react-alert-dialog |
| **Sheet** | Slide-out panel (drawer) | @radix-ui/react-dialog |
| **Drawer** | Mobile-friendly drawer | vaul |
| **Popover** | Floating popover | @radix-ui/react-popover |
| **Tooltip** | Tooltip for additional context | @radix-ui/react-tooltip |
| **Hover Card** | Card that appears on hover | @radix-ui/react-hover-card |
| **Context Menu** | Right-click context menu | @radix-ui/react-context-menu |
| **Dropdown Menu** | Dropdown menu | @radix-ui/react-dropdown-menu |
| **Menubar** | Horizontal menubar | @radix-ui/react-menubar |
| **Command** | Command palette | cmdk |

### Feedback & Status

| Component | Description | Dependencies |
|-----------|-------------|--------------|
| **Alert** | Alert for messages/notifications | - |
| **Toast** | Toast notifications | sonner |
| **Progress** | Progress bar | @radix-ui/react-progress |
| **Spinner** | Loading spinner | - |
| **Skeleton** | Skeleton loading placeholder | - |
| **Badge** | Badge for labels/status | - |
| **Empty** | Empty state component | - |

### Display & Media

| Component | Description | Dependencies |
|-----------|-------------|--------------|
| **Avatar** | Avatar for user profiles | @radix-ui/react-avatar |
| **Card** | Card container | - |
| **Table** | Table for displaying data | - |
| **Data Table** | Advanced table (sorting, filtering, pagination) | tanstack-table |
| **Chart** | Charts using Recharts | recharts |
| **Carousel** | Carousel using Embla | embla-carousel-react |
| **Aspect Ratio** | Container with aspect ratio | @radix-ui/react-aspect-ratio |
| **Typography** | Typography styles | - |
| **Item** | Generic item for lists/menus | - |
| **Kbd** | Keyboard shortcut display | - |

## MCP Server Integration

The shadcn MCP Server allows AI assistants to browse, search, and install components from registries using natural language.

### What is MCP?

Model Context Protocol (MCP) is an open protocol that enables AI assistants to securely connect to external data sources and tools. With the shadcn MCP server, your AI assistant gains direct access to:

- **Browse Components** - List all available components, blocks, and templates from any configured registry
- **Search Across Registries** - Find specific components by name or functionality across multiple sources
- **Install with Natural Language** - Add components using simple conversational prompts like "add a login form"
- **Support for Multiple Registries** - Access public registries, private company libraries, and third-party sources

### Quick Start

**Run the MCP init command** in your project:

```bash
<npx/bunx/pnpm dlx/yarn dlx> shadcn@latest mcp init --client claude
```

**Restart your MCP client** and try prompts like:
- "Show me all available components in the shadcn registry"
- "Add the button, dialog and card components to my project"
- "Create a contact form using components from the shadcn registry"

**Supported clients**: `--client claude|cursor|vscode|codex`

### Configuration

#### Claude Code

Add to `.mcp.json` in your project:

```json
{
  "mcpServers": {
    "shadcn": {
      "command": "npx",
      "args": ["shadcn@latest", "mcp"]
    }
  }
}
```

Restart Claude Code and run `/mcp` to verify connection.

#### Cursor

Add to `.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "shadcn": {
      "command": "npx",
      "args": ["shadcn@latest", "mcp"]
    }
  }
}
```

Enable the shadcn MCP server in Cursor Settings.

#### VS Code (GitHub Copilot)

Add to `.vscode/mcp.json`:

```json
{
  "servers": {
    "shadcn": {
      "command": "npx",
      "args": ["shadcn@latest", "mcp"]
    }
  }
}
```

Open `.vscode/mcp.json` and click **Start** next to the shadcn server.

#### Codex

Add to `~/.codex/config.toml`:

```toml
[mcp_servers.shadcn]
command = "npx"
args = ["shadcn@latest", "mcp"]
```

Restart Codex to load the MCP server.

### Registry Configuration

Configure multiple registries in your `components.json`:

```json
{
  "registries": {
    "@shadcn": "https://ui.shadcn.com/r/{name}.json",
    "@v0": "https://v0.dev/chat/b/{name}",
    "@acme": "https://registry.acme.com/{name}.json",
    "@private": {
      "url": "https://api.company.com/registry/{name}.json",
      "headers": {
        "Authorization": "Bearer ${REGISTRY_TOKEN}",
        "X-API-Key": "${API_KEY}"
      },
      "params": {
        "version": "latest"
      }
    }
  }
}
```

Environment variables in `${VAR_NAME}` format are automatically expanded.

### Authentication

For private registries, set environment variables in `.env.local`:

```bash
REGISTRY_TOKEN=your_token_here
API_KEY=your_api_key_here
```

### Example Prompts

Once configured, use natural language to interact with registries:

**Browse & Search**:
- "Show me all available components in the shadcn registry"
- "Find me a login form from the shadcn registry"

**Install Items**:
- "Add the button component to my project"
- "Create a login form using shadcn components"
- "Install the Cursor rules from the acme registry"

**Work with Namespaces**:
- "Show me components from acme registry"
- "Install @internal/auth-form"
- "Build a landing page using hero, features and testimonials from the acme registry"

### Installing from Registries (CLI)

```bash
# Install from public registry
<npx/bunx/pnpm dlx/yarn dlx> shadcn@latest add @shadcn/button

# Install from v0
<npx/bunx/pnpm dlx/yarn dlx> shadcn@latest add @v0/dashboard

# Install from private registry with auth
<npx/bunx/pnpm dlx/yarn dlx> shadcn@latest add @private/button

# Install multiple resources
<npx/bunx/pnpm dlx/yarn dlx> shadcn@latest add @acme/header @internal/auth-utils
```

### Troubleshooting

**MCP Not Responding**:
1. Check configuration is properly enabled in your MCP client
2. Restart MCP client after configuration changes
3. Ensure `shadcn` is installed in your project
4. Confirm network access to configured registries

**Registry Access Issues**:
1. Verify registry URLs are correct in `components.json`
2. Ensure environment variables are set for private registries
3. Confirm registry is online and accessible
4. Check namespace syntax is correct (`@namespace/component`)

**Installation Failures**:
1. Ensure valid `components.json` file
2. Confirm target directories exist
3. Check write permissions for component directories
4. Verify required dependencies are installed

## Registry Schema

For publishing your own components:

### Basic Registry Item

```json
{
  "name": "my-component",
  "type": "registry:component",
  "registryDependencies": ["button", "card"],
  "dependencies": ["zod", "date-fns"],
  "files": [
    {
      "path": "components/my-component.tsx",
      "type": "registry:component",
      "target": "components/my-component.tsx"
    }
  ]
}
```

### Full Registry Item with Styling

```json
{
  "name": "my-component",
  "type": "registry:component",
  "registryDependencies": ["button", "card"],
  "dependencies": ["zod", "date-fns"],
  "devDependencies": ["@types/node"],
  "tailwind": {
    "config": {
      "theme": {
        "extend": {
          "colors": {
            "brand": "hsl(var(--brand))"
          }
        }
      }
    }
  },
  "cssVars": {
    "light": {
      "brand": "220 13% 10%"
    },
    "dark": {
      "brand": "220 13% 90%"
    }
  },
  "files": [
    {
      "path": "components/my-component.tsx",
      "type": "registry:component"
    }
  ],
  "categories": ["ui"]
}
```

### Registry Types

| Type | Description |
|------|-------------|
| `registry:component` | React component |
| `registry:hook` | React hook |
| `registry:lib` | Utility/library function |
| `registry:page` | Page component (has `target` property for file-based routing) |
| `registry:block` | Pre-built page/feature with multiple files |
| `registry:theme` | Theme configuration |

### Building Registry Files

```bash
# Generate registry JSON from registry.json
<npx/bunx/pnpm dlx/yarn dlx> shadcn@latest build

# Custom output directory
<npx/bunx/pnpm dlx/yarn dlx> shadcn@latest build --output ./public/registry
```

## CLI Commands Reference

**Package Manager**: Use your preferred package manager's executor:
- `npx` (npm), `bunx` (bun), `pnpm dlx` (pnpm), `yarn dlx` (yarn)

### init

Initialize configuration and dependencies:

```bash
<npx/bunx/pnpm dlx/yarn dlx> shadcn@latest init [options]

# Options:
  -t, --template <template>      # Template: next, next-monorepo
  -b, --base-color <base-color>  # Base color: neutral, gray, zinc, stone, slate
  -y, --yes                      # Skip confirmation
  -f, --force                    # Force overwrite
  -c, --cwd <cwd>                # Working directory
  -s, --silent                   # Mute output
  --src-dir                      # Use src directory
  --css-variables                # Use CSS variables (default: true)
  --no-base-style                # Don't install base style
```

### add

Add components to project:

```bash
<npx/bunx/pnpm dlx/yarn dlx> shadcn@latest add [options] [components...]

# Options:
  -y, --yes           # Skip confirmation
  -o, --overwrite     # Overwrite existing files
  -c, --cwd <cwd>     # Working directory
  -a, --all           # Add all components
  -p, --path <path>   # Custom install path
  -s, --silent        # Mute output
```

### view

View components before installing:

```bash
<npx/bunx/pnpm dlx/yarn dlx> shadcn@latest view [item]

# View multiple
<npx/bunx/pnpm dlx/yarn dlx> shadcn@latest view button card dialog

# View from namespaced registries
<npx/bunx/pnpm dlx/yarn dlx> shadcn@latest view @acme/auth @v0/dashboard
```

### search

Search registries:

```bash
<npx/bunx/pnpm dlx/yarn dlx> shadcn@latest search [options] <registries...>

# Examples
<npx/bunx/pnpm dlx/yarn dlx> shadcn@latest search @shadcn -q "button"
<npx/bunx/pnpm dlx/yarn dlx> shadcn@latest search @shadcn @v0 @acme

# Options:
  -c, --cwd <cwd>        # Working directory
  -q, --query <query>    # Search query
  -l, --limit <number>   # Max items per registry (default: 100)
  -o, --offset <number>  # Items to skip (default: 0)
```

### list

List items from registry (alias for `search`):

```bash
<npx/bunx/pnpm dlx/yarn dlx> shadcn@latest list <registries...>
```

## Customization Best Practices

1. **Customize the theme** - Don't use defaults
   ```css
   /* Customize in globals.css */
   :root {
     --radius: 0.5rem; /* or 0 for sharp corners */
     --primary: 220 13% 10%; /* custom primary */
   }
   ```

2. **Extend components** - Don't just copy-paste
   - Add custom variants
   - Modify animations
   - Adjust spacing to match your aesthetic

3. **Combine primitives creatively**
   - Layer components for unique effects
   - Use Command for more than command palettes
   - Use Sheet for custom navigation patterns

4. **Follow the composition pattern**
   ```tsx
   // Compose, don't configure
   <Card>
     <Card.Header>
       <Card.Title>Header</Card.Title>
       <Card.Description>Description</Card.Description>
     </Card.Header>
     <Card.Content>Content</Card.Content>
     <Card.Footer>Footer</Card.Footer>
   </Card>
   ```
