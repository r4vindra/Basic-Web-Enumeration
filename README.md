# 🔎 Basic-Web-Enumeration

> A single-file automated web reconnaissance framework for authorized penetration testing, security research, and bug bounty reconnaissance.

**Author:** [r4vindra](https://github.com/r4vindra)

**Version:** 4.0

---

## ⚠️ Disclaimer

This tool is intended only for:

- Authorized penetration testing
- Bug bounty programs
- Security research
- CTF/lab environments
- Infrastructure you own
- Systems for which you have explicit permission

Do not use this tool against systems without authorization.

The author is not responsible for misuse, damage, service disruption, or unauthorized activity.

---

# 🚀 Overview

Basic-Web-Enumeration is a Bash-based reconnaissance framework designed to automate repetitive web reconnaissance tasks.

The project intentionally does **not** maintain its own:

- Module directory
- Configuration directory
- Wordlist directory

Instead, the framework uses:

- Installed security tools
- Kali Linux's SecLists
- Runtime-generated output directories

This keeps the repository lightweight and makes installation easier.

---

# 🧠 Architecture

```text
                         TARGET
                           │
                           ▼
                     Scope Handling
                           │
                           ▼
                  Passive Enumeration
                           │
             ┌─────────────┼─────────────┐
             │             │             │
         Subfinder     Assetfinder    Amass
             │             │             │
             └─────────────┼─────────────┘
                           │
                           ▼
                    DNS Resolution
                           │
                           ▼
                  Subdomain Permutation
                           │
                     SecLists DNS
                           │
                           ▼
                    HTTP Discovery
                           │
                         HTTPX
                           │
             ┌─────────────┴─────────────┐
             ▼                           ▼
       Port Discovery              Fingerprinting
          Naabu                         HTTPX
             │
             ▼
                  Historical URLs
             │
        ┌────┴────────────┐
        ▼                 ▼
       GAU            Waybackurls
        │                 │
        └────────┬────────┘
                 ▼
             Web Crawling
                 │
          ┌──────┴──────┐
          ▼             ▼
       Katana        GoSpider
          │             │
          └──────┬──────┘
                 ▼
             URL Analysis
                 │
       ┌─────────┼─────────┐
       ▼         ▼         ▼
      APIs    Parameters   JS
                 │
                 ▼
         Content Discovery
                 │
              SecLists
                 │
                 ▼
        Candidate Analysis
          │       │       │
         GF     Subzy   Nuclei
          │       │       │
          └───────┼───────┘
                  ▼
              REPORT
