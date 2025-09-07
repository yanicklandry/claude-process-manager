#!/bin/bash

# Claude Process Manager (cproc.sh)
# Standalone script to list and manage processes started by Claude

set -e

SCRIPT_NAME=$(basename "$0")

function show_help() {
    cat << EOF
$SCRIPT_NAME - Claude Process Manager

USAGE:
    $SCRIPT_NAME [COMMAND] [OPTIONS]

COMMANDS:
    list, ls, l          List all Claude-spawned processes with directories
    kill, k              Kill Claude processes
    status, s            Show status of all processes
    cwd, pwd             Show working directory for specific process(es)
    help, h              Show this help message

OPTIONS:
    For 'kill' command:
        <PID>            Kill specific process by PID
        <PID1> <PID2>... Kill multiple processes
        all              Kill ALL Claude processes
        
    For 'cwd' command:
        <PID>            Show working directory for process
        <PID1> <PID2>... Show directories for multiple processes

EXAMPLES:
    $SCRIPT_NAME list                # List all Claude processes
    $SCRIPT_NAME kill 12345          # Kill process 12345
    $SCRIPT_NAME kill all            # Kill all Claude processes
    $SCRIPT_NAME cwd 12345 67890     # Show directories for processes
    $SCRIPT_NAME status              # Show process status

ALIASES:
    ls, l    -> list
    k        -> kill
    s        -> status
    pwd      -> cwd
    h        -> help
EOF
}

function list_claude_processes() {
    echo "🤖 Claude-spawned processes:"
    echo "================================"
    
    # Find Claude shell processes
    local claude_shells=$(ps -eo pid,ppid,user,command | grep -E "\.claude.*snapshot-zsh" | grep -v grep)
    
    if [[ -z "$claude_shells" ]]; then
        echo "No Claude shell processes found."
        return 0
    fi
    
    echo "$claude_shells" | while IFS= read -r line; do
        local pid=$(echo "$line" | awk '{print $1}')
        local command=$(echo "$line" | cut -d' ' -f4-)
        
        echo ""
        echo "📋 Shell Process (PID: $pid):"
        echo "   Command: $command"
        
        # Get working directory using lsof
        local cwd=$(lsof -p "$pid" 2>/dev/null | grep " cwd " | awk '{print $NF}')
        if [[ -n "$cwd" ]]; then
            echo "   📁 Working Directory: $cwd"
        else
            echo "   📁 Working Directory: Unable to determine"
        fi
        
        # Find child processes
        local children=$(ps -eo pid,ppid,user,command | awk -v parent="$pid" '$2 == parent && $1 != parent')
        
        if [[ -n "$children" ]]; then
            echo "   👶 Child processes:"
            echo "$children" | while IFS= read -r child_line; do
                local child_pid=$(echo "$child_line" | awk '{print $1}')
                local child_cmd=$(echo "$child_line" | cut -d' ' -f4- | cut -c1-80)
                
                # Get child working directory
                local child_cwd=$(lsof -p "$child_pid" 2>/dev/null | grep " cwd " | awk '{print $NF}')
                if [[ -n "$child_cwd" ]]; then
                    echo "      ├── PID: $child_pid - $child_cmd"
                    echo "      │   📁 $child_cwd"
                else
                    echo "      ├── PID: $child_pid - $child_cmd"
                    echo "      │   📁 Unable to determine directory"
                fi
            done
        fi
    done
    
    echo ""
    echo "📊 Summary:"
    local shell_count=$(echo "$claude_shells" | wc -l | tr -d ' ')
    echo "   Claude shells: $shell_count"
}

function kill_claude_processes() {
    if [[ $# -eq 0 ]]; then
        echo "Error: No PID specified."
        echo "Usage: $SCRIPT_NAME kill <PID> [PID2] [PID3] ..."
        echo "Or: $SCRIPT_NAME kill all"
        return 1
    fi
    
    if [[ "$1" == "all" ]]; then
        echo "🛑 Killing ALL Claude-spawned processes..."
        
        # Get all Claude shell PIDs
        local pids=$(ps -eo pid,ppid,user,command | grep -E "\.claude.*snapshot-zsh" | grep -v grep | awk '{print $1}')
        
        if [[ -z "$pids" ]]; then
            echo "No Claude processes found to kill."
            return 0
        fi
        
        for pid in $pids; do
            echo "   Killing PID $pid..."
            kill -TERM "$pid" 2>/dev/null || echo "   Failed to kill PID $pid"
        done
        
        # Wait a moment, then force kill if necessary
        sleep 2
        for pid in $pids; do
            if ps -p "$pid" >/dev/null 2>&1; then
                echo "   Force killing PID $pid..."
                kill -KILL "$pid" 2>/dev/null
            fi
        done
        
        echo "✅ Done."
    else
        # Kill specific PIDs
        for pid in "$@"; do
            if ps -p "$pid" >/dev/null 2>&1; then
                echo "🛑 Killing PID $pid..."
                kill -TERM "$pid" 2>/dev/null || kill -KILL "$pid" 2>/dev/null
                echo "✅ PID $pid killed."
            else
                echo "❌ PID $pid not found or already dead."
            fi
        done
    fi
}

function process_status() {
    echo "📊 Process Status Summary:"
    echo "=========================="
    
    # Show Claude processes first
    echo "🤖 Claude processes:"
    list_claude_processes | grep -E "(Shell Process|Child processes|Summary)" || echo "   None found"
    
    echo ""
    echo "🔍 High-resource processes (>100MB RAM):"
    
    # Show memory-intensive processes
    ps aux | awk 'NR>1 {if($6/1024 > 100) print $2, $3"%", int($6/1024)"MB", $11}' | head -10 | while IFS= read -r line; do
        echo "   $line"
    done
    
    echo ""
    echo "🌐 Active network listeners:"
    
    # Show common development ports
    for port in 3000 3001 4000 5000 7860 7861 8000 8080 8888 9000; do
        if lsof -i :$port >/dev/null 2>&1; then
            local process=$(lsof -i :$port | tail -1 | awk '{print $1, $2}')
            echo "   Port $port: $process"
        fi
    done
}

function show_process_cwd() {
    if [[ $# -eq 0 ]]; then
        echo "Error: No PID specified."
        echo "Usage: $SCRIPT_NAME cwd <PID> [PID2] [PID3] ..."
        return 1
    fi
    
    for pid in "$@"; do
        if ps -p "$pid" >/dev/null 2>&1; then
            local cwd=$(lsof -p "$pid" 2>/dev/null | grep " cwd " | awk '{print $NF}')
            local cmd=$(ps -p "$pid" -o command= 2>/dev/null | cut -c1-60)
            
            echo "PID $pid: $cmd"
            if [[ -n "$cwd" ]]; then
                echo "📁 $cwd"
            else
                echo "📁 Unable to determine working directory"
            fi
            echo ""
        else
            echo "❌ PID $pid not found"
        fi
    done
}

# Main script logic
case "${1:-list}" in
    list|ls|l)
        list_claude_processes
        ;;
    kill|k)
        shift
        kill_claude_processes "$@"
        ;;
    status|s)
        process_status
        ;;
    cwd|pwd)
        shift
        show_process_cwd "$@"
        ;;
    help|h|--help|-h)
        show_help
        ;;
    *)
        echo "Error: Unknown command '$1'"
        echo ""
        show_help
        exit 1
        ;;
esac
