# cproc - Claude Process Manager

A command-line utility to list, monitor, and manage processes spawned by Claude AI assistant in terminal environments, with additional system monitoring capabilities.

**Current Status:** ✅ Installed and working at `/Users/yanick/bin/claude-process-manager/` with symlink `~/bin/cproc`

## Overview

When using Claude in terminal applications, it often spawns background processes that can consume significant system resources. This tool helps you:

- 📋 **List** all Claude-spawned processes with their working directories
- 🛑 **Kill** specific processes or all Claude processes at once  
- 📊 **Monitor** system resource usage and active network listeners
- 📁 **View** working directories of any running process

## How is this different from `claude process`?

While Claude may have a built-in `claude process` command, `cproc` offers several advantages:

| Feature | `claude process` | `cproc` |
|---------|------------------|----------|
| **Availability** | May not exist or be limited | ✅ Always available as standalone tool |
| **Working Directories** | ❌ Not shown | ✅ Shows where each process is running from |
| **Process Hierarchy** | ❌ Limited | ✅ Shows parent-child relationships |
| **System Monitoring** | ❌ Claude-only | ✅ System-wide resource monitoring |
| **Network Ports** | ❌ Not included | ✅ Shows active development servers |
| **Bulk Operations** | ❌ Limited | ✅ Kill multiple processes or all at once |
| **Cross-platform** | ❌ Claude-dependent | ✅ Works independently |
| **Customizable** | ❌ No | ✅ Open source, modify as needed |

**Key Differences:**
- **🗂️ Directory Context**: `cproc` shows exactly which folder each process is running from
- **🔗 Process Tree**: See parent shell processes and their children
- **📊 Resource Usage**: Monitor memory consumption and system impact
- **🌐 Network Awareness**: Check which ports your development servers are using
- **⚡ Bulk Management**: Kill all Claude processes with one command
- **🔧 Standalone**: Works even if Claude's built-in commands are unavailable

**Example Comparison:**
```bash
# If claude process shows:
# PID 12345: python3

# cproc shows:
# 📋 Shell Process (PID: 12340):
#    Command: /bin/zsh -c -l source ~/.claude/shell-snapshots/...
#    📁 Working Directory: /Users/yanick/my-project
#    👶 Child processes:
#       ├── PID: 12345 - python3 launch.py --api --listen
#       │   📁 /Users/yanick/my-project
```

## Installation

### Quick Setup

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/cproc.git ~/bin/cproc
   ```

2. Make the script executable:
   ```bash
   chmod +x ~/bin/cproc/cproc.sh
   ```

3. Make sure `~/bin` is in your PATH (add to `~/.zshrc` or `~/.bashrc` if needed):
   ```bash
   export PATH="$HOME/bin:$PATH"
   ```

4. Create a symlink for easy access:
   ```bash
   ln -sf ~/bin/cproc/cproc.sh ~/bin/cproc
   ```

**Note:** If you already have this installed from a previous setup, the directory might be named `claude-process-manager` instead of `cproc`. In that case, use:
   ```bash
   ln -sf ~/bin/claude-process-manager/cproc.sh ~/bin/cproc
   ```

### Manual Installation

1. Download `cproc.sh` and place it in a directory in your PATH
2. Make it executable:
   ```bash
   chmod +x /path/to/cproc.sh
   ```

## Usage

### Basic Commands

```bash
# List all Claude-spawned processes (default command)
cproc
cproc list
cproc ls
cproc l

# Kill specific process(es)
cproc kill 12345
cproc kill 12345 67890
cproc k 12345

# Kill ALL Claude processes
cproc kill all
cproc k all

# Show process status and resource usage
cproc status
cproc s

# Show working directory for process(es)
cproc cwd 12345
cproc pwd 12345 67890

# Show help
cproc help
cproc h
```

### Examples

**List all Claude processes:**
```bash
$ cproc list
🤖 Claude-spawned processes:
================================

📋 Shell Process (PID: 58288):
   Command: /bin/zsh -c -l source ~/.claude/shell-snapshots/snapshot-zsh-...
   📁 Working Directory: ~/Developer/2025/stable-diffusion-webui
   👶 Child processes:
      ├── PID: 58301 - python3 launch.py --api --listen --skip-torch-cuda-test --use-cpu all
      │   📁 ~/Developer/2025/stable-diffusion-webui

📊 Summary:
   Claude shells: 1
```

**Kill a memory-hungry process:**
```bash
$ cproc kill 58301
🛑 Killing PID 58301...
✅ PID 58301 killed.
```

**Check process status:**
```bash
$ cproc status
📊 Process Status Summary:
==========================
🤖 Claude processes:
   None found

🔍 High-resource processes (>100MB RAM):
   1234 5.2% 512MB python3
   5678 3.1% 256MB node

🌐 Active network listeners:
   Port 3000: node 1234
   Port 8080: python3 5678
```

## How It Works

The tool identifies Claude-spawned processes by looking for shell processes that:
- Execute from `.claude/shell-snapshots/` directories
- Match the pattern `snapshot-zsh-*` in their command line
- Are spawned by Claude's session management system

## Common Use Cases

### Memory Management
Large applications and development tools can consume significant RAM. Use `cproc` to:
- Monitor which processes are using the most memory
- Quickly terminate resource-heavy processes when done
- Clean up orphaned processes that didn't shut down properly

### Development Workflow
When working with multiple Claude sessions:
- See what projects are currently running in the background
- Identify which directory each process is running from
- Clean up old development servers or background tasks

### System Monitoring
- Get a quick overview of all Claude-related system activity
- Check which development servers and services are running
- Monitor network port usage for web applications
- Troubleshoot processes that might be stuck or unresponsive

## Requirements

- **macOS** (uses `lsof` and `ps` commands)
- **Bash** 4.0+ 
- **Claude AI** running in a terminal environment (like Warp)

## File Structure

```
~/bin/claude-process-manager/  # or ~/bin/cproc/ for new installs
├── cproc.sh       # Main script
├── README.md      # This documentation  
├── LICENSE        # MIT license
├── .gitignore     # Git ignore file
└── .git/          # Git repository
```

**Current symlink:** `~/bin/cproc` -> `~/bin/claude-process-manager/cproc.sh`

## Troubleshooting

### "No Claude processes found"
This is normal if:
- No Claude sessions are currently running background processes
- All previous processes have completed and terminated
- You're not running Claude in a terminal environment

### Permission errors
Make sure the script is executable:
```bash
chmod +x ~/bin/claude-process-manager/cproc.sh  # or ~/bin/cproc/cproc.sh for new installs
```

### Command not found
Ensure `~/bin` is in your PATH:
```bash
echo $PATH | grep -o "$HOME/bin"
```

## Contributing

Feel free to submit issues, feature requests, or pull requests. This tool is designed to be simple and focused on Claude process management.

## License

MIT License - Feel free to use, modify, and distribute.

## Author

Created to help manage resource-intensive AI processes spawned by Claude in terminal environments.
