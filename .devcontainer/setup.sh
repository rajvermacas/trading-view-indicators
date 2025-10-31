#!/bin/bash

# Exit on error (but allow grep to fail)
set -e
set +o pipefail

# Target home directory for installation (use vscode user's home)
TARGET_HOME="/root"

# Create log file
LOG_FILE="/root/setup-log.txt"
if [ ! -d "/root" ]; then
    LOG_FILE="/tmp/setup-log.txt"
fi


# Simple logging function
log() {
    echo "  → $*"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')]   → $*" >> "$LOG_FILE" 2>/dev/null || true
}

# Log file operations with source and target
log_file_op() {
    local operation="$1"
    local source="$2"
    local target="$3"
    echo "  [$operation] Source: $source"
    echo "                Target: $target"
    echo "  [$operation] Source: $source → Target: $target" >> "$LOG_FILE" 2>/dev/null || true
}

log "========================================"
log "Starting development setup..."
log "========================================"
log "Script execution started at: $(date '+%Y-%m-%d %H:%M:%S')"
log "User: $(whoami)"
log "Home directory: $HOME"
log "Current directory: $(pwd)"
log "Log file location: $LOG_FILE"

# Clone the repository
REPO_URL="https://github.com/rajvermacas/development-setup.git"
TEMP_DIR="/tmp/development-setup"

log ""
log "=== STEP 1: Repository Cloning ==="
log "Repository URL: $REPO_URL"
log "Temporary clone directory: $TEMP_DIR"

# Remove existing temp directory if it exists
if [ -d "$TEMP_DIR" ]; then
    log "Found existing directory at $TEMP_DIR"
    log "Removing existing directory..."
    rm -rf "$TEMP_DIR" 2>/dev/null || true
    log "Directory removed successfully"
else
    log "No existing directory found at $TEMP_DIR"
fi

# Clone the repository
log "Starting git clone operation..."
log "Command: git clone $REPO_URL $TEMP_DIR"
if git clone "$REPO_URL" "$TEMP_DIR" 2>/dev/null; then
    log "✓ Repository cloned successfully"
    log "Clone completed at: $(date '+%H:%M:%S')"
    log "Repository size: $(du -sh "$TEMP_DIR" 2>/dev/null | cut -f1)"
    REPO_AVAILABLE=true
else
    log "✗ Failed to clone repository"
    log "Clone failed at: $(date '+%H:%M:%S')"
    log "Continuing setup without repository files..."
    REPO_AVAILABLE=false
fi

# Create target directories
log ""
log "=== STEP 2: Creating Target Directories ==="
log "Preparing to create directory structure..."

# Claude directories
log "Creating Claude directories..."
TARGET_DIR="$TARGET_HOME/.claude"
log "Main Claude directory: $TARGET_DIR"
mkdir -p "$TARGET_DIR"
log "Created: $TARGET_DIR"

for subdir in agents commands output-styles; do
    FULL_PATH="$TARGET_DIR/$subdir"
    log "Creating subdirectory: $FULL_PATH"
    mkdir -p "$FULL_PATH"
    log "✓ Created: $FULL_PATH"
done

# Gemini directories
log "Creating Gemini directories..."
TARGET_DIR="$TARGET_HOME/.gemini/commands"
log "Target: $TARGET_DIR"
mkdir -p "$TARGET_DIR"
log "✓ Created: $TARGET_DIR"

# Project templates directory
log "Creating project templates directory..."
TARGET_DIR="$TARGET_HOME/projects/claude-code-templates"
log "Target: $TARGET_DIR"
mkdir -p "$TARGET_DIR"
log "✓ Created: $TARGET_DIR"

# User directory for VSCode settings
log "Creating User directory for VSCode settings..."
TARGET_DIR="$TARGET_HOME/User"
log "Target: $TARGET_DIR"
mkdir -p "$TARGET_DIR"
log "✓ Created: $TARGET_DIR"

log "✓ All directories created successfully"


# Copy configuration files
if [ "$REPO_AVAILABLE" = true ]; then
    log ""
    log "=== STEP 3: Copying Configuration Files ==="

    # Ensure target home directory exists
    if [ ! -d "$TARGET_HOME" ]; then
        log "Creating target home directory: $TARGET_HOME"
        mkdir -p "$TARGET_HOME"
    fi

    # Check if we can write to the target directory
    if [ ! -w "$TARGET_HOME" ]; then
        log "Warning: Cannot write to $TARGET_HOME"
        log "Error: No write access to $TARGET_HOME"
        exit 1
    fi

    log "Starting file copy operations..."
    log "Source base directory: $TEMP_DIR"

    # Copy Claude agents
    log ""
    log "Processing Claude agents..."
    SOURCE_DIR="$TEMP_DIR/.claude/agents"
    TARGET_DIR="$TARGET_HOME/.claude/agents"
    if [ -d "$SOURCE_DIR" ]; then
        log "Found agents directory at: $SOURCE_DIR"
        log "Listing agent files to copy:"
        for file in "$SOURCE_DIR"/*; do
            if [ -f "$file" ]; then
                filename=$(basename "$file")
                log "  - $filename"
                log_file_op "COPY" "$file" "$TARGET_DIR/$filename"
                cp "$file" "$TARGET_DIR/" 2>/dev/null || log "    Warning: Failed to copy $filename"
            fi
        done
        log "✓ Copied Claude agents"
    else
        log "No agents directory found at: $SOURCE_DIR"
    fi

    # Copy Claude commands
    log ""
    log "Processing Claude commands..."
    SOURCE_DIR="$TEMP_DIR/.claude/commands"
    TARGET_DIR="$TARGET_HOME/.claude/commands"
    if [ -d "$SOURCE_DIR" ]; then
        log "Found commands directory at: $SOURCE_DIR"
        log "Listing command files to copy:"
        for file in "$SOURCE_DIR"/*; do
            if [ -f "$file" ]; then
                filename=$(basename "$file")
                log "  - $filename"
                log_file_op "COPY" "$file" "$TARGET_DIR/$filename"
                cp "$file" "$TARGET_DIR/" 2>/dev/null || log "    Warning: Failed to copy $filename"
            fi
        done
        log "✓ Copied Claude commands"
    else
        log "No commands directory found at: $SOURCE_DIR"
    fi

    # Copy output-styles
    log ""
    log "Processing output-styles..."
    SOURCE_DIR="$TEMP_DIR/.claude/output-styles"
    TARGET_DIR="$TARGET_HOME/.claude/output-styles"
    if [ -d "$SOURCE_DIR" ]; then
        log "Found output-styles directory at: $SOURCE_DIR"
        log "Listing style files to copy:"
        for file in "$SOURCE_DIR"/*; do
            if [ -f "$file" ]; then
                filename=$(basename "$file")
                log "  - $filename"
                log_file_op "COPY" "$file" "$TARGET_DIR/$filename"
                cp "$file" "$TARGET_DIR/" 2>/dev/null || log "    Warning: Failed to copy $filename"
            fi
        done
        log "✓ Copied output-styles"
    else
        log "No output-styles directory found at: $SOURCE_DIR"
    fi

    # Copy Claude config files
    log ""
    log "Processing Claude configuration files..."

    # CLAUDE.md
    SOURCE_FILE="$TEMP_DIR/.claude/CLAUDE.md"
    TARGET_FILE="$TARGET_HOME/.claude/CLAUDE.md"
    if [ -f "$SOURCE_FILE" ]; then
        log_file_op "COPY" "$SOURCE_FILE" "$TARGET_FILE"
        cp "$SOURCE_FILE" "$TARGET_FILE"
        log "✓ Copied CLAUDE.md"
    else
        log "CLAUDE.md not found at: $SOURCE_FILE"
    fi

    # settings.json
    SOURCE_FILE="$TEMP_DIR/.claude/settings.json"
    TARGET_FILE="$TARGET_HOME/.claude/settings.json"
    if [ -f "$SOURCE_FILE" ]; then
        log_file_op "COPY" "$SOURCE_FILE" "$TARGET_FILE"
        cp "$SOURCE_FILE" "$TARGET_FILE"
        log "✓ Copied settings.json"
    else
        log "settings.json not found at: $SOURCE_FILE"
    fi

    # Copy templates
    log ""
    log "Processing Claude code templates..."
    SOURCE_FILE="$TEMP_DIR/claude-code-templates/session-scratchpad-template.md"
    TARGET_FILE="$TARGET_HOME/projects/claude-code-templates/session-scratchpad-template.md"
    if [ -f "$SOURCE_FILE" ]; then
        log_file_op "COPY" "$SOURCE_FILE" "$TARGET_FILE"
        cp "$SOURCE_FILE" "$TARGET_FILE"
        log "✓ Copied templates"
    else
        log "Template not found at: $SOURCE_FILE"
    fi

    # Copy VSCode keybindings
    log ""
    log "Processing VSCode keybindings..."
    SOURCE_FILE="$TEMP_DIR/.vscode/keybindings.json"
    TARGET_FILE="$TARGET_HOME/User/keybindings.json"
    if [ -f "$SOURCE_FILE" ]; then
        log_file_op "COPY" "$SOURCE_FILE" "$TARGET_FILE"
        cp "$SOURCE_FILE" "$TARGET_FILE"
        log "✓ Copied VSCode keybindings"
    else
        log "VSCode keybindings not found at: $SOURCE_FILE"
    fi

    # Copy Gemini files
    log ""
    log "Processing Gemini configuration..."
    if [ -d "$TEMP_DIR/.gemini" ]; then
        log "Found Gemini directory"

        # GEMINI.md
        SOURCE_FILE="$TEMP_DIR/.gemini/GEMINI.md"
        TARGET_FILE="$TARGET_HOME/.gemini/GEMINI.md"
        if [ -f "$SOURCE_FILE" ]; then
            log_file_op "COPY" "$SOURCE_FILE" "$TARGET_FILE"
            cp "$SOURCE_FILE" "$TARGET_FILE"
            log "✓ Copied GEMINI.md"
        else
            log "GEMINI.md not found at: $SOURCE_FILE"
        fi

        # git-commit.toml
        SOURCE_FILE="$TEMP_DIR/.gemini/commands/git-commit.toml"
        TARGET_FILE="$TARGET_HOME/.gemini/commands/git-commit.toml"
        if [ -f "$SOURCE_FILE" ]; then
            log_file_op "COPY" "$SOURCE_FILE" "$TARGET_FILE"
            cp "$SOURCE_FILE" "$TARGET_FILE"
            log "✓ Copied git-commit.toml"
        else
            log "git-commit.toml not found at: $SOURCE_FILE"
        fi

        log "✓ Copied Gemini config"
    else
        log "No Gemini directory found at: $TEMP_DIR/.gemini"
    fi

    log "File copy operations completed"
else
    log ""
    log "=== STEP 3: Skipping File Copy ==="
    log "Repository not available, skipping all file copy operations"
    log "Reason: Git clone failed or repository was not accessible"
fi

# Install utility packages
log ""
log "=== STEP 4: Installing Utility Packages ==="
log "Preparing package installation..."

# Essential packages only
PACKAGES=(
    "vim"
    "git"
    "curl"
    "wget"
    "jq"
    "ripgrep"
    "fd-find"
    "tree"
    "htop"
    "net-tools"
    "sed"
    "awk"
    "sort"
    "diff"
    "sdiff"
    "uniq"
    "grep"
    "egrep"
    "fgrep"
    "ack"
    "base64"
    "head"
    "tail"
    "unzip"
    "find"
    "locate"
    "which"
    "vmstat"
    "ip"
    "ifconfig"
    "nslookup"
    "netstat"
    "ss"
    "tcpdump"
    "nmap"
    "ping"
    "traceroute"
)

log "Total packages to check/install: ${#PACKAGES[@]}"
log "Package list: ${PACKAGES[*]}"

# Update package list
log ""
log "Updating APT package lists..."
log "Command: sudo apt-get update -qq"
sudo apt-get update -qq
log "✓ Package lists updated"

# Install packages
log ""
log "Starting package installation..."
INSTALLED_COUNT=0
SKIPPED_COUNT=0
FAILED_COUNT=0

for package in "${PACKAGES[@]}"; do
    log ""
    log "Processing package: $package"

    # Check if already installed
    if dpkg -l 2>/dev/null | grep -q "^ii  $package " || dpkg -l 2>/dev/null | grep -q "^ii  ${package//-/} "; then
        log "  Package $package is already installed - skipping"
        log "  ○ $package already installed"
        SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
    else
        log "  Package $package not found, attempting installation..."
        log "  Command: sudo apt-get install -y -qq $package"

        # Try to install the package with timeout
        if timeout 30 sudo apt-get install -y -qq "$package" 2>&1 | tail -n 5 >> "$LOG_FILE"; then
            log "  ✓ Successfully installed $package"
            log "  Installation completed for $package"
            INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
        else
            log "  ✗ Failed to install $package"
            log "  ERROR: Installation failed for $package"
            FAILED_COUNT=$((FAILED_COUNT + 1))
        fi
    fi
done

# Package installation summary
log ""
log "Package installation summary:"
log "  - New installations: $INSTALLED_COUNT"
log "  - Already installed: $SKIPPED_COUNT"
log "  - Failed installations: $FAILED_COUNT"
log "✓ Package installation phase completed"

# Install Python uv
log ""
log "=== STEP 4.5: Installing Python uv ==="
log "Installing Python's uv package manager..."

# Install uv using pip
log "Installing uv with pip..."
log "Command: pip install uv"
if pip install uv 2>&1 | while IFS= read -r line; do log "    UV: $line"; done; [ ${PIPESTATUS[0]} -eq 0 ]; then
    log "  ✓ Successfully installed uv"

    # Verify installation
    if command -v uv &> /dev/null; then
        UV_VERSION=$(uv --version 2>/dev/null | head -n1)
        log "  ✓ uv is available: $UV_VERSION"
    else
        log "  ⚠ uv installed but not found in PATH"
    fi
else
    log "  ✗ Failed to install uv"
fi

log "✓ Python uv installation phase completed"

# Install MCP servers
log ""
log "=== STEP 4.6: Installing MCP Servers ==="
log "Installing Claude MCP servers..."

# Refresh PATH and hash table to ensure newly installed commands are found
export PATH="/usr/local/bin:/usr/bin:/bin:$PATH"
hash -r  # Clear the command hash table

# Try to find claude with multiple methods
CLAUDE_FOUND=false
CLAUDE_CMD=""

# Method 1: Direct command check after PATH refresh
if command -v claude &> /dev/null; then
    CLAUDE_FOUND=true
    CLAUDE_CMD="claude"
    log "Claude CLI found via command -v: $(which claude)"
# Method 2: Check common npm global install locations
elif [ -x "/usr/bin/claude" ]; then
    CLAUDE_FOUND=true
    CLAUDE_CMD="/usr/bin/claude"
    log "Claude CLI found at /usr/bin/claude"
elif [ -x "/usr/local/bin/claude" ]; then
    CLAUDE_FOUND=true
    CLAUDE_CMD="/usr/local/bin/claude"
    log "Claude CLI found at /usr/local/bin/claude"
# Method 3: Check if the npm module exists and try to use it directly
elif [ -f "/usr/lib/node_modules/@anthropic-ai/claude-code/cli.js" ]; then
    CLAUDE_FOUND=true
    CLAUDE_CMD="node /usr/lib/node_modules/@anthropic-ai/claude-code/cli.js"
    log "Claude CLI found via node module at /usr/lib/node_modules/@anthropic-ai/claude-code/cli.js"
else
    # Last resort: wait a bit and try again
    log "Claude not immediately found, waiting 3 seconds for environment to settle..."
    sleep 3
    hash -r  # Clear the command hash table

    # Try one more time after wait
    if command -v claude &> /dev/null; then
        CLAUDE_FOUND=true
        CLAUDE_CMD="claude"
        log "Claude CLI found after wait: $(which claude)"
    elif [ -f "/usr/lib/node_modules/@anthropic-ai/claude-code/cli.js" ]; then
        CLAUDE_FOUND=true
        CLAUDE_CMD="node /usr/lib/node_modules/@anthropic-ai/claude-code/cli.js"
        log "Claude npm module found after wait"
    fi
fi

if [ "$CLAUDE_FOUND" = true ]; then
    log "Claude CLI detected, proceeding with MCP server installation"
    log "Using claude command: $CLAUDE_CMD"

    # Install context7 MCP server
    log "Installing context7 MCP server..."
    log "Command: $CLAUDE_CMD mcp add context7 -s user -- npx -y @upstash/context7-mcp"
    if $CLAUDE_CMD mcp add context7 -s user -- npx -y @upstash/context7-mcp 2>&1 | while IFS= read -r line; do log "    MCP: $line"; done; [ ${PIPESTATUS[0]} -eq 0 ]; then
        log "  ✓ Successfully installed context7 MCP server"
    else
        log "  ✗ Failed to install context7 MCP server"
    fi

    # Install fetch MCP server
    log "Installing fetch MCP server..."
    log "Command: $CLAUDE_CMD mcp add fetch -s user -- uvx mcp-server-fetch"
    if $CLAUDE_CMD mcp add fetch -s user -- uvx mcp-server-fetch 2>&1 | while IFS= read -r line; do log "    MCP: $line"; done; [ ${PIPESTATUS[0]} -eq 0 ]; then
        log "  ✓ Successfully installed fetch MCP server"
    else
        log "  ✗ Failed to install fetch MCP server"
    fi

    log "✓ MCP server installation phase completed"
else
    log "Claude CLI not found after all attempts"
    log "⚠ Claude CLI not available - MCP servers not installed"
    log "PATH checked: $PATH"
    log "Locations checked:"
    log "  - command -v claude"
    log "  - /usr/bin/claude"
    log "  - /usr/local/bin/claude"
    log "  - /usr/lib/node_modules/@anthropic-ai/claude-code/cli.js"
fi

# Clean up
log ""
log "=== STEP 5: Cleanup ==="
log "Starting cleanup operations..."

if [ -d "$TEMP_DIR" ]; then
    log "Found temporary directory: $TEMP_DIR"
    log "Calculating size before removal..."
    TEMP_SIZE=$(du -sh "$TEMP_DIR" 2>/dev/null | cut -f1)
    log "Size of temporary directory: $TEMP_SIZE"
    log "Removing temporary directory..."
    rm -rf "$TEMP_DIR"
    log "✓ Temporary directory removed"
else
    log "No temporary directory to clean up"
fi

log "Cleanup completed"

# Final summary
log ""
log "========================================"
log "🎉 SETUP COMPLETED SUCCESSFULLY! 🎉"
log "========================================"
log ""
log "Configuration Summary:"
log "  • Claude configuration: ~/.claude/"
log "    - Agents: ~/.claude/agents/"
log "    - Commands: ~/.claude/commands/"
log "    - Output styles: ~/.claude/output-styles/"
log "    - Settings: ~/.claude/settings.json"
log "    - Configuration: ~/.claude/CLAUDE.md"
log ""
log "  • Gemini configuration: ~/.gemini/"
log "    - Commands: ~/.gemini/commands/"
log "    - Configuration: ~/.gemini/GEMINI.md"
log ""
log "  • Project templates: ~/projects/claude-code-templates/"
log ""
log "  • VSCode settings: ~/User/"
log ""
log "  • MCP Servers:"
if [ "$CLAUDE_FOUND" = true ]; then
    log "    - context7 MCP server: Provides library documentation access"
    log "    - fetch MCP server: Enables web content fetching"
else
    log "    - MCP servers not installed (Claude CLI not available)"
fi
log ""
log "Statistics:"
log "  • Packages installed: $INSTALLED_COUNT"
log "  • Packages skipped: $SKIPPED_COUNT"
log "  • Packages failed: $FAILED_COUNT"
log ""
log "Log file saved at: $LOG_FILE"
log ""
log "Script execution completed at: $(date '+%Y-%m-%d %H:%M:%S')"
log "========================================"