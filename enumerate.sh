#!/bin/bash

#==============================#
#       Web Recon Script      #
#      by r4vindra (Color)    #
#==============================#

# Define Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m' # No Color

# Function to display saved file paths
print_saved() {
    echo -e "${CYAN}[*] Output saved to: ${GREEN}$1${NC}"
}

# Function to print a section header
section() {
    echo -e "\n${MAGENTA}==========[ $1 ]==========${NC}\n"
}

# Display Banner
figlet "r4vindra" | lolcat

# Output File Names
subdomains="subdomains.txt"
domaintakeover="domains-takeover.txt"
alivesubdomains="subdomains-alive.txt"
alivesubdomainsstatus="alive-subdomains-status-codes.txt"
katanaurls="katana-urls.txt"
waybackurls="wayback-urls.txt"
allurls="all-unique-urls.txt"

# Input
echo ""
read -p "$(echo -e ${CYAN}Enter a domain or path to a domain list:${NC} ) " domain
echo ""

# Subdomain Enumeration
section "Subdomain Enumeration"
if [ -f "$domain" ]; then
    echo -e "${YELLOW}[*] A file was detected. Enumerating subdomains from list...${NC}"
    subfinder -dL "$domain" > "$subdomains"
else
    echo -e "${YELLOW}[*] Enumerating subdomains for: $domain${NC}"
    subfinder -d "$domain" > "$subdomains"
fi
print_saved "$subdomains"

# Subdomain Takeover Check
section "Subdomain Takeover Detection"
echo "List of potentially vulnerable subdomains:" > "$domaintakeover"
echo "" >> "$domaintakeover"
subzy r --targets "$subdomains" | grep -i "HTTP ERROR" | cut -d "-" -f2 >> "$domaintakeover"
print_saved "$domaintakeover"

# Alive Subdomain Probing
section "Checking for Alive Subdomains"
httpx-toolkit -l "$subdomains" \
    -ports 443,80,8080,8000,8888,8088,8808 \
    -threads 200 > "$alivesubdomains"
print_saved "$alivesubdomains"

# Status Codes
section "Fetching HTTP Status Codes"
cat "$alivesubdomains" | httpx-toolkit -sc > "$alivesubdomainsstatus"
print_saved "$alivesubdomainsstatus"

# Katana Crawling
section "Crawling URLs using Katana"
ignored_exts="woff,css,png,svg,jpg,woff2,jpeg,gif,svg,bak,old,backup,orig,tmp,swp,save,config,conf,ini,yml,yaml,env,php,asp,aspx,jsp,py,rb,pl,js,ts,jsx,tsx,zip,tar,tar.gz,rar,7z,gz,bz2,sql,db,sqlite,sqlite3,mdb,accdb,log,txt,dump,dmp,stackdump,pem,key,crt,p12,pfx,cert,htpasswd,htaccess,ssh,id_rsa,pgpass,doc,docx,xls,xlsx,pdf,ppt,pptx,git,svn,hg,DS_Store,npmrc,babelrc,idea,vscode,project,classpath"

cat "$alivesubdomains" | katana -d 7 -ef "$ignored_exts" -o "$katanaurls" 2>/dev/null
print_saved "$katanaurls"

# Wayback URLs
section "Collecting URLs from Wayback Machine"
cat "$subdomains" | waybackurls > "$waybackurls" 2>/dev/null
print_saved "$waybackurls"

# Combine and Clean URLs
section "Combining & Deduplicating All URLs"
cat "$katanaurls" "$waybackurls" | sort -u > "$allurls"
print_saved "$allurls"

# Cleanup
section "Cleaning Temporary Files"
rm -f "$katanaurls" "$waybackurls"
echo -e "${GREEN}[*] Temporary files removed.${NC}"

# Done
section "Web Enumeration Completed"
echo -e "${BLUE}[*] Recon process is successfully completed. Review the output files above, Keep Hunting.......Happy Hacking:).${NC}"

