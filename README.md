# 🔎 Basic-Web-Enumeration

> A modular, automated reconnaissance framework for authorized web application and bug bounty reconnaissance.

**Author:** [r4vindra](https://github.com/r4vindra)

**Version:** 3.0

---

## ⚠️ Disclaimer

This project is intended for:

- Authorized penetration testing
- Bug bounty programs
- Security research
- CTF environments
- Lab environments
- Assets you own or have explicit permission to test

Do **not** use this framework against systems without authorization.

The author is not responsible for misuse, damage, service disruption, or unauthorized activity.

---

# 🚀 Introduction

**Basic-Web-Enumeration** is a modular reconnaissance framework designed to automate the repetitive parts of web application attack-surface discovery.

Instead of manually running dozens of reconnaissance commands, the framework combines multiple open-source tools into a structured workflow:

```text
Target
  │
  ▼
Scope
  │
  ▼
Passive Recon
  │
  ├── Certificate Transparency
  ├── Subfinder
  ├── Assetfinder
  ├── Amass
  ├── Findomain
  ├── GitHub Subdomains
  └── BBOT
  │
  ▼
DNS Resolution
  │
  ▼
Subdomain Permutation
  │
  └── Gotator
  │
  ▼
HTTP Discovery
  │
  └── HTTPX
  │
  ▼
Infrastructure Discovery
  │
  ├── Naabu
  ├── Nmap
  └── Caduceus
  │
  ▼
Historical Recon
  │
  ├── Wayback Machine
  ├── GAU
  └── TheTimeMachine
  │
  ▼
Web Crawling
  │
  ├── Katana
  └── GoSpider
  │
  ▼
URL Analysis
  │
  ├── Parameters
  ├── APIs
  ├── JavaScript
  └── Sensitive Extensions
  │
  ▼
Security Checks
  │
  ├── GF
  ├── Subzy
  └── Nuclei
  │
  ▼
Organized Reports
