#!/bin/bash

#==============================#
#       Web Recon Script       #
#       by r4vindra            #
#==============================#

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m'

# Functions
print_saved() {
    echo -e "${CYAN}[*] Output saved to: ${GREEN}$1${NC}"
}

section() {
    echo -e "\n${MAGENTA}==========[ $1 ]==========${NC}\n"
}

# Check Dependencies
required_tools=(
    subfinder
    subzy
    httpx-toolkit
    katana
    waybackurls
    figlet
    lolcat
)

for tool in "${required_tools[@]}"; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo -e "${RED}[!] $tool is not installed.${NC}"
        exit 1
    fi
done

# Banner
figlet "r4vindra" | lolcat

# Create Output Directory
timestamp=$(date +%Y%m%d_%H%M%S)
output_dir="recon_$timestamp"

mkdir -p "$output_dir"

subdomains="$output_dir/subdomains.txt"
domaintakeover="$output_dir/domains-takeover.txt"
alivesubdomains="$output_dir/subdomains-alive.txt"
alivesubdomainsstatus="$output_dir/alive-subdomains-status-codes.txt"
katanaurls="$output_dir/katana-urls.txt"
waybackurlsfile="$output_dir/wayback-urls.txt"
allurls="$output_dir/all-unique-urls.txt"

# Input
echo
read -p "$(echo -e ${CYAN}Enter a domain or path to a domain list:${NC} ) " target
echo

# Validate File Input
if [[ "$target" == */* || "$target" == *.txt ]]; then
    if [[ ! -f "$target" ]]; then
        echo -e "${RED}[!] File not found: $target${NC}"
        exit 1
    fi
fi

# Subdomain Enumeration
section "Subdomain Enumeration"

if [[ -f "$target" ]]; then
    echo -e "${YELLOW}[*] Domain list detected. Running Subfinder...${NC}"
    subfinder -dL "$target" -silent > "$subdomains"
else
    echo -e "${YELLOW}[*] Enumerating subdomains for: $target${NC}"
    subfinder -d "$target" -silent > "$subdomains"
fi

print_saved "$subdomains"

# Subdomain Takeover Detection
section "Subdomain Takeover Detection"

echo "Potentially Vulnerable Subdomains" > "$domaintakeover"
echo "===============================" >> "$domaintakeover"
echo >> "$domaintakeover"

subzy run --targets "$subdomains" 2>/dev/null | \
grep -Ei "VULNERABLE|HTTP ERROR" >> "$domaintakeover"

print_saved "$domaintakeover"

# Alive Subdomains
section "Checking for Alive Subdomains"

httpx-toolkit \
-l "$subdomains" \
-silent \
-threads 200 \
-ports 80,443,8080,8000,8888,8088,8808 \
> "$alivesubdomains"

print_saved "$alivesubdomains"

# Status Codes
section "Fetching HTTP Status Codes"

httpx-toolkit \
-l "$alivesubdomains" \
-sc \
-silent \
> "$alivesubdomainsstatus"

print_saved "$alivesubdomainsstatus"

# Katana Crawling
section "Crawling URLs using Katana"

ignored_exts="woff,css,png,svg,jpg,woff2,jpeg,gif,bak,old,backup,orig,tmp,swp,save,config,conf,ini,yml,yaml,env,php,asp,aspx,jsp,py,rb,pl,js,ts,jsx,tsx,zip,tar,tar.gz,rar,7z,gz,bz2,sql,db,sqlite,sqlite3,mdb,accdb,log,txt,dump,dmp,pem,key,crt,p12,pfx,cert,htpasswd,htaccess,doc,docx,xls,xlsx,pdf,ppt,pptx"

katana \
-l "$alivesubdomains" \
-d 7 \
-ef "$ignored_exts" \
-o "$katanaurls" \
2>/dev/null

print_saved "$katanaurls"

# Wayback URLs
section "Collecting URLs from Wayback Machine"

waybackurls < "$subdomains" > "$waybackurlsfile" 2>/dev/null

print_saved "$waybackurlsfile"

# Combine URLs
section "Combining & Deduplicating URLs"

cat "$katanaurls" "$waybackurlsfile" | sort -u > "$allurls"

print_saved "$allurls"

# Cleanup
section "Cleaning Temporary Files"

rm -f "$katanaurls" "$waybackurlsfile"

echo -e "${GREEN}[*] Temporary files removed.${NC}"

# Completed
section "Web Enumeration Completed"

echo -e "${GREEN}[+] Recon completed successfully.${NC}"
echo -e "${CYAN}[+] Results directory: ${output_dir}${NC}"
echo -e "${BLUE}[+] Keep Hunting... Happy Hacking!${NC}"
