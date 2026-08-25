#!/usr/bin/env bash

# ============================================================
# Basic-Web-Enumeration
# Installation Script
#
# Author: r4vindra
# Version: 3.0
#
# Installs the tools required by recon.sh
#
# Supported:
#   Kali Linux
#   Debian
#   Ubuntu
#
# Usage:
#   chmod +x install.sh
#   sudo ./install.sh
# ============================================================

set -Eeuo pipefail

# ============================================================
# Configuration
# ============================================================

REPO_NAME="Basic-Web-Enumeration"
VERSION="3.0"

INSTALL_DIR="/usr/local/bin"
GO_BIN="${HOME}/go/bin"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ============================================================
# Colors
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'

# ============================================================
# Logging
# ============================================================

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
    echo -e "${MAGENTA}============================================================${NC}"
    echo -e "${WHITE}$1${NC}"
    echo -e "${MAGENTA}============================================================${NC}"
}

# ============================================================
# Banner
# ============================================================

banner() {

    clear 2>/dev/null || true

    echo -e "${CYAN}"

    if command -v figlet >/dev/null 2>&1; then
        figlet "r4vindra"
    else
        echo "r4vindra"
    fi

    echo -e "${NC}"

    echo -e "${WHITE}Basic Web Enumeration${NC}"
    echo -e "${GRAY}Installation & Dependency Manager v${VERSION}${NC}"
    echo
}

# ============================================================
# Root Check
# ============================================================

check_root() {

    if [[ $EUID -ne 0 ]]; then

        error "This installer must be run with sudo/root privileges."

        echo
        echo "Run:"
        echo
        echo "    sudo ./install.sh"
        echo

        exit 1
    fi
}

# ============================================================
# OS Detection
# ============================================================

detect_os() {

    section "01 — Operating System Detection"

    if [[ ! -f /etc/os-release ]]; then
        error "Unable to detect operating system."
        exit 1
    fi

    source /etc/os-release

    OS_ID="${ID:-unknown}"
    OS_NAME="${PRETTY_NAME:-unknown}"

    info "Operating System: $OS_NAME"

    case "$OS_ID" in

        kali|debian|ubuntu)
            success "Supported operating system detected."
            ;;

        *)
            warn "This OS is not officially tested."
            warn "The installer may still work if apt is available."
            ;;

    esac
}

# ============================================================
# Package Manager
# ============================================================

update_packages() {

    section "02 — Updating Package Repository"

    export DEBIAN_FRONTEND=noninteractive

    apt-get update -y

    success "Package repository updated."
}

# ============================================================
# System Packages
# ============================================================

install_system_packages() {

    section "03 — Installing System Dependencies"

    apt-get install -y \
        git \
        curl \
        wget \
        jq \
        unzip \
        zip \
        tar \
        gzip \
        make \
        gcc \
        build-essential \
        python3 \
        python3-pip \
        python3-venv \
        python3-dev \
        libpcap-dev \
        libssl-dev \
        openssl \
        dnsutils \
        whois \
        net-tools \
        ca-certificates \
        nmap \
        masscan \
        ffuf \
        dirsearch \
        figlet \
        parallel \
        ruby \
        ruby-dev \
        libffi-dev \
        libyaml-dev \
        pkg-config

    success "System dependencies installed."
}

# ============================================================
# Go Installation
# ============================================================

install_go() {

    section "04 — Go Environment"

    if command -v go >/dev/null 2>&1; then

        GO_VERSION="$(go version)"

        success "Go already installed:"
        echo "    $GO_VERSION"

    else

        info "Go is not installed."

        apt-get install -y golang-go

        if command -v go >/dev/null 2>&1; then
            success "Go installed successfully."
        else
            error "Go installation failed."
            exit 1
        fi

    fi
}

# ============================================================
# Configure Go PATH
# ============================================================

configure_go() {

    section "05 — Configuring Go PATH"

    GO_PATH_LINE='export PATH="$PATH:$HOME/go/bin"'

    USER_HOME="${SUDO_USER:+$(getent passwd "$SUDO_USER" | cut -d: -f6)}"

    if [[ -z "${USER_HOME:-}" ]]; then
        USER_HOME="$HOME"
    fi

    USER_BASHRC="$USER_HOME/.bashrc"

    if [[ ! -f "$USER_BASHRC" ]]; then
        touch "$USER_BASHRC"
        chown "${SUDO_USER:-root}:${SUDO_USER:-root}" "$USER_BASHRC" 2>/dev/null || true
    fi

    if ! grep -Fq 'export PATH="$PATH:$HOME/go/bin"' "$USER_BASHRC"; then

        echo
        echo "$GO_PATH_LINE" >> "$USER_BASHRC"

        success "Added Go binaries to PATH."

    else

        success "Go PATH already configured."

    fi

    export PATH="$PATH:$USER_HOME/go/bin"
}

# ============================================================
# Go Tool Installer
# ============================================================

install_go_tool() {

    local name="$1"
    local package="$2"

    if command -v "$name" >/dev/null 2>&1; then

        success "$name already installed."

        return 0
    fi

    info "Installing $name..."

    if sudo -u "${SUDO_USER:-root}" env \
        GOPATH="${USER_HOME:-/root}/go" \
        PATH="${PATH}:${USER_HOME:-/root}/go/bin" \
        go install -v "$package"; then

        local binary="${USER_HOME:-/root}/go/bin/$name"

        if [[ -f "$binary" ]]; then

            ln -sf "$binary" "$INSTALL_DIR/$name"

            success "$name installed."

        else

            warn "$name was installed but binary was not found."

        fi

    else

        warn "Failed to install $name."
    fi
}

# ============================================================
# ProjectDiscovery Tools
# ============================================================

install_projectdiscovery() {

    section "06 — ProjectDiscovery Tools"

    install_go_tool \
        "subfinder" \
        "github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"

    install_go_tool \
        "httpx" \
        "github.com/projectdiscovery/httpx/cmd/httpx@latest"

    install_go_tool \
        "naabu" \
        "github.com/projectdiscovery/naabu/v2/cmd/naabu@latest"

    install_go_tool \
        "katana" \
        "github.com/projectdiscovery/katana/cmd/katana@latest"

    install_go_tool \
        "dnsx" \
        "github.com/projectdiscovery/dnsx/cmd/dnsx@latest"

    install_go_tool \
        "mapcidr" \
        "github.com/projectdiscovery/mapcidr/cmd/mapcidr@latest"

    install_go_tool \
        "nuclei" \
        "github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
}

# ============================================================
# Other Go Tools
# ============================================================

install_other_go_tools() {

    section "07 — Additional Recon Tools"

    install_go_tool \
        "assetfinder" \
        "github.com/tomnomnom/assetfinder@latest"

    install_go_tool \
        "waybackurls" \
        "github.com/tomnomnom/waybackurls@latest"

    install_go_tool \
        "gau" \
        "github.com/lc/gau/v2/cmd/gau@latest"

    install_go_tool \
        "gospider" \
        "github.com/jaeles-project/gospider@latest"

    install_go_tool \
        "subzy" \
        "github.com/PentestPad/subzy@latest"

    install_go_tool \
        "gotator" \
        "github.com/Josue87/gotator@latest"

    install_go_tool \
        "anew" \
        "github.com/tomnomnom/anew@latest"

    install_go_tool \
        "dnsgen" \
        "github.com/ProjectAnte/dnsgen@latest"

    install_go_tool \
        "findomain" \
        "github.com/Findomain/Findomain@latest"
}

# ============================================================
# GF
# ============================================================

install_gf() {

    section "08 — GF Pattern Matching"

    install_go_tool \
        "gf" \
        "github.com/tomnomnom/gf@latest"

    GF_DIR="${USER_HOME:-/root}/.gf"

    if [[ ! -d "$GF_DIR" ]]; then

        mkdir -p "$GF_DIR"

    fi

    if [[ ! -d "$GF_DIR/examples" ]]; then

        info "Installing standard GF patterns..."

        sudo -u "${SUDO_USER:-root}" git clone \
            https://github.com/1ndianl33t/Gf-Patterns.git \
            "$GF_DIR/examples" \
            2>/dev/null || true

    fi

    success "GF configuration completed."
}

# ============================================================
# Github Subdomains
# ============================================================

install_github_subdomains() {

    section "09 — GitHub Subdomain Enumeration"

    install_go_tool \
        "github-subdomains" \
        "github.com/gwen001/github-subdomains@latest"

    success "github-subdomains installed."

    warn "A GitHub token is recommended for better results."

    echo
    echo "Create a token from GitHub and configure it when using:"
    echo
    echo "    github-subdomains -d example.com -t YOUR_TOKEN"
}

# ============================================================
# BBOT
# ============================================================

install_bbot() {

    section "10 — BBOT"

    if command -v bbot >/dev/null 2>&1; then

        success "BBOT already installed."

        return
    fi

    info "Installing BBOT using pipx..."

    if ! command -v pipx >/dev/null 2>&1; then

        apt-get install -y pipx

        python3 -m pipx ensurepath 2>/dev/null || true

    fi

    if command -v pipx >/dev/null 2>&1; then

        sudo -u "${SUDO_USER:-root}" \
            pipx install bbot \
            || warn "BBOT installation failed."

    else

        warn "pipx unavailable. Skipping BBOT."

    fi
}

# ============================================================
# TheTimeMachine
# ============================================================

install_timemachine() {

    section "11 — TheTimeMachine"

    TTM_DIR="${USER_HOME:-/root}/tools/TheTimeMachine"

    if [[ -d "$TTM_DIR" ]]; then

        success "TheTimeMachine already exists."

        return

    fi

    mkdir -p "$(dirname "$TTM_DIR")"

    sudo -u "${SUDO_USER:-root}" \
        git clone \
        https://github.com/anmolksachan/TheTimeMachine.git \
        "$TTM_DIR" \
        || warn "Unable to clone TheTimeMachine."

    if [[ -f "$TTM_DIR/requirements.txt" ]]; then

        sudo -u "${SUDO_USER:-root}" \
            python3 -m pip install \
            --user \
            -r "$TTM_DIR/requirements.txt" \
            2>/dev/null \
            || warn "Some TheTimeMachine Python dependencies could not be installed."

    fi

    success "TheTimeMachine setup completed."
}

# ============================================================
# Caduceus
# ============================================================

install_caduceus() {

    section "12 — Caduceus"

    # Repository/project may change over time.
    # Installation is intentionally optional.

    if command -v caduceus >/dev/null 2>&1; then

        success "Caduceus already installed."

        return
    fi

    warn "Caduceus is an optional component."
    warn "Install it separately if the upstream installation method"
    warn "has changed for your environment."

    echo
    echo "Repository:"
    echo "https://github.com/g0ldencybersec/Caduceus"
}

# ============================================================
# SecLists
# ============================================================

install_wordlists() {

    section "13 — Wordlists"

    WORDLIST_DIR="${USER_HOME:-/root}/wordlists"

    mkdir -p "$WORDLIST_DIR"

    if [[ -d "$WORDLIST_DIR/SecLists" ]]; then

        success "SecLists already installed."

    else

        info "Installing SecLists..."

        sudo -u "${SUDO_USER:-root}" \
            git clone \
            https://github.com/danielmiessler/SecLists.git \
            "$WORDLIST_DIR/SecLists" \
            || warn "Unable to clone SecLists."

    fi
}

# ============================================================
# Nuclei Templates
# ============================================================

update_nuclei_templates() {

    section "14 — Nuclei Templates"

    if ! command -v nuclei >/dev/null 2>&1; then

        warn "Nuclei is not available."

        return
    fi

    local nuclei_user="${SUDO_USER:-root}"

    sudo -u "$nuclei_user" \
        nuclei -update-templates \
        || warn "Unable to update Nuclei templates."

    success "Nuclei templates updated."
}

# ============================================================
# Repository Structure
# ============================================================

create_structure() {

    section "15 — Repository Structure"

    mkdir -p \
        "$SCRIPT_DIR/config" \
        "$SCRIPT_DIR/modules" \
        "$SCRIPT_DIR/wordlists"

    touch \
        "$SCRIPT_DIR/config/tools.conf" \
        "$SCRIPT_DIR/config/ports.conf" \
        "$SCRIPT_DIR/config/exclusions.txt"

    touch \
        "$SCRIPT_DIR/wordlists/permutations.txt" \
        "$SCRIPT_DIR/wordlists/web-short.txt" \
        "$SCRIPT_DIR/wordlists/parameters.txt"

    chmod +x "$SCRIPT_DIR/recon.sh"

    success "Repository structure prepared."
}

# ============================================================
# Tool Verification
# ============================================================

verify_tool() {

    local tool="$1"

    if command -v "$tool" >/dev/null 2>&1; then

        printf "${GREEN}[OK]${NC} %-22s %s\n" \
            "$tool" \
            "$(command -v "$tool")"

        return 0

    else

        printf "${RED}[MISSING]${NC} %-22s\n" \
            "$tool"

        return 1
    fi
}

verify_tools() {

    section "16 — Tool Verification"

    local tools=(
        curl
        jq
        git
        nmap
        masscan
        ffuf
        dirsearch
        subfinder
        assetfinder
        findomain
        amass
        httpx
        dnsx
        naabu
        katana
        nuclei
        mapcidr
        gau
        waybackurls
        gospider
        gotator
        dnsgen
        subzy
        anew
        gf
        github-subdomains
        bbot
    )

    local installed=0
    local missing=0

    echo

    for tool in "${tools[@]}"; do

        if verify_tool "$tool"; then
            ((installed+=1))
        else
            ((missing+=1))
        fi

    done

    echo
    echo -e "${WHITE}Installed : ${GREEN}${installed}${NC}"
    echo -e "${WHITE}Missing   : ${RED}${missing}${NC}"

}

# ============================================================
# Completion
# ============================================================

completion() {

    section "17 — Installation Complete"

    echo
    echo -e "${GREEN}Basic-Web-Enumeration is ready.${NC}"
    echo

    echo -e "${WHITE}Run a standard scan:${NC}"
    echo
    echo "    ./recon.sh -d example.com"
    echo

    echo -e "${WHITE}Passive reconnaissance:${NC}"
    echo
    echo "    ./recon.sh -d example.com --passive"
    echo

    echo -e "${WHITE}Full reconnaissance:${NC}"
    echo
    echo "    ./recon.sh -d example.com --full"
    echo

    echo -e "${YELLOW}IMPORTANT:${NC}"
    echo
    echo "Only scan systems that you are authorized to test."
    echo
}

# ============================================================
# Main
# ============================================================

main() {

    banner

    check_root

    detect_os

    update_packages

    install_system_packages

    install_go

    configure_go

    install_projectdiscovery

    install_other_go_tools

    install_gf

    install_github_subdomains

    install_bbot

    install_timemachine

    install_caduceus

    install_wordlists

    update_nuclei_templates

    create_structure

    verify_tools

    completion
}

main "$@"
