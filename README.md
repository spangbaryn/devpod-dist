# DevPod

DevPod is a command-line tool for managing development workflows with AI-powered assistance.

## Quick Install

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/spangbaryn/devpod-dist/main/install.sh | bash
```

### Windows (PowerShell)

```powershell
iwr -useb https://raw.githubusercontent.com/spangbaryn/devpod-dist/main/install.ps1 | iex
```

## What is DevPod?

DevPod helps you manage your development projects with:

- **Work Tracking**: Create and manage epics, features, bugs, and chores
- **Development Modes**: Speed, Discovery, Stable, and Production modes for different phases
- **Git Integration**: Automatic branch creation and workflow management
- **AI Context**: Maintains project context in CLAUDE.md for AI assistants
- **Standards Enforcement**: Configurable project standards and conventions

## Manual Installation

If you prefer to install manually:

1. Download the binary for your platform from [Releases](https://github.com/spangbaryn/devpod/releases/latest)
   - macOS: `devpod-macos`
   - Linux: `devpod-linux`
   - Windows: `devpod-win.exe`

2. Make it executable (macOS/Linux):
   ```bash
   chmod +x devpod-*
   ```

3. Move to your PATH:
   ```bash
   # macOS/Linux
   sudo mv devpod-* /usr/local/bin/devpod

   # Windows: Move to a directory in your PATH or add the directory to PATH
   ```

## Getting Started

Once installed, initialize DevPod in your project:

```bash
cd your-project
devpod init
```

Create your first work item:

```bash
devpod work create feature "Add user authentication"
devpod work start 1
```

## Auto-Updates

DevPod automatically checks for updates daily and downloads them in the background. Updates are applied on the next run.

## Documentation

For full documentation, visit the [DevPod repository](https://github.com/spangbaryn/devpod).

## Support

- Report issues: [GitHub Issues](https://github.com/spangbaryn/devpod/issues)
- Version: Run `devpod --version`

## License

**This Repository (Install Scripts):** MIT License
The installation scripts in this repository are open source and free to use, modify, and distribute.

**DevPod Application:** Proprietary - Closed Source
The DevPod application itself (the binaries you download) is proprietary software. The install scripts simply automate downloading and installing the closed-source binaries from GitHub releases.
