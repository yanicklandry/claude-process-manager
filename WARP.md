# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

**cproc** (Claude Process Manager) is a bash-based command-line utility that helps users manage and monitor processes spawned by Claude AI assistant in terminal environments. The tool provides system monitoring capabilities and process management specifically tailored for Claude-spawned processes.

### Key Features
- List Claude-spawned processes with their working directories
- Kill specific processes or all Claude processes at once
- Monitor system resource usage and active network listeners
- View working directories of running processes
- Process hierarchy visualization (parent-child relationships)

## Architecture

This is a simple single-script project with the following structure:

- **`cproc.sh`** - Main executable script containing all functionality
- **`README.md`** - Comprehensive documentation and usage examples
- **`LICENSE`** - MIT license file
- Standard project files (`.gitignore`, git repository)

### Core Components

The main script (`cproc.sh`) contains several key functions:

1. **`list_claude_processes()`** - Identifies and displays Claude shell processes by searching for `.claude/shell-snapshots/snapshot-zsh` patterns
2. **`kill_claude_processes()`** - Terminates processes with graceful SIGTERM followed by SIGKILL if necessary
3. **`process_status()`** - Provides system-wide process monitoring and resource usage
4. **`show_process_cwd()`** - Shows working directories for specified processes
5. **`show_help()`** - Displays usage information and command syntax

### Process Detection Logic

The tool identifies Claude-spawned processes by:
- Searching for shell processes executing from `.claude/shell-snapshots/` directories
- Matching the pattern `snapshot-zsh-*` in command lines
- Using `ps` and `lsof` commands for process information and working directory detection

## Development Commands

### Testing the Script
```bash
# Test basic functionality
./cproc.sh help

# Test process listing (safe, read-only)
./cproc.sh list

# Test status monitoring
./cproc.sh status
```

### Making the Script Executable
```bash
chmod +x cproc.sh
```

### Installation Testing
```bash
# Test the symlink works correctly
ls -la ~/bin/cproc

# Test the command works from anywhere
cproc help
```

## System Requirements

- **macOS** (uses `lsof` and `ps` commands with macOS-specific flags)
- **Bash** 4.0+
- **Claude AI** running in terminal environment
- Standard Unix utilities: `ps`, `lsof`, `awk`, `grep`

## Important Implementation Notes

### Process Identification Strategy
The script uses a specific pattern to identify Claude processes:
```bash
ps -eo pid,ppid,user,command | grep -E "\\.claude.*snapshot-zsh" | grep -v grep
```

This pattern is Claude-specific and may need updating if Claude changes its process spawning mechanism.

### Error Handling
- Uses `set -e` for strict error handling
- Graceful handling of missing processes or permissions issues
- Fallback behaviors when `lsof` can't determine working directories

### Resource Monitoring
The status function monitors:
- Memory-intensive processes (>100MB RAM)
- Common development ports (3000, 3001, 4000, 5000, 7860, 7861, 8000, 8080, 8888, 9000)
- Active network listeners using `lsof`

## Key Design Decisions

1. **Single File Architecture** - All functionality contained in one bash script for simplicity and portability
2. **Command Aliases** - Multiple ways to invoke same functionality (ls/list/l, k/kill, etc.)
3. **Safe Process Termination** - Uses SIGTERM first, then SIGKILL as fallback
4. **Working Directory Context** - Shows where processes are running from, which is crucial for Claude workflow management
5. **Bulk Operations** - Can kill all Claude processes at once for cleanup scenarios

## Maintenance Notes

### Potential Breaking Changes
- Changes to Claude's process spawning patterns could break process detection
- macOS system command changes could affect `ps` or `lsof` usage
- Updates to shell snapshot directory structure in Claude

### Extension Points
- Additional port monitoring ranges
- Support for other Unix-like systems (Linux, BSD)
- Integration with other AI assistant process patterns
- Enhanced resource monitoring metrics
