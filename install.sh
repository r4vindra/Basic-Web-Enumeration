#!/usr/bin/env bash

# ============================================================
# Basic-Web-Enumeration
# Installer
#
# Author  : r4vindra
# Version : 4.0
# ============================================================

set -Eeuo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[+]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

error() {
    echo -e "${RED}[-]${NC} $1"
}

section() {
    echo
    echo -e "${CYAN}============================================================${NC}"
    echo -e "${WHITE}$1${NC}"
    echo -e "${CYAN}============================================================${NC}"
}

if [[ $EUID -ne 0 ]]; then
    error "Run this installer with sudo."
    echo
    echo "Usage:"
    echo "    sudo ./install.sh"
    exit 1
fi

if [[ ! -f /etc/os-release ]]; then
    error "Unable to identify operating system."
    exit 1
fi

source /etc/os-release

if [[ "${ID:-}" != "kali" ]]; then
    warn "This installer is primarily designed for Kali Linux."
    warn "Detected: ${PRETTY_NAME:-Unknown}"
fi

section "Basic-Web-Enumeration v4.0"

info "Updating package database..."

apt-get update -y

section "Installing System Dependencies"

apt-get install -y \
    git \
    curl \
    wget \
    jq \
    unzip \
    ca-certificates \
    dnsutils \
    whois \
    nmap \
    masscan \
    ffuf \
    dirsearch \
    parallel \
    seclists \
    golang-go \
    python3 \
    python3-pip \
    python3-venv \
    pipx

success "System dependencies installed."

section "Configuring Go"

USER_NAME="${SUDO_USER:-root}"

USER_HOME="$(getent passwd "$USER_NAME" | cut -d: -f6)"

if [[ -z "$USER_HOME" ]]; then
    USER_HOME="/root"
fi

GO_BIN="$USER_HOME/go/bin"

mkdir -p "$GO_BIN"

if ! grep -q 'HOME/go/bin' "$USER_HOME/.bashrc" 2>/dev/null; then

    echo 'export PATH="$PATH:$HOME/go/bin"' >> "$USER_HOME/.bashrc"

fi

export PATH="$PATH:$GO_BIN"

section "Installing Go Recon Tools"

install_go_tool() {

    local name="$1"
    local package="$2"

    if command -v "$name" >/dev/null 2>&1; then
        success "$name already installed."
        return 0
    fi

    info "Installing $name..."

    if sudo -u "$USER_NAME" \
        env GOPATH="$USER_HOME/go" \
        PATH="$PATH:$USER_HOME/go/bin" \
        go install "$package"; then

        if [[ -f "$USER_HOME/go/bin/$name" ]]; then

            ln -sf "$USER_HOME/go/bin/$name" \
                "/usr/local/bin/$name"

            success "$name installed."

        else

            warn "$name binary was not found."

        fi

    else

        warn "Unable to install $name."

    fi
}

install_go_tool \
    subfinder \
    github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

install_go_tool \
    httpx \
    github.com/projectdiscovery/httpx/cmd/httpx@latest

install_go_tool \
    dnsx \
    github.com/projectdiscovery/dnsx/cmd/dnsx@latest

install_go_tool \
    naabu \
    github.com/projectdiscovery/naabu/v2/cmd/naabu@latest

install_go_tool \
    katana \
    github.com/projectdiscovery/katana/cmd/katana@latest

install_go_tool \
    nuclei \
    github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest

install_go_tool \
    assetfinder \
    github.com/tomnomnom/assetfinder@latest

install_go_tool \
    amass \
    github.com/owasp-amass/amass/v4/...@master

install_go_tool \
    gau \
    github.com/lc/gau/v2/cmd/gau@latest

install_go_tool \
    waybackurls \
    github.com/tomnomnom/waybackurls@latest

install_go_tool \
    gospider \
    github.com/jaeles-project/gospider@latest

install_go_tool \
    gotator \
    github.com/Josue87/gotator@latest

install_go_tool \
    dnsgen \
    github.com/ProjectAnte/dnsgen@latest

install_go_tool \
    subzy \
    github.com/PentestPad/subzy@latest

install_go_tool \
    anew \
    github.com/tomnomnom/anew@latest

install_go_tool \
    gf \
    github.com/tomnomnom/gf@latest

install_go_tool \
    github-subdomains \
    github.com/gwen001/github-subdomains@latest

section "Installing BBOT"

if command -v bbot >/dev/null 2>&1; then

    success "BBOT already installed."

else

    if command -v pipx >/dev/null 2>&1; then

        sudo -u "$USER_NAME" \
            pipx install bbot \
            || warn "BBOT installation failed."

    else

        warn "pipx unavailable. BBOT skipped."

    fi

fi

section "Installing GF Patterns"

GF_DIR="$USER_HOME/.gf"

mkdir -p "$GF_DIR"

if [[ ! -d "$GF_DIR/examples" ]]; then

    sudo -u "$USER_NAME" \
        git clone \
        https://github.com/1ndianl33t/Gf-Patterns.git \
        "$GF_DIR/examples" \
        2>/dev/null || true

fi

section "Nuclei Templates"

if command -v nuclei >/dev/null 2>&1; then

    sudo -u "$USER_NAME" \
        nuclei -update-templates \
        || warn "Unable to update Nuclei templates."

fi

section "SecLists"

if [[ -d /usr/share/seclists ]]; then

    success "SecLists available at:"
    echo
    echo "    /usr/share/seclists"

elif [[ -d /usr/share/SecLists ]]; then

    success "SecLists available at:"
    echo
    echo "    /usr/share/SecLists"

else

    error "SecLists installation could not be located."
    exit 1

fi

section "Preparing Script"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

chmod +x "$SCRIPT_DIR/recon.sh"

success "recon.sh is executable."

section "Installation Complete"

echo
echo -e "${GREEN}Basic-Web-Enumeration v4.0 is ready.${NC}"
echo
echo "Examples:"
echo
echo "  ./recon.sh -d example.com"
echo
echo "  ./recon.sh -d example.com --passive"
echo
echo "  ./recon.sh -d example.com --full"
echo
echo "  ./recon.sh -l targets.txt --full"
echo
echo "SecLists:"
echo
echo "  /usr/share/seclists"
echo
echo -e "${YELLOW}Only scan systems you are authorized to test.${NC}"
echo
