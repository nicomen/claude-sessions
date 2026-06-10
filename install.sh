#!/usr/bin/env sh
set -e

REPO_URL="https://github.com/nicomen/saisons.git"
INSTALL_DIR=""
LIB_DIR="$HOME/.local/lib"

# Find a writable directory in PATH
for dir in "$HOME/.local/bin" "$HOME/bin" /usr/local/bin; do
    if [ -d "$dir" ] && [ -w "$dir" ]; then
        INSTALL_DIR="$dir"
        break
    fi
done

# Create ~/.local/bin if nothing else found
if [ -z "$INSTALL_DIR" ]; then
    INSTALL_DIR="$HOME/.local/bin"
    mkdir -p "$INSTALL_DIR"
    echo "Created $INSTALL_DIR — make sure it is in your PATH."
    echo "  Add this to your ~/.bashrc or ~/.zshrc:"
    echo '  export PATH="$HOME/.local/bin:$PATH"'
fi

# Check for Perl
if ! command -v perl >/dev/null 2>&1; then
    echo "Error: Perl is not installed."
    echo ""
    echo "Install it with your package manager:"
    echo "  Debian/Ubuntu:  sudo apt install perl"
    echo "  Fedora/RHEL:    sudo dnf install perl"
    echo "  macOS:          brew install perl   (or use the system Perl)"
    echo "  Arch:           sudo pacman -S perl"
    exit 1
fi

# Check for git
if ! command -v git >/dev/null 2>&1; then
    echo "Error: git is not installed."
    exit 1
fi

REPO_DIR="$HOME/.local/share/saisons"

# Clone or update repo
if [ -d "$REPO_DIR/.git" ]; then
    echo "Updating saisons..."
    git -C "$REPO_DIR" pull --ff-only
else
    echo "Installing saisons..."
    git clone --depth=1 "$REPO_URL" "$REPO_DIR"
fi

# Symlink the executable
ln -sf "$REPO_DIR/saisons" "$INSTALL_DIR/saisons"

# Symlink the lib
mkdir -p "$LIB_DIR"
ln -sf "$REPO_DIR/lib/Saisons"    "$LIB_DIR/Saisons"
ln -sf "$REPO_DIR/lib/Saisons.pm" "$LIB_DIR/Saisons.pm"

echo "Done. Run: saisons"
