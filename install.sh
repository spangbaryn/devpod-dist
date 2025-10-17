#!/bin/bash
set -e

# DevPod Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/spangbaryn/devpod/main/install.sh | bash

REPO="spangbaryn/devpod-dist"
INSTALL_DIR="/usr/local/bin"
BINARY_NAME="devpod"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Error handling
error() {
  echo -e "${RED}Error: $1${NC}" >&2
  exit 1
}

success() {
  echo -e "${GREEN}$1${NC}"
}

info() {
  echo -e "${YELLOW}$1${NC}"
}

# Check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Detect platform
detect_platform() {
  OS="$(uname -s)"
  case "$OS" in
    Darwin)
      PLATFORM="macos"
      BINARY_NAME_PLATFORM="devpod-macos"
      ;;
    Linux)
      PLATFORM="linux"
      BINARY_NAME_PLATFORM="devpod-linux"
      ;;
    *)
      error "Unsupported platform: $OS. Supported platforms: macOS, Linux"
      ;;
  esac
  info "Detected platform: $PLATFORM"
}

# Check dependencies
check_dependencies() {
  if ! command_exists curl; then
    error "curl is required but not installed"
  fi

  if ! command_exists jq; then
    info "jq not found, using grep/sed for JSON parsing (less reliable)"
  fi
}

# Get latest release version
get_latest_version() {
  info "Fetching latest release..."

  RELEASE_URL="https://api.github.com/repos/$REPO/releases/latest"

  if command_exists jq; then
    VERSION=$(curl -fsSL "$RELEASE_URL" | jq -r '.tag_name')
  else
    # Fallback if jq not available
    VERSION=$(curl -fsSL "$RELEASE_URL" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
  fi

  if [ -z "$VERSION" ]; then
    error "Failed to fetch latest version"
  fi

  success "Latest version: $VERSION"
}

# Download binary
download_binary() {
  DOWNLOAD_URL="https://github.com/$REPO/releases/download/$VERSION/$BINARY_NAME_PLATFORM"
  TMP_FILE="/tmp/$BINARY_NAME"

  info "Downloading from $DOWNLOAD_URL..."

  if ! curl -fsSL -o "$TMP_FILE" "$DOWNLOAD_URL"; then
    error "Failed to download binary"
  fi

  # Verify download (check file size)
  if [ ! -s "$TMP_FILE" ]; then
    error "Downloaded file is empty"
  fi

  success "Download complete"
}

# Install binary
install_binary() {
  info "Installing to $INSTALL_DIR..."

  # Check if install directory is writable
  if [ ! -w "$INSTALL_DIR" ]; then
    info "Need sudo access to install to $INSTALL_DIR"
    if ! sudo mv "$TMP_FILE" "$INSTALL_DIR/$BINARY_NAME"; then
      error "Failed to install binary (permission denied)"
    fi
    if ! sudo chmod +x "$INSTALL_DIR/$BINARY_NAME"; then
      error "Failed to make binary executable"
    fi
  else
    if ! mv "$TMP_FILE" "$INSTALL_DIR/$BINARY_NAME"; then
      error "Failed to install binary"
    fi
    if ! chmod +x "$INSTALL_DIR/$BINARY_NAME"; then
      error "Failed to make binary executable"
    fi
  fi

  success "Installed successfully"
}

# Verify installation
verify_installation() {
  info "Verifying installation..."

  if ! command_exists devpod; then
    error "Installation failed - devpod command not found in PATH"
  fi

  INSTALLED_VERSION=$(devpod --version 2>&1 | grep -oE 'v?[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")

  success "DevPod $INSTALLED_VERSION installed successfully!"
  echo ""
  info "Run 'devpod --help' to get started"
}

# Cleanup on exit
cleanup() {
  if [ -f "$TMP_FILE" ]; then
    rm -f "$TMP_FILE"
  fi
}
trap cleanup EXIT

# Main installation flow
main() {
  echo "========================================"
  echo "  DevPod Installer"
  echo "========================================"
  echo ""

  detect_platform
  check_dependencies
  get_latest_version
  download_binary
  install_binary
  verify_installation
}

main
