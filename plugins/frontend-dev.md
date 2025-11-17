---
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
description: Create distinctive, production-grade frontend interfaces with high design quality. Use this skill when the user asks to build web components, pages, or applications. Generates creative, polished code that avoids generic AI aesthetics.
---

## Context

This skill guides creation of distinctive, production-grade frontend interfaces that avoid generic "AI slop" aesthetics. Implement real working code with exceptional attention to aesthetic details and creative choices.

The user provides frontend requirements: a component, page, application, or interface to build. They may include context about the purpose, audience, or technical constraints.

## Design Thinking

Before coding, understand the context and commit to a BOLD aesthetic direction:

- **Purpose**: What problem does this interface solve? Who uses it?
- **Tone**: Pick an extreme: brutally minimal, maximalist chaos, retro-futuristic, organic/natural, luxury/refined, playful/toy-like, editorial/magazine, brutalist/raw, art deco/geometric, soft/pastel, industrial/utilitarian, etc. There are so many flavors to choose from. Use these for inspiration but design one that is true to the aesthetic direction.
- **Constraints**: Technical requirements (framework, performance, accessibility).
- **Differentiation**: What makes this UNFORGETTABLE? What's the one thing someone will remember?

**CRITICAL**: Choose a clear conceptual direction and execute it with precision. Bold maximalism and refined minimalism both work - the key is intentionality, not intensity.

Then implement working code (HTML/CSS/JS, React, Vue, etc.) that is:
- Production-grade and functional
- Visually striking and memorable
- Cohesive with a clear aesthetic point-of-view
- Meticulously refined in every detail

## Implementation Guidelines

### Component Architecture

- **Use shadcn/ui components** as the foundation for UI elements
- **Avoid large components**: Break down complex interfaces into smaller, focused components
- **Component isolation**: Each component should have a single, well-defined responsibility
- **Better testability**: Smaller components with isolated concerns are easier to test and maintain
- **Composition over complexity**: Build complex interfaces by composing simple, reusable components

### File Organization

Structure your components for clarity and maintainability:
```
components/
  ├── ui/              # shadcn/ui components
  ├── [feature]/       # Feature-specific components
  │   ├── components/  # Sub-components
  │   └── index.tsx    # Main feature component
  └── shared/          # Shared utility components
```

## Frontend Aesthetics Guidelines

Focus on:

### Typography
Choose fonts that are beautiful, unique, and interesting. Avoid generic fonts like Arial and Inter; opt instead for distinctive choices that elevate the frontend's aesthetics; unexpected, characterful font choices. Pair a distinctive display font with a refined body font.

### Color & Theme
Commit to a cohesive aesthetic. Use CSS variables for consistency. Dominant colors with sharp accents outperform timid, evenly-distributed palettes.

### Motion
Use animations for effects and micro-interactions. Prioritize CSS-only solutions for HTML. Use Motion library (Framer Motion) for React when available. Focus on high-impact moments: one well-orchestrated page load with staggered reveals (animation-delay) creates more delight than scattered micro-interactions. Use scroll-triggering and hover states that surprise.

### Spatial Composition
Unexpected layouts. Asymmetry. Overlap. Diagonal flow. Grid-breaking elements. Generous negative space OR controlled density.

### Backgrounds & Visual Details
Create atmosphere and depth rather than defaulting to solid colors. Add contextual effects and textures that match the overall aesthetic. Apply creative forms like:
- Gradient meshes
- Noise textures
- Geometric patterns
- Layered transparencies
- Dramatic shadows
- Decorative borders
- Custom cursors
- Grain overlays

## What to Avoid

NEVER use generic AI-generated aesthetics like:
- Overused font families (Inter, Roboto, Arial, system fonts)
- Cliched color schemes (particularly purple gradients on white backgrounds)
- Predictable layouts and component patterns
- Cookie-cutter design that lacks context-specific character

Interpret creatively and make unexpected choices that feel genuinely designed for the context. No design should be the same. Vary between light and dark themes, different fonts, different aesthetics. NEVER converge on common choices (Space Grotesk, for example) across generations.

## Design Complexity

**IMPORTANT**: Match implementation complexity to the aesthetic vision:
- **Maximalist designs** need elaborate code with extensive animations and effects
- **Minimalist or refined designs** need restraint, precision, and careful attention to spacing, typography, and subtle details
- Elegance comes from executing the vision well

## Consistency

Should be consistent with the current design style guide. Before implementing:
1. Check for existing design tokens, theme files, or style guides
2. Review existing components for patterns and conventions
3. Match the established aesthetic direction while adding your unique touches

## Your Task

Based on the user's requirements:

1. **Understand the context**: Analyze the purpose, audience, and constraints
2. **Choose a bold aesthetic direction**: Commit to a clear, distinctive vision
3. **Plan component architecture**: Break down the interface into small, focused components
4. **Implement with shadcn/ui**: Use shadcn components as building blocks
5. **Add distinctive details**: Typography, colors, animations, and visual effects
6. **Ensure consistency**: Match existing style guides while maintaining your creative vision
7. **Test and refine**: Ensure components are functional, accessible, and maintainable

Remember: Claude is capable of extraordinary creative work. Don't hold back, show what can truly be created when thinking outside the box and committing fully to a distinctive vision.
