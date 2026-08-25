# 🔎 Basic Web Enumeration

A lightweight, beginner-friendly and powerful **Web Reconnaissance & Bug Hunting Automation Framework** for authorized security testing.

The goal of this project is to automate repetitive reconnaissance tasks performed during web application penetration testing and bug bounty hunting.

It combines passive reconnaissance, DNS enumeration, subdomain discovery, permutation, HTTP probing, port scanning, crawling, JavaScript analysis, URL collection, content discovery, and vulnerability-oriented filtering into a single workflow.

> ⚠️ **Disclaimer:** This tool is intended only for authorized security testing, bug bounty programs, CTFs, and systems you own or have explicit permission to test.

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
- 🎯 URL and parameter collection
- 🧪 Vulnerability-oriented URL filtering
- 🛡️ Nuclei vulnerability scanning
- 📊 Organized output
- 📚 Uses Kali Linux SecLists
- ⚡ Designed for repeated bug-hunting workflows
- 🧩 Multiple reconnaissance techniques in one script
- 🔁 Iterative attack-surface discovery

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
sudo privileges
Python 3
Go

The project uses common security-research tools such as:

Subfinder
Assetfinder
BBOT
Amass
Findomain
DNSX
HTTPX
Naabu
Nmap
Katana
Gospider
GAU
Waybackurls
FFUF
Gobuster
Dirsearch
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

The exact tools enabled depend on the implementation and whether they are available on the system.

⚙️ Installation

Clone the repository:

git clone https://github.com/r4vindra/Basic-Web-Enumeration.git

Enter the directory:

cd Basic-Web-Enumeration

Make the scripts executable:

chmod +x recon.sh install.sh

Run the installer:

sudo ./install.sh

The installer prepares the environment and installs the required dependencies/tools.

After installation, verify the script:

./recon.sh --help
📚 SecLists

This project uses SecLists instead of storing large wordlists inside the repository.

Install SecLists on Kali Linux:

sudo apt update
sudo apt install seclists

The default location is:

/usr/share/seclists/

Useful directories include:

/usr/share/seclists/Discovery/
/usr/share/seclists/Discovery/DNS/
/usr/share/seclists/Discovery/Web-Content/
/usr/share/seclists/Discovery/Infrastructure/
/usr/share/seclists/Fuzzing/

This approach keeps the repository lightweight while allowing the framework to use high-quality community-maintained wordlists.

🚀 Usage

Basic usage:

./recon.sh example.com

Display help:

./recon.sh -h

or:

./recon.sh --help

Before running active reconnaissance, make sure the target is explicitly authorized and within scope.

🎯 Target Types

The framework is designed to work with web reconnaissance targets such as:

example.com
sub.example.com

Depending on the implementation, input can also be adapted for lists of domains or hosts.

For example:

targets.txt
example.com
example.org
example.net

Always verify that every target is authorized before scanning.

🔥 Reconnaissance Workflow

The framework follows a layered reconnaissance methodology:

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

The purpose is to gradually expand and understand the target's attack surface instead of relying on a single scanner.

🔎 1. Passive Reconnaissance

The first stage attempts to identify assets using passive or low-impact sources.

Potential sources include:

Certificate Transparency
Search Engines
DNS databases
Security databases
GitHub
Web Archives
URLScan
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

Multiple enumeration sources are combined because no single tool can discover every asset.

Common tools:

Subfinder
Assetfinder
Amass
Findomain
BBOT
GitHub Subdomains

Example:

subfinder -d example.com -all -recursive -silent

Assetfinder:

assetfinder --subs-only example.com

Amass:

amass enum -passive -d example.com

The discovered domains are then normalized and deduplicated:

sort -u
🔀 3. Subdomain Permutation

Existing subdomains often reveal naming conventions.

For example:

dev.example.com
stage.example.com
api.example.com
uat.example.com
test.example.com

These naming patterns can be used to discover additional potential assets.

Common permutation tools:

DNSGen
Gotator
Ripgen
Goaltdns
PureDNS

The generated candidates should be resolved before further testing.

Example:

cat subdomains.txt | dnsgen -
🌍 4. HTTP Probing

Discovered domains are checked for reachable HTTP/HTTPS services.

Useful information includes:

HTTP Status Code
Page Title
Server
Technology
Redirect
URL
Port

Example:

httpx -l subdomains.txt -sc -title -td -server -location

This helps identify interesting applications and prioritize targets.

🔌 5. Port Scanning

Web applications are not necessarily limited to:

80
443

Additional applications may be exposed on ports such as:

3000
5000
7000
7001
8000
8001
8080
8081
8088
8443
8888
9000
9001
10000

Naabu can be used for fast port discovery:

naabu -list hosts.txt

Nmap can then be used for service identification:

nmap -sV -sC target

Port discovery can reveal:

Development servers
Admin interfaces
APIs
Monitoring applications
Databases
CI/CD services
Management interfaces
Internal applications
🏢 6. ASN / Infrastructure Reconnaissance

Organizations may own multiple IP ranges and networks.

ASN reconnaissance can help identify additional infrastructure that may not appear through normal subdomain enumeration.

Useful resources include:

BGP.he.net
Censys
Shodan
SecurityTrails

The general workflow is:

Organization
     ↓
ASN
     ↓
CIDR ranges
     ↓
IP addresses
     ↓
Open ports
     ↓
HTTP services
     ↓
Additional attack surface

For example, an ASN may contain infrastructure hosting applications that are not directly linked from the primary domain.

Only scan infrastructure that is explicitly within your authorized scope.

🕰️ 7. Historical Reconnaissance

Historical URLs can expose old application functionality.

Useful sources:

Wayback Machine
GAU
Waybackurls
URLScan
AlienVault
Censys

Historical data can reveal:

Old endpoints
Legacy APIs
Deleted functionality
Old parameters
Backup files
Old subdomains
Development applications
Deprecated APIs

Example:

gau example.com
🕷️ 8. Web Crawling

Modern applications can contain thousands of endpoints.

Crawling helps discover:

API endpoints
JavaScript files
Parameters
Forms
Hidden paths
Links
Sitemaps
Robots.txt
Client-side routes

Common tools:

Katana
Gospider

Example:

katana -u https://example.com -jc -d 5

Gospider:

gospider -s https://example.com
📜 9. JavaScript Reconnaissance

JavaScript files are extremely valuable during bug hunting.

They can contain references to:

API endpoints
Internal routes
Environment names
Feature flags
Third-party integrations
Hidden functionality
Client-side parameters
Potential secrets

Useful tools:

GetJS
Cariddi
Katana

Example:

getJS --input urls.txt --complete --resolve

JavaScript analysis should always distinguish between:

Public configuration
Non-sensitive identifiers
API endpoints
Actual secrets

Potential secrets must be manually validated before reporting.

📂 10. Content Discovery

Content discovery attempts to identify directories and files that are not directly linked from the application.

Potential targets include:

/admin
/api
/dev
/test
/backup
/config
/.git
/swagger
/api-docs
/old
/internal

Tools:

FFUF
Dirsearch
Gobuster

Example:

ffuf \
-u https://example.com/FUZZ \
-w /usr/share/seclists/Discovery/Web-Content/common.txt

HTTP status codes should be interpreted carefully because applications can return custom responses for nonexistent paths.

🎯 11. URL & Parameter Analysis

Collected URLs can be categorized based on interesting parameters.

Common parameter names include:

id=
url=
uri=
redirect=
next=
return=
file=
path=
page=
cmd=
query=
search=
callback=
template=

Potential testing categories include:

XSS
SQL Injection
SSRF
SSTI
LFI
RCE
Open Redirect
IDOR
XXE
Path Traversal

GF can help organize URLs into testing categories.

Example:

cat urls.txt | gf xss

Other useful patterns may include:

cat urls.txt | gf sqli
cat urls.txt | gf ssrf
cat urls.txt | gf lfi
cat urls.txt | gf rce
cat urls.txt | gf ssti

These results are candidates for manual validation, not confirmed vulnerabilities.

🔐 12. Secret Discovery

Potential secrets may sometimes be exposed through:

JavaScript
Git repositories
Source maps
Archives
Configuration files
Public repositories
Historical URLs
Error messages

Potential findings include:

API keys
Cloud credentials
Tokens
Private keys
Passwords
Database credentials
Webhook secrets

Automated secret detection should always be followed by validation and responsible handling.

Do not use discovered credentials against systems unless that activity is explicitly authorized.

🧪 13. Vulnerability Scanning

Nuclei can be used to identify known vulnerabilities and security misconfigurations.

Example:

nuclei -l targets.txt

Useful categories include:

CVE detection
Misconfiguration
Exposed panels
Default credentials
Information disclosure
Known technologies
Security headers
Takeover indicators

Automated results should always be manually validated before being considered a vulnerability.

🧠 14. Finding Interesting Assets

During reconnaissance, prioritize assets such as:

dev.example.com
stage.example.com
test.example.com
uat.example.com
internal.example.com
admin.example.com
api.example.com
vpn.example.com
portal.example.com
old.example.com

Also prioritize applications exposing:

Login panels
API documentation
Swagger
GraphQL
Admin interfaces
Debug interfaces
File upload functionality
Development environments
Monitoring dashboards
CI/CD systems
Cloud storage

These often provide valuable areas for manual testing.

🔁 15. Iterative Reconnaissance

Recon should not be considered a one-time process.

A new discovery can lead to another discovery.

Example:

Subdomain
   ↓
New application
   ↓
JavaScript
   ↓
Hidden API
   ↓
New hostname
   ↓
DNS
   ↓
New IP
   ↓
New port
   ↓
New application
   ↓
New endpoints

Therefore, repeatedly feed new discoveries back into the reconnaissance process.

📊 Recommended Output Organization

A professional reconnaissance project should keep results separated by category.

Example:

results/
│
├── subdomains/
│
├── dns/
│
├── http/
│
├── ports/
│
├── technologies/
│
├── archives/
│
├── crawling/
│
├── javascript/
│
├── content/
│
├── parameters/
│
├── nuclei/
│
└── findings/

This makes large engagements easier to manage and analyze.

🧪 Manual Testing Comes After Recon

Automation is primarily used to answer:

What assets exist?
What is alive?
What technologies are running?
What endpoints exist?
What parameters exist?
What historical functionality exists?
What services are exposed?

Manual testing then answers:

Can this functionality be abused?
Is authentication enforced?
Is authorization enforced?
Can data belonging to another user be accessed?
Can input reach a dangerous sink?
Can security controls be bypassed?
Can vulnerabilities be chained?

The goal is to use automation for discovery and human analysis for validation and exploitation.

🛠️ Troubleshooting

Check whether a tool is installed:

command -v subfinder
command -v httpx
command -v naabu
command -v nuclei

Check SecLists:

ls /usr/share/seclists/

Install SecLists:

sudo apt update
sudo apt install seclists

Check Go:

go version

Check Python:

python3 --version

Validate the Bash script:

bash -n recon.sh

Run with debugging:

bash -x recon.sh example.com
🔄 Updating

Update the repository:

cd Basic-Web-Enumeration
git pull

Update Kali packages:

sudo apt update
sudo apt upgrade

Update individual Go-based security tools using their official installation/update mechanisms.

🧰 Main Tools
Category	Tools
Passive Recon	BBOT, Amass, Subfinder
Subdomains	Subfinder, Assetfinder, Amass, Findomain
Permutation	DNSGen, Gotator, Ripgen, Goaltdns
DNS	DNSX, PureDNS
HTTP	HTTPX
Ports	Naabu, Nmap
Crawling	Katana, Gospider
Archives	GAU, Waybackurls
Content	FFUF, Dirsearch, Gobuster
JavaScript	GetJS, Cariddi
Vulnerability Scanning	Nuclei
URL Filtering	GF
Infrastructure	MapCIDR
Wordlists	SecLists
External Recon	Censys, Shodan, SecurityTrails, URLScan
📌 Example Workflow

For an authorized bug-bounty target:

./recon.sh example.com

Then review the generated results:

Subdomains
     ↓
Alive hosts
     ↓
Technologies
     ↓
Open ports
     ↓
Historical URLs
     ↓
Crawled URLs
     ↓
JavaScript
     ↓
Parameters
Bro are you dumb or are you out of your mind.
I said I want complete ouput in md file, GIve the complete output shown below in md file so that I can upload it inot github repository as readme.md file, also make any changes required into that.


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


text
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
🔎 Basic Web Enumeration

A lightweight, beginner-friendly and powerful Web Reconnaissance & Bug Hunting Automation Framework for authorized security testing.

The goal of this project is to automate repetitive reconnaissance tasks performed during web application penetration testing and bug bounty hunting.

It combines passive reconnaissance, DNS enumeration, subdomain discovery, permutation, HTTP probing, port scanning, crawling, JavaScript analysis, URL collection, content discovery, and vulnerability-oriented filtering into a single workflow.

⚠️ Disclaimer: This tool is intended only for authorized security testing, bug bounty programs, CTFs, and systems you own or have explicit permission to test.

✨ Features
🔍 Passive subdomain enumeration
🌐 DNS resolution and validation
🔀 Subdomain permutation
🏢 ASN / infrastructure reconnaissance
🔌 Port scanning
🚀 HTTP/HTTPS probing
🧰 Technology fingerprinting
🕰️ Web archive enumeration
🕷️ Web crawling
📜 JavaScript endpoint discovery
🔐 Potential secret/API-key discovery
📂 Directory and file discovery
🎯 URL and parameter collection
🧪 Vulnerability-oriented URL filtering
🛡️ Nuclei vulnerability scanning
📊 Organized output directories
📚 Uses Kali Linux SecLists instead of repository-specific wordlists
⚡ Designed for repeated bug-hunting workflows
🔁 Iterative attack-surface discovery
🧩 Combines multiple reconnaissance techniques into a single workflow
📁 Repository Structure
Basic-Web-Enumeration/
│
├── recon.sh
├── install.sh
└── README.md

The project intentionally keeps the repository structure simple.

recon.sh

The main reconnaissance script. It orchestrates the enumeration workflow and creates organized output.

install.sh

Installs/prepares the required dependencies and security-research tools.

README.md

Complete documentation for installation, usage, methodology, troubleshooting, and workflow.

Note: The project does not require custom modules/, config/, or repository-specific wordlists. Wordlists are obtained from the Kali Linux SecLists installation.

💻 Requirements

Recommended environment:

Kali Linux
Bash
Internet connection
sudo privileges for installation
Go
Python 3
Git

The framework is designed primarily for Kali Linux.

The script uses security-research tools such as:

Subfinder
Assetfinder
BBOT
Amass
Findomain
DNSX
HTTPX
Naabu
Nmap
Katana
Gospider
GAU
Waybackurls
FFUF
Gobuster
Dirsearch
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

Tool availability may vary depending on the installation method and current upstream project changes.

⚙️ Installation
1. Clone the Repository
git clone https://github.com/r4vindra/Basic-Web-Enumeration.git

Enter the repository:

cd Basic-Web-Enumeration
2. Make Scripts Executable
chmod +x recon.sh install.sh
3. Run the Installer
sudo ./install.sh

The installer prepares the required environment and installs the dependencies/tools used by the framework.

After installation, verify the script:

./recon.sh --help

You can also check:

./recon.sh -h
📚 SecLists

This project uses SecLists instead of storing large wordlists inside the repository.

Install SecLists on Kali Linux:

sudo apt update
sudo apt install seclists

Default location:

/usr/share/seclists/

Useful locations include:

/usr/share/seclists/Discovery/
/usr/share/seclists/Discovery/DNS/
/usr/share/seclists/Discovery/Web-Content/
/usr/share/seclists/Discovery/Infrastructure/
/usr/share/seclists/Fuzzing/

Example:

ls /usr/share/seclists/Discovery/Web-Content/

Using the system's SecLists installation keeps this repository lightweight and avoids committing large wordlists to GitHub.

🚀 Usage

Basic usage:

./recon.sh example.com

Display help:

./recon.sh -h

or:

./recon.sh --help

Before running active reconnaissance, make sure the target is explicitly authorized and within scope.

🎯 Target Examples
Single Domain
./recon.sh example.com
Subdomain
./recon.sh api.example.com
IP Address

If supported by the selected reconnaissance stage:

./recon.sh 192.0.2.10
Target List

For workflows supporting list input:

targets.txt

Example:

example.com
example.org
example.net

Then:

./recon.sh -l targets.txt

Use only targets that are explicitly authorized.

🔥 Recommended Reconnaissance Workflow

The framework follows a layered reconnaissance methodology:

                         TARGET
                           │
                           ▼
                  Passive Reconnaissance
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
                           │
                           ▼
                    Security Report

The objective is to progressively expand the target's attack surface instead of relying on a single scanner.

🔎 1. Passive Reconnaissance

The first stage attempts to discover assets using passive or low-impact sources.

Potential sources include:

Certificate Transparency
Search Engines
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

The objective is to create an initial asset inventory.

🌐 2. Subdomain Enumeration

No single subdomain enumeration tool discovers every asset.

The framework can combine multiple sources to increase coverage.

Typical tools:

Subfinder
Assetfinder
Amass
Findomain
BBOT
GitHub Subdomains

Example:

subfinder -d example.com -all -recursive -silent

Assetfinder:

assetfinder --subs-only example.com

Amass:

amass enum -passive -d example.com

Results should be normalized and deduplicated:

sort -u

Example:

cat *.txt | sort -u > subdomains.txt
🔀 3. Subdomain Permutation

Existing subdomains can reveal naming conventions.

For example:

dev.example.com
stage.example.com
api.example.com
internal.example.com
test.example.com
uat.example.com

These naming patterns can be used to generate additional candidates.

Common permutation tools include:

DNSGen
Gotator
Ripgen
Goaltdns
PureDNS

Example:

cat subdomains.txt | dnsgen -

Candidates should then be DNS-resolved before further testing.

The purpose is to discover assets such as:

dev-api.example.com
api-dev.example.com
staging-api.example.com
internal-api.example.com
test-api.example.com
🌍 4. HTTP Probing

Once domains have been discovered, the next step is identifying which hosts actually expose HTTP/HTTPS services.

Typical information collected:

HTTP Status Code
Page Title
Server
Technology
Redirect Location
URL
Port

Example:

httpx -l subdomains.txt -sc -title -td -server -location

This helps prioritize interesting applications.

For example:

200 → Potentially interesting
301 → Redirect
302 → Redirect
401 → Authentication required
403 → Access denied
404 → Not found
500 → Server error

Status codes alone do not indicate vulnerability.

🔌 5. Port Scanning

Web applications are not always hosted only on:

80
443

Additional services can exist on ports such as:

3000
5000
7000
7001
8000
8001
8080
8081
8088
8443
8888
9000
9001
10000

Naabu can be used for fast port discovery:

naabu -list hosts.txt

Nmap can then be used to fingerprint interesting services:

nmap -sV -sC target

Port discovery can reveal:

Development servers
Admin interfaces
APIs
Monitoring applications
Management interfaces
CI/CD services
Additional web applications

Only scan infrastructure that is explicitly within your authorized scope.

🏢 6. ASN / Infrastructure Reconnaissance

Organizations can own multiple IP ranges and networks.

ASN reconnaissance can help identify infrastructure that may not appear during normal subdomain enumeration.

Useful resources include:

BGP.he.net
Censys
Shodan
SecurityTrails

General workflow:

Organization
     │
     ▼
    ASN
     │
     ▼
   CIDRs
     │
     ▼
IP Addresses
     │
     ▼
Open Ports
     │
     ▼
HTTP Services
     │
     ▼
Additional Attack Surface

Infrastructure discovered through ASN enumeration must still be checked against the engagement or bug-bounty scope before scanning.

🕰️ 7. Historical Reconnaissance

Historical data can reveal functionality that is no longer linked from the current application.

Potential discoveries include:

Old endpoints
Deleted functionality
Legacy APIs
Backup files
Old parameters
Forgotten applications
Previous subdomains
Deprecated APIs
Old JavaScript

Useful sources:

Wayback Machine
GAU
Waybackurls
URLScan
AlienVault
Censys

Example:

gau example.com

Historical endpoints should be revalidated against the current target before testing.

🕷️ 8. Web Crawling

Modern applications can contain thousands of endpoints.

Crawling helps discover:

API endpoints
JavaScript files
Parameters
Forms
Hidden paths
Links
Sitemaps
robots.txt
Client-side routes

Common tools:

Katana
Gospider

Example:

katana -u https://example.com -jc -d 5

Gospider:

gospider -s https://example.com

The resulting URLs can then be normalized, deduplicated and categorized.

📜 9. JavaScript Reconnaissance

JavaScript files are one of the most valuable sources of application intelligence.

They may reveal:

API endpoints
Internal routes
Environment names
Feature flags
Third-party integrations
Client-side routes
Parameter names
Potential secrets

Useful tools:

GetJS
Cariddi
Katana

Example:

getJS --input urls.txt --complete --resolve

JavaScript analysis should distinguish between:

Public configuration
Non-sensitive identifiers
API endpoints
Potential secrets
Actual secrets

Potential secrets must always be manually validated.

📂 10. Content Discovery

Content discovery searches for files and directories that may not be linked from the application.

Interesting examples include:

/admin
/api
/dev
/test
/backup
/config
/.git
/swagger
/api-docs
/old
/internal

Common tools:

FFUF
Dirsearch
Gobuster

SecLists can provide the required wordlists.

Example:

ffuf \
-u https://example.com/FUZZ \
-w /usr/share/seclists/Discovery/Web-Content/common.txt

Potentially interesting responses should be manually reviewed.

Be careful with applications that return the same status code or response body for nonexistent paths.

🎯 11. Parameter & Endpoint Analysis

After collecting URLs, filter them based on interesting parameters.

Examples:

id=
url=
uri=
redirect=
next=
return=
file=
path=
page=
cmd=
query=
search=
callback=
template=

Potential testing categories include:

Cross-Site Scripting
SQL Injection
SSRF
SSTI
LFI
RCE
Open Redirect
IDOR
Path Traversal
XXE

Tools such as gf can help categorize URLs.

Example:

cat urls.txt | gf xss

Other examples:

cat urls.txt | gf sqli
cat urls.txt | gf ssrf
cat urls.txt | gf lfi
cat urls.txt | gf rce
cat urls.txt | gf ssti

These commands identify candidates for testing. They do not prove that a vulnerability exists.

🛡️ 12. Nuclei

Nuclei can be used to identify known vulnerabilities and security misconfigurations.

Example:

nuclei -l targets.txt

Useful categories include:

CVE detection
Misconfiguration
Exposed panels
Default credentials
Information disclosure
Known technologies
Security headers
Takeover indicators

For large scopes, use appropriate rate limits and relevant template categories instead of blindly running every available template.

Automated findings must always be manually validated before reporting.

📊 Output Organization

Reconnaissance results should be separated into logical categories.

A typical output structure can look like:

results/
│
├── subdomains/
│
├── dns/
│
├── http/
│
├── ports/
│
├── technologies/
│
├── archives/
│
├── crawling/
│
├── javascript/
│
├── content/
│
├── parameters/
│
├── nuclei/
│
└── findings/

The exact directory/file names depend on the current implementation of recon.sh.

Organized output makes large reconnaissance projects easier to review and compare between scans.

🧠 Bug Hunting Philosophy

The purpose of this framework is not simply to execute hundreds of scanners.

The core methodology is:

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
   ↓
Report

Automation is primarily responsible for discovering and organizing the attack surface.

Human analysis is responsible for determining whether the discovered functionality is actually vulnerable.

🔁 Recommended Recon Cycle

Reconnaissance should be iterative.

A typical cycle is:

Subdomain
    ↓
DNS
    ↓
HTTP
    ↓
Technology
    ↓
Ports
    ↓
URLs
    ↓
Parameters
    ↓
JavaScript
    ↓
New Endpoints
    ↓
New Hostnames
    ↓
New IPs
    ↓
Repeat

For example:

api.example.com
       ↓
JavaScript discovered
       ↓
api-v2.example.com
       ↓
New DNS record
       ↓
New IP
       ↓
Port 8080
       ↓
Development application
       ↓
New endpoints
       ↓
New parameters

Every new discovery can become an input for the next reconnaissance cycle.

🎯 What to Prioritize

Not every discovered asset deserves equal attention.

High-value areas often include:

dev.*
stage.*
staging.*
test.*
uat.*
internal.*
admin.*
api.*
portal.*
vpn.*
old.*
legacy.*

Also prioritize applications exposing:

Login panels
API documentation
Swagger
GraphQL
Admin interfaces
Debug interfaces
File upload functionality
Development environments
Monitoring dashboards
CI/CD systems
Cloud storage
Management interfaces

These are not automatically vulnerable. They are simply useful candidates for deeper manual testing.

🔐 Responsible Usage

Use this project only against:

Your own infrastructure
Authorized penetration-testing environments
CTF/lab environments
Bug-bounty targets where the activity is explicitly permitted
Systems where you have written authorization

Do not scan random Internet infrastructure without authorization.

Always respect:

Scope
Rate limits
Program rules
Testing windows
Exclusions
Legal requirements
Responsible disclosure requirements

If a bug-bounty program excludes a particular asset or testing technique, do not test it.

🛠️ Troubleshooting
Check Whether a Tool Exists
command -v subfinder
command -v httpx
command -v naabu
command -v nuclei
command -v ffuf
command -v katana
Check SecLists
ls /usr/share/seclists/

If SecLists is missing:

sudo apt update
sudo apt install seclists
Check Go
go version
Check Python
python3 --version
Check Bash Script Syntax
bash -n recon.sh
Run in Debug Mode

If something goes wrong:

bash -x recon.sh example.com
Check File Permissions
ls -lh recon.sh install.sh

If required:

chmod +x recon.sh install.sh
🔄 Updating

Update the repository:

cd Basic-Web-Enumeration
git pull

Update Kali packages:

sudo apt update
sudo apt upgrade

Update individual tools according to their official upstream repositories.

📌 Complete Example Workflow

For an authorized bug-bounty target:

./recon.sh example.com

The framework performs reconnaissance and generates organized results.

A typical manual workflow after automation is:

Recon
  ↓
Review discovered assets
  ↓
Identify interesting applications
  ↓
Review technologies
  ↓
Review exposed ports
  ↓
Analyze historical URLs
  ↓
Analyze crawled endpoints
  ↓
Inspect JavaScript
  ↓
Extract interesting parameters
  ↓
Prioritize attack surface
  ↓
Perform manual testing
  ↓
Validate vulnerability
  ↓
Document evidence
  ↓
Report
🧰 Main Tools
Category	Tools
Passive Recon	Subfinder, Amass, BBOT
Subdomain Enumeration	Subfinder, Assetfinder, Amass, Findomain
Permutation	DNSGen, Gotator, Ripgen, Goaltdns
DNS	DNSX, PureDNS
HTTP Probing	HTTPX
Port Discovery	Naabu, Nmap
Crawling	Katana, Gospider
Historical URLs	GAU, Waybackurls
Content Discovery	FFUF, Dirsearch, Gobuster
JavaScript	GetJS, Cariddi
Vulnerability Scanning	Nuclei
URL Filtering	GF
Infrastructure	MapCIDR, ASN intelligence
External Recon	Censys, Shodan, SecurityTrails, URLScan
Wordlists	Kali SecLists
🧩 Why This Framework?

Traditional reconnaissance often involves manually executing many commands:

subfinder
assetfinder
amass
httpx
naabu
nmap
katana
gau
ffuf
nuclei
gf
...

This creates several problems:

Repetitive commands
Forgotten enumeration stages
Scattered output
Difficult result management
Repeated manual setup
Inconsistent reconnaissance methodology

This project attempts to provide a consistent workflow:

One Target
    ↓
Automated Recon
    ↓
Organized Results
    ↓
Manual Analysis

The goal is repeatability, not simply speed.

⚡ Design Principles

The framework follows several principles:

1. Coverage

Use multiple discovery sources where practical.

2. Deduplication

Avoid wasting time testing the same asset repeatedly.

3. Validation

Do not treat discovered domains or URLs as automatically alive.

4. Prioritization

Focus manual testing on interesting assets.

5. Iteration

Feed newly discovered information back into reconnaissance.

6. Organization

Keep outputs structured and easy to review.

7. Safety

Respect target scope, rate limits, exclusions, and authorization.

🧪 Automation vs Manual Testing

Automation is excellent for:

Asset discovery
Subdomain enumeration
DNS resolution
HTTP probing
Port discovery
URL collection
Crawling
Technology identification
Historical URL collection
Initial vulnerability detection

Manual testing remains essential for:

Authentication
Authorization
IDOR/BOLA
Business logic
Race conditions
CSRF
Access-control bypass
Session management
Complex API behavior
Multi-step vulnerabilities
Vulnerability chaining
Impact validation

A scanner may tell you:

Potential SSRF

A security tester must determine:

Is the parameter actually server-side?
Can the request be controlled?
Is outbound interaction possible?
Is authentication required?
Can meaningful impact be demonstrated?
📈 Future Improvements

Possible future features include:

 Better target list support
 Improved passive-source integration
 More ASN discovery automation
 Cloud asset discovery
 Better JavaScript analysis
 Screenshot generation
 Response fingerprinting
 Improved endpoint deduplication
 Automatic parameter extraction
 More takeover detection
 Better API discovery
 GraphQL reconnaissance
 OpenAPI/Swagger discovery
 Recon resume functionality
 Parallelized workflows
 HTML reconnaissance reports
 JSON output
 Configurable rate limits
 Scope/exclusion support
 Better error handling
👨‍💻 Author

Ravindra Kumar Manjhi

GitHub:

https://github.com/r4vindra

Repository:

https://github.com/r4vindra/Basic-Web-Enumeration

⭐ Support

If you find this project useful for your authorized security research:

⭐ Star the repository
🍴 Fork the project
🐛 Report bugs
💡 Suggest improvements
🔧 Contribute improvements
📜 License

This project is provided for educational and authorized security-testing purposes.

Before using any component of this project, review the license and terms of the individual upstream tools included in the workflow.

⚠️ Final Disclaimer

The author is not responsible for damage, service disruption, unauthorized access, data loss, or legal consequences resulting from misuse of this project.

You are responsible for ensuring that you have explicit authorization to test every target.

Use the framework responsibly.

Recon responsibly.
Validate manually.
Respect scope.
Report ethically.
