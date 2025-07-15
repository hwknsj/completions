# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Zsh completion plugin that provides enhanced completions for various command-line tools and custom functions. It follows the Zsh Plugin Standard and integrates with plugin managers like Zi.

## Architecture

The project has a modular structure with clear separation of concerns:

### Core Files
- `completions.plugin.zsh` - Main plugin file that sets up fpath, loads functions, and defines generic completions
- `functions.zsh` - Additional utility functions and completions setup  
- `load_functions` - Standalone script following Zsh Plugin Standard for loading functions

### Completion Scripts (`src/`)
All completion scripts in `src/` follow the pattern `_<command>` and provide tab completion for:
- Development tools: `_gh`, `_docker`, `_pnpm`, `_uv`, `_turbo`, `_fnm`
- Utilities: `_rclone`, `_glow`, `_procs`, `_ipinfo`, `_op`, `_supabase`
- Custom functions: `_pr_create`, `_launchctl`, `_vid-compress`, `_vid-trim`, `_vid-trim-hb`

### Custom Functions (`functions/`)
- `pr_create` - GitHub PR creation wrapper with enterprise host support
- `vid-compress` - FFmpeg video compression utility
- `vid-trim` - Video trimming using FFmpeg

## Key Features

### Host Management
The `pr_create` function supports multiple GitHub Enterprise hosts:
- `hulu` → `github.prod.hulu.com`
- `twdc`/`disney` → `github.twdcgrid.net` 
- `bamgrid` → `github.bamtech.co`

### Video Processing Functions
- `vid-compress`: Compresses videos with configurable speed/CRF using FFmpeg
- `vid-trim`: Trims videos with start/end/duration/split options
- `vid-trim-hb`: Same as above but using HandBrake for encoding

### Completion System
- Uses `compgeneric()` function to easily add generic `--help` style completions
- Handles both tools and IPv6 toolkit commands
- Includes pip completion integration

## Development Commands

No build system - this is a pure Zsh plugin. To test changes:

```bash
# Reload the plugin in your shell
source completions.plugin.zsh

# Test completions
pr_create --<TAB>
vid-compress --<TAB>

# Test custom functions
pr_create --help
vid-compress -h
```

## Adding New Completions

1. Create `src/_<command>` file following existing patterns
2. Add the command to autoload in `completions.plugin.zsh:26`
3. For generic tools, add to the `cmds` array in `completions.plugin.zsh:38-68`

## Zsh Plugin Standard Compliance

The plugin follows https://wiki.zshell.dev/community/zsh_plugin_standard:
- Proper `$0` handling for script/function duality
- Functions directory auto-added to fpath
- Global `Plugins[COMPLETIONS_DIR]` parameter
- Compatible with modern plugin managers