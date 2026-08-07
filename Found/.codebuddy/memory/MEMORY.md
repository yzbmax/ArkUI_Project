# Project Memory

## Tech Stack
- HarmonyOS (ArkTS/ArkUI) 
- API Level 11
- Package: oh-package.json5

## Icon System (2024-08-04)
- **Approach**: Image + SVG + colorFilter matrix (NOT Shape + Path)
- **Why**: Shape component cannot reliably size in Flex layout; Image sizing is deterministic
- **Why colorFilter not fillColor**: fillColor targets SVG `fill` (interior), Tabler icons use `stroke` (outline). colorFilter matrix replaces all visible pixel colors, correctly tinting stroke lines.
- SVG files in `base/media/` use `stroke="currentColor"` (converted from `#000000`)
- colorFilter matrix: `[0,0,0,0,R, 0,0,0,0,G, 0,0,0,0,B, 0,0,0,1,0]` tints to target while preserving alpha
- Icon component: `@Props: name, iconSize, tint(number[])`
- TINT constants in `tint.ts`; icon→Resource map in `IconImage.ets`
- Old Shape+Path approach removed; IconDefs.ets is unused legacy
