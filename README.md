# 🔎 Basic Web Enumeration

A lightweight, beginner-friendly and powerful **Web Reconnaissance & Bug Hunting Automation Framework** for authorized security testing.

The goal of this project is to automate the repetitive reconnaissance tasks performed during web application penetration testing and bug bounty hunting.

It combines passive reconnaissance, DNS enumeration, subdomain discovery, permutation, HTTP probing, port scanning, crawling, JavaScript analysis, URL collection, content discovery and vulnerability-oriented filtering into a single workflow.

> ⚠️ **Disclaimer:** This tool is intended only for authorized security testing, bug bounty programs, CTFs and systems you own or have explicit permission to test.

---

## ✨ Features

- 🔍 Passive subdomain enumeration
- 🌐 DNS resolution and validation
- 🔀 Subdomain permutation
- 🏢 ASN / infrastructure reconnaissance
- 🔌 Port scanning
- 🚀 HTTP/HTTPS probing
- 🧰 Technology fingerprinting
- 🕰️ Web archive enumeration
- 🕷️ Web crawling
- 📜 JavaScript endpoint discovery
- 🔐 Secret/API-key discovery
- 📂 Directory and file discovery
- 🎯 URL parameter collection
- 🧪 Vulnerability-oriented URL filtering
- 🛡️ Nuclei vulnerability scanning
- 📊 Organized output directories
- 📚 Uses Kali Linux SecLists instead of repository-specific wordlists
- ⚡ Designed for repeated bug-hunting workflows

---

# 📁 Repository Structure

```text
Basic-Web-Enumeration/
│
├── recon.sh
├── install.sh
└── README.md

The project intentionally keeps the structure simple.

recon.sh contains the main reconnaissance workflow and does not require custom modules/, config/, or repository-specific wordlists.

Wordlists are taken from the SecLists installation available on Kali Linux.

💻 Requirements

Recommended environment:

Kali Linux
Bash
Internet connection
sudo privileges for installation
Go
Python 3

The script uses commonly available security-research tools such as:

Subfinder
Assetfinder
BBOT
Amass
Findomain
dnsx
httpx
Naabu
Nmap
Katana
Gospider
GAU
Waybackurls
FFUF
Gobuster / Dirsearch
Nuclei
GF
GetJS
Cariddi
Caduceus
GitHub Subdomains
Gotator
DNSGen
PureDNS
MapCIDR

The exact tools enabled depend on the implementation and availability on the system.

⚙️ Installation

Clone the repository:

git clone https://github.com/r4vindra/Basic-Web-Enumeration.git

Enter the directory:

cd Basic-Web-Enumeration

Make the scripts executable:

chmod +x recon.sh install.sh

Run the installer:

sudo ./install.sh

The installer prepares the required environment and installs the required dependencies/tools.

After installation, verify:

./recon.sh --help
📚 SecLists

This project uses SecLists for wordlists instead of storing large wordlists inside the repository.

On Kali Linux:

sudo apt install seclists

Common SecLists locations:

/usr/share/seclists/

Useful directories include:

/usr/share/seclists/Discovery/
/usr/share/seclists/Discovery/DNS/
/usr/share/seclists/Discovery/Web-Content/
/usr/share/seclists/Discovery/Infrastructure/
/usr/share/seclists/Fuzzing/

This keeps the repository lightweight while allowing the tool to use high-quality community wordlists.

🚀 Usage

Basic usage:

./recon.sh example.com

Show help:

./recon.sh -h

For a bug-bounty target, always make sure the domain is explicitly in scope before running active enumeration.

🔥 Recommended Workflow

The tool follows a layered reconnaissance methodology:

                    TARGET
                      │
                      ▼
              Passive Recon
                      │
                      ▼
          Subdomain Enumeration
                      │
                      ▼
          DNS Resolution / Validation
                      │
                      ▼
           Subdomain Permutation
                      │
                      ▼
             HTTP Probing
                      │
                      ▼
          Technology Fingerprinting
                      │
                      ▼
              Port Discovery
                      │
                      ▼
             URL Collection
                      │
             ┌────────┴────────┐
             ▼                 ▼
          Crawling          Archives
             │                 │
             └────────┬────────┘
                      ▼
             JavaScript Analysis
                      │
                      ▼
              Content Discovery
                      │
                      ▼
          Parameter / Endpoint Analysis
                      │
                      ▼
            Vulnerability Scanning
                      │
                      ▼
              Manual Validation
🔎 1. Passive Reconnaissance

The first stage attempts to discover assets without directly interacting heavily with the target.

Potential sources include:

Certificate Transparency
Search engines
DNS databases
Internet intelligence platforms
GitHub
Security databases
Web archives
Passive DNS
BBOT
Amass
Subfinder
Assetfinder
Findomain

Example:

subfinder -d example.com -all -silent

The objective is to build an initial asset inventory.

🌐 2. Subdomain Enumeration

Multiple enumeration sources are combined because no single tool discovers everything.

Typical tools:

subfinder
assetfinder
amass
findomain
BBOT
github-subdomains

Results are normalized and deduplicated:

sort -u
🔀 3. Subdomain Permutation

Existing subdomains can reveal naming patterns such as:

dev.example.com
stage.example.com
api.example.com
internal.example.com

Permutation tools can generate additional candidates:

dnsgen
gotator
ripgen
goaltdns

Candidates should then be resolved before further testing.

🌍 4. HTTP Probing

Discovered domains are checked for reachable HTTP services.

Typical information collected:

HTTP status
Title
Server
Technology
Redirect
URL
Port

Example:

httpx -l subdomains.txt -sc -title -td -server

This helps prioritize interesting targets.

🔌 5. Port Scanning

Web applications are not always hosted on:

80
443

Additional services may exist on ports such as:

3000
5000
7001
8000
8080
8081
8443
8888
9000

Naabu and Nmap can be used to identify exposed services.

Example:

naabu -list hosts.txt

Then fingerprint interesting services:

nmap -sV -sC target
🕰️ 6. Historical Reconnaissance

Historical URLs can expose:

Old endpoints
Deleted functionality
Legacy APIs
Backup files
Old parameters
Forgotten applications
Previous subdomains

Common sources:

Wayback Machine
GAU
Waybackurls
URLScan

Example:

gau example.com
🕷️ 7. Crawling

Modern applications can contain thousands of endpoints.

Crawlers help discover:

API endpoints
JavaScript files
Parameters
Forms
Hidden paths
Links
Sitemaps
Robots.txt

Common tools:

Katana
Gospider

Example:

katana -u https://example.com -jc -d 5
📜 8. JavaScript Recon

JavaScript files are extremely valuable during bug hunting.

They may reveal:

API endpoints
Internal paths
Environment names
Feature flags
Third-party integrations
Client-side routes
Potential secrets

Useful tools:

getJS
Cariddi

Always manually validate potential secrets before reporting them.

📂 9. Content Discovery

Content discovery searches for interesting files and directories.

Examples:

/admin
/api
/dev
/test
/backup
/config
/.git
/swagger
/api-docs

Tools:

ffuf
dirsearch
gobuster

SecLists provides suitable wordlists.

Example:

ffuf -u https://example.com/FUZZ \
-w /usr/share/seclists/Discovery/Web-Content/common.txt
🎯 10. Parameter & Endpoint Analysis

Collected URLs can be filtered based on interesting parameters.

Examples:

id=
url=
redirect=
next=
file=
path=
page=
cmd=
query=
search=
callback=

Potential testing categories include:

XSS
SQL Injection
SSRF
SSTI
LFI
RCE
Open Redirect
IDOR

Tools such as gf can help organize URLs for manual testing.

Example:

cat urls.txt | gf xss
🛡️ 11. Nuclei

Nuclei can be used for automated detection of known vulnerabilities and security misconfigurations.

Example:

nuclei -l targets.txt

For safer and more useful results, focus on relevant template categories rather than blindly running every template.

Automated findings should always be manually validated.

📊 Output

Recon results should be separated into logical categories.

Example:

results/
│
├── subdomains/
├── dns/
├── http/
├── ports/
├── technologies/
├── archives/
├── crawling/
├── javascript/
├── content/
├── parameters/
├── nuclei/
└── findings/

This makes large reconnaissance projects easier to analyze.

🧠 Bug Hunting Philosophy

The purpose of this tool is not simply to run hundreds of scanners.

The workflow is:

Discover
   ↓
Normalize
   ↓
Validate
   ↓
Expand
   ↓
Fingerprint
   ↓
Prioritize
   ↓
Analyze
   ↓
Manually Test
   ↓
Validate Finding

The most important step is still manual analysis.

Automation helps discover the attack surface; it does not replace security testing.

⭐ Recommended Recon Cycle

After discovering new assets, repeat the process:

Subdomain
   ↓
DNS
   ↓
HTTP
   ↓
Ports
   ↓
URLs
   ↓
Parameters
   ↓
JavaScript
   ↓
New endpoints
   ↓
New subdomains
   ↓
Repeat

Reconnaissance should be treated as an iterative process rather than a one-time scan.

🔐 Responsible Usage

Only use this project against:

Your own infrastructure
Authorized penetration-testing environments
CTF/lab environments
Bug bounty targets where the activity is explicitly permitted

Do not scan random internet infrastructure without authorization.

Always respect:

Scope
Rate limits
Program rules
Robots / exclusions where applicable
Legal requirements
🛠️ Troubleshooting

Check whether a tool exists:

command -v subfinder
command -v httpx
command -v naabu
command -v nuclei

Check SecLists:

ls /usr/share/seclists/

If SecLists is missing:

sudo apt update
sudo apt install seclists

Check Go:

go version

Check the script:

bash -n recon.sh

Run with debugging if necessary:

bash -x recon.sh example.com
🔄 Updating

Update the repository:

cd Basic-Web-Enumeration
git pull

Update Kali packages:

sudo apt update
sudo apt upgrade

Update Go-based tools according to their respective repositories.

📌 Example

For an authorized bug bounty target:

./recon.sh example.com

The framework performs reconnaissance and creates organized results that can then be reviewed manually.

A typical workflow after reconnaissance is:

Recon
 ↓
Review assets
 ↓
Identify interesting applications
 ↓
Review technologies
 ↓
Analyze endpoints
 ↓
Inspect parameters
 ↓
Analyze JavaScript
 ↓
Perform manual testing
 ↓
Validate vulnerabilities
 ↓
Report
🧰 Main Tools
Category	Tools
Subdomains	Subfinder, Assetfinder, Amass, Findomain, BBOT
Permutation	DNSGen, Gotator, Ripgen, Goaltdns
DNS	DNSX, PureDNS
HTTP	HTTPX
Ports	Naabu, Nmap
Crawling	Katana, Gospider
Archives	GAU, Waybackurls
Content	FFUF, Dirsearch, Gobuster
JavaScript	GetJS, Cariddi
Vulnerability Scan	Nuclei
Filtering	GF
Infrastructure	MapCIDR, ASN sources
Wordlists	SecLists
👨‍💻 Author

Ravindra Kumar Manjhi

GitHub:

https://github.com/r4vindra

Repository:

https://github.com/r4vindra/Basic-Web-Enumeration
