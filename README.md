# 🔎 Basic Web Enumeration

A lightweight Bash-based web reconnaissance tool for **penetration testers, bug bounty hunters, and security researchers**.

It automates common web enumeration tasks by combining multiple open-source reconnaissance tools into a simple workflow.

> ⚠️ **For authorized security testing only. Do not scan targets without permission.**

---

## 🚀 What It Does

Basic-Web-Enumeration helps automate:

* 🌐 Subdomain enumeration
* 🔍 DNS resolution
* 🛰️ Live host discovery
* 🔓 Port enumeration
* 🕷️ Web crawling
* 🔗 URL & endpoint collection
* 📜 Historical URL discovery
* 🎯 Vulnerability scanning
* 🚨 Subdomain takeover detection
* 🔎 GF-based URL filtering

The general workflow is:

```text
Target
  ↓
Subdomains
  ↓
DNS Resolution
  ↓
Live Hosts
  ↓
Ports
  ↓
Crawling & URL Collection
  ↓
Filtering
  ↓
Vulnerability Detection
```

---

## 🛠️ Tools

The installation script sets up commonly used security tools, including:

* **Subfinder**
* **Assetfinder**
* **Findomain**
* **HTTPX**
* **DNSX**
* **Naabu**
* **Katana**
* **GoSpider**
* **GAU**
* **Waybackurls**
* **Nuclei**
* **Subzy**
* **GF**
* **BBOT**
* **GitHub Subdomains**
* **TheTimeMachine**
* **SecLists**

Along with required system dependencies.

---

## 📦 Installation

### Clone

```bash
git clone https://github.com/r4vindra/Basic-Web-Enumeration.git
cd Basic-Web-Enumeration
```

### Install

```bash
chmod +x install.sh
sudo ./install.sh
```

The installer automatically installs the required dependencies and reconnaissance tools.

**Supported:** Kali Linux, Debian and Ubuntu.

---

## ⚡ Usage

Make the enumeration script executable:

```bash
chmod +x recon.sh
```

Run:

```bash
./recon.sh -d example.com
```

### Passive Mode

```bash
./recon.sh -d example.com --passive
```

### Full Recon

```bash
./recon.sh -d example.com --full
```

> Replace `example.com` with an authorized target.

---

## 📚 Wordlists

The project uses **SecLists** for wordlists instead of maintaining a separate wordlist directory inside the repository.

The installer automatically sets up SecLists and makes commonly used wordlists available for:

* DNS enumeration
* Directory discovery
* Fuzzing
* Parameter discovery
* Content discovery

---

## 🔑 GitHub Token

Some GitHub-based enumeration functionality can benefit from an authenticated GitHub token.

Example:

```bash
github-subdomains -d example.com -t YOUR_GITHUB_TOKEN
```

Never commit tokens or other credentials to the repository.

---

## 🔬 Methodology

The tool follows a simple reconnaissance pipeline:

**1. Discover** → Find subdomains and assets.

**2. Resolve** → Validate DNS records.

**3. Probe** → Identify live HTTP/HTTPS services.

**4. recon** → Discover ports, endpoints, URLs and technologies.

**5. Crawl** → Collect application paths and resources.

**6. Filter** → Extract interesting URLs and parameters.

**7. Scan** → Run automated vulnerability checks.

**8. Verify** → Manually validate potential findings.

Automation helps with **discovery**, but vulnerabilities should always be **manually verified** before reporting.

---

## ⚠️ Disclaimer

This project is intended **only for authorized penetration testing, bug bounty programs, CTFs, labs, and security research**.

The author is not responsible for damage, disruption, or unauthorized activity resulting from misuse of this tool.

**Scan responsibly. Stay in scope. 🔐**

---

## 👨‍💻 Author

**r4vindra**

GitHub:
https://github.com/r4vindra

Repository:
https://github.com/r4vindra/Basic-Web-Enumeration
