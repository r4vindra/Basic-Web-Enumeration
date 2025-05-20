#!/bin/bash

#=============================================#
#        Recon Tool Installer Script          #
#           by r4vindra (Colorized)           #
#=============================================#

# Define Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
RED='\033[0;31m'
MAGENTA='\033[1;35m'
NC='\033[0m' # No Color

# Function to display a section
section() {
    echo -e "\n${MAGENTA}==========[ $1 ]==========${NC}\n"
}

# Function to check and install a Go-based tool
check_and_install() {
    local tool_name=$1
    local go_path=$2
    local symlink_path=$3

    if [ -f "$go_path" ]; then
        echo -e "${GREEN}✔ $tool_name is already installed.${NC}"
    else
        echo -e "${YELLOW}➜ $tool_name is not installed. Installing...${NC}"
        go install "$4"
        sudo ln -sf "$go_path" "$symlink_path"
        echo -e "${GREEN}✔ $tool_name has been successfully installed.${NC}"
    fi
}

# Start Update & Basic Dependencies
section "System Update & Installing Dependencies"
sudo apt update
sudo apt install golang-go subfinder httpx-toolkit -y

# Export Go bin path
export PATH=~/go/bin:$PATH

# Check and Install Tools
section "Installing Recon Tools"

check_and_install "Katana" \
    "$HOME/go/bin/katana" \
    "/usr/bin/katana" \
    "github.com/projectdiscovery/katana/cmd/katana@latest"

check_and_install "Subzy" \
    "$HOME/go/bin/subzy" \
    "/usr/bin/subzy" \
    "github.com/PentestPad/subzy@latest"

check_and_install "WaybackURLs" \
    "$HOME/go/bin/waybackurls" \
    "/usr/bin/waybackurls" \
    "github.com/tomnomnom/waybackurls@latest"

check_and_install "Naabu" \
    "$HOME/go/bin/naabu" \
    "/usr/bin/naabu" \
    "github.com/projectdiscovery/naabu/v2/cmd/naabu@latest"

# Final Message
section "Installation Complete"
echo -e "${CYAN}All required tools are installed and ready to use!${NC}"
echo -e "${GREEN}You can now run: ./enumeration.sh${NC}"

