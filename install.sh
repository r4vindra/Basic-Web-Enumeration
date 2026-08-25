#!/usr/bin/env bash

# ============================================================
# Basic-Web-Enumeration
# Automated Web Reconnaissance Framework
#
# Author  : r4vindra
# Version : 4.0
#
# Usage:
#   ./recon.sh -d example.com
#   ./recon.sh -l targets.txt
#   ./recon.sh -d example.com --passive
#   ./recon.sh -d example.com --full
#
# IMPORTANT:
# Only use against assets you own or are explicitly authorized
# to test.
# ============================================================

set -Eeuo pipefail

VERSION="4.0"
SCRIPT_NAME="$(basename "$0")"
START_TIME="$(date +%s)"

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
# Global Variables
# ============================================================

TARGET=""
TARGET_LIST=""
PROFILE="standard"

THREADS=50
RATE_LIMIT=100

OUTPUT_BASE="recon"

SECLISTS=""
WORKDIR=""
LOGFILE=""

DOMAIN_FILE=""
SUBDOMAIN_FILE=""
RESOLVED_FILE=""
ALIVE_FILE=""
URL_FILE=""
JS_FILE=""
PARAM_FILE=""
PORT_FILE=""

# ============================================================
# Logging
# ============================================================

info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

success() {
    echo -e "${GREEN}[+]${NC} $*"
}

warn() {
    echo -e "${YELLOW}[!]${NC} $*"
}

error() {
    echo -e "${RED}[-]${NC} $*" >&2
}

section() {
    echo
    echo -e "${MAGENTA}============================================================${NC}"
    echo -e "${WHITE}$*${NC}"
    echo -e "${MAGENTA}============================================================${NC}"
}

run_cmd() {
    echo -e "${GRAY}[CMD]${NC} $*" | tee -a "$LOGFILE"

    if ! "$@" >> "$LOGFILE" 2>&1; then
        warn "Command failed: $*"
        return 1
    fi

    return 0
}

# ============================================================
# Banner
# ============================================================

banner() {

    clear 2>/dev/null || true

    echo -e "${CYAN}"

    cat <<'EOF'

██████╗ ██╗  ██╗██╗   ██╗██╗███╗   ██╗██████╗ ██████╗  █████╗
██╔══██╗██║  ██║██║   ██║██║████╗  ██║██╔══██╗██╔══██╗██╔══██╗
██████╔╝███████║██║   ██║██║██╔██╗ ██║██████╔╝██████╔╝███████║
██╔══██╗██╔══██║╚██╗ ██╔╝██║██║╚██╗██║██╔══██╗██╔══██╗██╔══██║
██║  ██║██║  ██║ ╚████╔╝ ██║██║ ╚████║██████╔╝██║  ██║██║  ██║
╚═╝  ╚═╝╚═╝  ╚═╝  ╚═══╝  ╚═╝╚═╝  ╚═══╝╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝

EOF

    echo -e "${NC}"
    echo -e "${WHITE}Basic Web Enumeration${NC} ${GRAY}v${VERSION}${NC}"
    echo -e "${GRAY}Automated reconnaissance framework${NC}"
    echo
}

# ============================================================
# Usage
# ============================================================

usage() {

    cat <<EOF

Usage:
    $SCRIPT_NAME [OPTIONS]

Target:
    -d, --domain <domain>       Single domain/IP
    -l, --list <file>           File containing targets

Profiles:
    --passive                   Passive reconnaissance
    --standard                  Normal reconnaissance
    --full                      Full reconnaissance

Options:
    -t, --threads <number>      Concurrency (default: ${THREADS})
    --rate <number>             Rate limit (default: ${RATE_LIMIT})
    -o, --output <directory>    Output directory
    --no-nuclei                 Skip Nuclei
    --no-content                Skip content discovery
    --no-crawl                  Skip crawling
    --no-ports                  Skip port scanning
    --no-bbot                   Skip BBOT
    --no-github                 Skip GitHub subdomain discovery
    -h, --help                  Show this help

Examples:

    $SCRIPT_NAME -d example.com

    $SCRIPT_NAME -d example.com --passive

    $SCRIPT_NAME -d example.com --full

    $SCRIPT_NAME -l targets.txt --full

    $SCRIPT_NAME -d example.com --full --threads 100

EOF
}

# ============================================================
# Argument Parsing
# ============================================================

parse_args() {

    while [[ $# -gt 0 ]]; do

        case "$1" in

            -d|--domain)
                TARGET="$2"
                shift 2
                ;;

            -l|--list)
                TARGET_LIST="$2"
                shift 2
                ;;

            --passive)
                PROFILE="passive"
                shift
                ;;

            --standard)
                PROFILE="standard"
                shift
                ;;

            --full)
                PROFILE="full"
                shift
                ;;

            -t|--threads)
                THREADS="$2"
                shift 2
                ;;

            --rate)
                RATE_LIMIT="$2"
                shift 2
                ;;

            -o|--output)
                OUTPUT_BASE="$2"
                shift 2
                ;;

            --no-nuclei)
                NO_NUCLEI=1
                shift
                ;;

            --no-content)
                NO_CONTENT=1
                shift
                ;;

            --no-crawl)
                NO_CRAWL=1
                shift
                ;;

            --no-ports)
                NO_PORTS=1
                shift
                ;;

            --no-bbot)
                NO_BBOT=1
                shift
                ;;

            --no-github)
                NO_GITHUB=1
                shift
                ;;

            -h|--help)
                usage
                exit 0
                ;;

            *)
                error "Unknown argument: $1"
                usage
                exit 1
                ;;

        esac

    done

    if [[ -z "$TARGET" && -z "$TARGET_LIST" ]]; then
        error "You must provide a domain or target list."
        usage
        exit 1
    fi

    if [[ -n "$TARGET" && -n "$TARGET_LIST" ]]; then
        error "Use either --domain or --list, not both."
        exit 1
    fi
}

# ============================================================
# Root / Environment
# ============================================================

check_environment() {

    section "Environment"

    if [[ $EUID -eq 0 ]]; then
        warn "Running as root."
    fi

    if ! command -v bash >/dev/null 2>&1; then
        error "Bash is required."
        exit 1
    fi

    if ! command -v curl >/dev/null 2>&1; then
        error "curl is missing."
        exit 1
    fi
}

# ============================================================
# SecLists Detection
# ============================================================

find_seclists() {

    section "SecLists Detection"

    local paths=(
        "/usr/share/seclists"
        "/usr/share/SecLists"
        "/opt/SecLists"
        "$HOME/SecLists"
    )

    for path in "${paths[@]}"; do

        if [[ -d "$path" ]]; then
            SECLISTS="$path"
            success "SecLists found: $SECLISTS"
            return 0
        fi

    done

    error "SecLists was not found."

    echo
    echo "Install it with:"
    echo
    echo "    sudo apt install seclists"
    echo

    exit 1
}

# ============================================================
# Locate SecLists Resources
# ============================================================

find_wordlist() {

    local type="$1"

    case "$type" in

        dns)

            local candidates=(
                "$SECLISTS/Discovery/DNS/subdomains-top1million-5000.txt"
                "$SECLISTS/Discovery/DNS/subdomains-top1million-20000.txt"
                "$SECLISTS/Discovery/DNS/bitquark-subdomains-top100000.txt"
            )

            ;;

        web)

            local candidates=(
                "$SECLISTS/Discovery/Web-Content/common.txt"
                "$SECLISTS/Discovery/Web-Content/combined_directories.txt"
                "$SECLISTS/Discovery/Web-Content/raft-small-words.txt"
            )

            ;;

        parameters)

            local candidates=(
                "$SECLISTS/Discovery/Web-Content/burp-parameter-names.txt"
                "$SECLISTS/Discovery/Web-Content/raft-small-words.txt"
            )

            ;;

        permutations)

            local candidates=(
                "$SECLISTS/Discovery/DNS/namelist.txt"
                "$SECLISTS/Discovery/DNS/subdomains-top1million-5000.txt"
            )

            ;;

        *)

            return 1
            ;;

    esac

    for wordlist in "${candidates[@]}"; do

        if [[ -f "$wordlist" ]]; then
            echo "$wordlist"
            return 0
        fi

    done

    return 1
}

# ============================================================
# Tool Checking
# ============================================================

require_tool() {

    local tool="$1"

    if command -v "$tool" >/dev/null 2>&1; then
        return 0
    fi

    warn "Missing tool: $tool"
    return 1
}

check_tools() {

    section "Tool Check"

    local required=(
        curl
        jq
        subfinder
        httpx
        dnsx
        katana
    )

    local optional=(
        assetfinder
        amass
        findomain
        naabu
        nmap
        gau
        waybackurls
        gospider
        gotator
        dnsgen
        ffuf
        dirsearch
        nuclei
        subzy
        gf
        bbot
        github-subdomains
    )

    local missing=0

    echo -e "${WHITE}Required:${NC}"

    for tool in "${required[@]}"; do

        if require_tool "$tool"; then
            echo -e "  ${GREEN}[OK]${NC} $tool"
        else
            echo -e "  ${RED}[MISSING]${NC} $tool"
            ((missing+=1))
        fi

    done

    echo
    echo -e "${WHITE}Optional:${NC}"

    for tool in "${optional[@]}"; do

        if command -v "$tool" >/dev/null 2>&1; then
            echo -e "  ${GREEN}[OK]${NC} $tool"
        else
            echo -e "  ${YELLOW}[SKIP]${NC} $tool"
        fi

    done

    if [[ "$missing" -gt 0 ]]; then
        error "Required dependencies are missing."
        echo "Run:"
        echo "    sudo ./install.sh"
        exit 1
    fi
}

# ============================================================
# Prepare Workspace
# ============================================================

prepare_workspace() {

    local name

    if [[ -n "$TARGET" ]]; then
        name="$TARGET"
    else
        name="multi-target"
    fi

    name="$(echo "$name" | tr '/:' '__' | tr -cd '[:alnum:]_.-')"

    WORKDIR="${OUTPUT_BASE}/${name}_$(date '+%Y%m%d_%H%M%S')"

    mkdir -p "$WORKDIR"/{
        scope,
        passive,
        dns,
        permutations,
        infrastructure,
        http,
        archives,
        crawl,
        javascript,
        content,
        findings,
        reports,
        logs
    }

    LOGFILE="$WORKDIR/logs/recon.log"

    touch "$LOGFILE"

    DOMAIN_FILE="$WORKDIR/scope/targets.txt"
    SUBDOMAIN_FILE="$WORKDIR/dns/subdomains.txt"
    RESOLVED_FILE="$WORKDIR/dns/resolved.txt"
    ALIVE_FILE="$WORKDIR/http/alive.txt"
    URL_FILE="$WORKDIR/archives/all-urls.txt"
    JS_FILE="$WORKDIR/javascript/javascript.txt"
    PARAM_FILE="$WORKDIR/content/parameters.txt"
    PORT_FILE="$WORKDIR/infrastructure/ports.txt"

    success "Output directory: $WORKDIR"
}

# ============================================================
# Prepare Targets
# ============================================================

prepare_targets() {

    section "Scope"

    if [[ -n "$TARGET" ]]; then
        echo "$TARGET" > "$DOMAIN_FILE"
    else

        if [[ ! -f "$TARGET_LIST" ]]; then
            error "Target list does not exist: $TARGET_LIST"
            exit 1
        fi

        sed \
            -e 's/\r//g' \
            -e '/^[[:space:]]*#/d' \
            -e '/^[[:space:]]*$/d' \
            "$TARGET_LIST" |
            sort -u > "$DOMAIN_FILE"
    fi

    sed -i 's#https\?://##g' "$DOMAIN_FILE"

    success "Targets loaded: $(wc -l < "$DOMAIN_FILE")"
}

# ============================================================
# Passive Recon
# ============================================================

passive_recon() {

    section "Passive Reconnaissance"

    local target

    while IFS= read -r target; do

        info "Passive enumeration: $target"

        if command -v subfinder >/dev/null 2>&1; then
            subfinder \
                -d "$target" \
                -all \
                -silent \
                -o "$WORKDIR/passive/subfinder-${target}.txt" \
                >> "$LOGFILE" 2>&1 || true
        fi

        if command -v assetfinder >/dev/null 2>&1; then
            assetfinder \
                --subs-only "$target" \
                > "$WORKDIR/passive/assetfinder-${target}.txt" \
                2>> "$LOGFILE" || true
        fi

        if command -v findomain >/dev/null 2>&1; then
            findomain \
                -t "$target" \
                --quiet \
                -u "$WORKDIR/passive/findomain-${target}.txt" \
                >> "$LOGFILE" 2>&1 || true
        fi

        if command -v amass >/dev/null 2>&1; then
            amass enum \
                -passive \
                -d "$target" \
                -o "$WORKDIR/passive/amass-${target}.txt" \
                >> "$LOGFILE" 2>&1 || true
        fi

        if [[ "${NO_GITHUB:-0}" -eq 0 ]] &&
           command -v github-subdomains >/dev/null 2>&1; then

            if [[ -n "${GITHUB_TOKEN:-}" ]]; then

                github-subdomains \
                    -d "$target" \
                    -t "$GITHUB_TOKEN" \
                    > "$WORKDIR/passive/github-${target}.txt" \
                    2>> "$LOGFILE" || true

            else
                warn "GITHUB_TOKEN not set. Skipping GitHub enumeration."
            fi

        fi

    done < "$DOMAIN_FILE"

    cat "$WORKDIR"/passive/*.txt 2>/dev/null |
        sed 's/\r//g' |
        sed '/^[[:space:]]*$/d' |
        sort -u |
        grep -Ei '^[A-Za-z0-9._-]+\.[A-Za-z]{2,}$' \
        > "$SUBDOMAIN_FILE" || true

    cat "$DOMAIN_FILE" >> "$SUBDOMAIN_FILE"

    sort -u "$SUBDOMAIN_FILE" -o "$SUBDOMAIN_FILE"

    success "Unique domains/subdomains: $(wc -l < "$SUBDOMAIN_FILE")"
}

# ============================================================
# BBOT
# ============================================================

bbot_recon() {

    [[ "${NO_BBOT:-0}" -eq 1 ]] && return 0

    if ! command -v bbot >/dev/null 2>&1; then
        warn "BBOT not installed. Skipping."
        return 0
    fi

    section "BBOT Recon"

    while IFS= read -r target; do

        info "BBOT: $target"

        bbot \
            -t "$target" \
            -m subdomain-enum \
            -o "$WORKDIR/passive/bbot-${target}" \
            >> "$LOGFILE" 2>&1 || true

    done < "$DOMAIN_FILE"
}

# ============================================================
# DNS Resolution
# ============================================================

dns_resolution() {

    section "DNS Resolution"

    if command -v dnsx >/dev/null 2>&1; then

        dnsx \
            -l "$SUBDOMAIN_FILE" \
            -silent \
            -a \
            -resp \
            -o "$RESOLVED_FILE" \
            >> "$LOGFILE" 2>&1 || true

    fi

    if [[ ! -s "$RESOLVED_FILE" ]]; then

        while IFS= read -r domain; do

            ip=$(getent ahosts "$domain" 2>/dev/null |
                awk '{print $1}' |
                sort -u |
                head -n 1 || true)

            [[ -n "$ip" ]] && echo "$domain [$ip]"

        done < "$SUBDOMAIN_FILE" > "$RESOLVED_FILE"

    fi

    success "Resolved targets: $(wc -l < "$RESOLVED_FILE")"
}

# ============================================================
# Permutation
# ============================================================

permutation_recon() {

    section "Subdomain Permutation"

    local wordlist

    wordlist="$(find_wordlist permutations || true)"

    if [[ -z "$wordlist" ]]; then
        warn "Suitable SecLists permutation list not found."
        return 0
    fi

    info "Using SecLists:"
    echo "    $wordlist"

    if command -v gotator >/dev/null 2>&1; then

        gotator \
            -sub "$SUBDOMAIN_FILE" \
            -perm "$wordlist" \
            -depth 1 \
            -silent \
            > "$WORKDIR/permutations/gotator.txt" \
            2>> "$LOGFILE" || true

    elif command -v dnsgen >/dev/null 2>&1; then

        cat "$SUBDOMAIN_FILE" |
            dnsgen - |
            sort -u \
            > "$WORKDIR/permutations/dnsgen.txt" \
            2>> "$LOGFILE" || true

    else

        warn "Gotator/DNSGen not installed."
        return 0

    fi

    if [[ -s "$WORKDIR/permutations/gotator.txt" ]]; then

        dnsx \
            -l "$WORKDIR/permutations/gotator.txt" \
            -silent \
            > "$WORKDIR/permutations/resolved.txt" \
            2>> "$LOGFILE" || true

        cat "$WORKDIR/permutations/resolved.txt" >> "$SUBDOMAIN_FILE"

        sort -u "$SUBDOMAIN_FILE" -o "$SUBDOMAIN_FILE"

    fi

    success "Permutation stage completed."
}

# ============================================================
# HTTP Discovery
# ============================================================

http_discovery() {

    section "HTTP Discovery & Fingerprinting"

    if ! command -v httpx >/dev/null 2>&1; then
        error "HTTPX is required."
        return 1
    fi

    httpx \
        -l "$SUBDOMAIN_FILE" \
        -silent \
        -threads "$THREADS" \
        -status-code \
        -title \
        -tech-detect \
        -server \
        -location \
        -follow-redirects \
        -json \
        -o "$WORKDIR/http/httpx.json" \
        >> "$LOGFILE" 2>&1 || true

    jq -r '.url // empty' \
        "$WORKDIR/http/httpx.json" |
        sort -u \
        > "$ALIVE_FILE" || true

    success "Alive web targets: $(wc -l < "$ALIVE_FILE")"
}

# ============================================================
# Port Scanning
# ============================================================

port_scan() {

    [[ "${NO_PORTS:-0}" -eq 1 ]] && return 0

    section "Infrastructure / Port Discovery"

    if ! command -v naabu >/dev/null 2>&1; then
        warn "Naabu not installed. Skipping port scan."
        return 0
    fi

    local ports="80,443,8000,8001,8008,8080,8081,8082,8088,8090,8181,8443,8888,9000,9001,9090,9443,10000"

    naabu \
        -list "$SUBDOMAIN_FILE" \
        -p "$ports" \
        -c "$THREADS" \
        -rate "$RATE_LIMIT" \
        -silent \
        -o "$PORT_FILE" \
        >> "$LOGFILE" 2>&1 || true

    success "Open web-related ports: $(wc -l < "$PORT_FILE")"

    if command -v httpx >/dev/null 2>&1 &&
       [[ -s "$PORT_FILE" ]]; then

        httpx \
            -l "$PORT_FILE" \
            -silent \
            -status-code \
            -title \
            -tech-detect \
            -server \
            -json \
            -o "$WORKDIR/infrastructure/http-services.json" \
            >> "$LOGFILE" 2>&1 || true

    fi
}

# ============================================================
# Historical URLs
# ============================================================

archives() {

    section "Historical URL Discovery"

    : > "$URL_FILE"

    if command -v gau >/dev/null 2>&1; then

        gau \
            --threads "$THREADS" \
            --blacklist jpg,jpeg,png,gif,svg,css,woff,woff2,ico \
            < "$DOMAIN_FILE" \
            >> "$WORKDIR/archives/gau.txt" \
            2>> "$LOGFILE" || true

    fi

    if command -v waybackurls >/dev/null 2>&1; then

        while IFS= read -r domain; do

            echo "$domain" |
                waybackurls \
                >> "$WORKDIR/archives/waybackurls.txt" \
                2>> "$LOGFILE" || true

        done < "$DOMAIN_FILE"

    fi

    cat "$WORKDIR"/archives/*.txt 2>/dev/null |
        sed '/^[[:space:]]*$/d' |
        sort -u > "$URL_FILE" || true

    success "Historical URLs: $(wc -l < "$URL_FILE")"
}

# ============================================================
# Crawling
# ============================================================

crawl() {

    [[ "${NO_CRAWL:-0}" -eq 1 ]] && return 0

    section "Web Crawling"

    if [[ ! -s "$ALIVE_FILE" ]]; then
        warn "No alive targets available for crawling."
        return 0
    fi

    if command -v katana >/dev/null 2>&1; then

        katana \
            -list "$ALIVE_FILE" \
            -d 5 \
            -jc \
            -kf all \
            -c "$THREADS" \
            -silent \
            -o "$WORKDIR/crawl/katana.txt" \
            >> "$LOGFILE" 2>&1 || true

    fi

    if command -v gospider >/dev/null 2>&1; then

        gospider \
            -S "$ALIVE_FILE" \
            -a \
            -r \
            -d 3 \
            -c 10 \
            -t "$THREADS" \
            -q \
            > "$WORKDIR/crawl/gospider.txt" \
            2>> "$LOGFILE" || true

    fi

    cat "$WORKDIR"/crawl/*.txt 2>/dev/null |
        grep -Eo 'https?://[^ ]+' |
        sed 's/[<>"]//g' |
        sort -u \
        > "$WORKDIR/crawl/all-urls.txt" || true

    success "Crawled URLs: $(wc -l < "$WORKDIR/crawl/all-urls.txt")"
}

# ============================================================
# URL Analysis
# ============================================================

analyze_urls() {

    section "URL Analysis"

    cat \
        "$URL_FILE" \
        "$WORKDIR/crawl/all-urls.txt" \
        2>/dev/null |
        grep -E '^https?://' |
        sort -u \
        > "$WORKDIR/content/all-urls.txt" || true

    grep -E '\?.+=' \
        "$WORKDIR/content/all-urls.txt" |
        sort -u \
        > "$PARAM_FILE" || true

    grep -Ei \
        '/(api|api/v[0-9]+|graphql|swagger|openapi|rest)(/|$)' \
        "$WORKDIR/content/all-urls.txt" |
        sort -u \
        > "$WORKDIR/content/api-endpoints.txt" || true

    grep -Ei \
        '\.(bak|backup|old|zip|tar|gz|sql|db|sqlite|log|conf|config|ini|yaml|yml|json|xml)$' \
        "$WORKDIR/content/all-urls.txt" |
        sort -u \
        > "$WORKDIR/content/interesting-files.txt" || true

    grep -Ei '\.js([?#]|$)' \
        "$WORKDIR/content/all-urls.txt" |
        sort -u \
        > "$JS_FILE" || true

    success "Parameterized URLs: $(wc -l < "$PARAM_FILE")"
    success "JavaScript URLs: $(wc -l < "$JS_FILE")"
}

# ============================================================
# Content Discovery
# ============================================================

content_discovery() {

    [[ "${NO_CONTENT:-0}" -eq 1 ]] && return 0

    section "Content Discovery"

    if ! command -v ffuf >/dev/null 2>&1; then
        warn "FFUF not installed. Skipping content discovery."
        return 0
    fi

    local wordlist

    wordlist="$(find_wordlist web || true)"

    if [[ -z "$wordlist" ]]; then
        warn "Suitable SecLists Web-Content wordlist not found."
        return 0
    fi

    info "Using:"
    echo "    $wordlist"

    mkdir -p "$WORKDIR/content/ffuf"

    while IFS= read -r url; do

        local host

        host="$(echo "$url" |
            sed -E 's#https?://##' |
            cut -d/ -f1 |
            tr ':/' '__')"

        [[ -z "$host" ]] && continue

        ffuf \
            -u "${url%/}/FUZZ" \
            -w "$wordlist" \
            -t "$THREADS" \
            -rate "$RATE_LIMIT" \
            -mc all \
            -fc 404 \
            -of json \
            -o "$WORKDIR/content/ffuf/${host}.json" \
            -s \
            >> "$LOGFILE" 2>&1 || true

    done < "$ALIVE_FILE"

    success "Content discovery completed."
}

# ============================================================
# JavaScript Analysis
# ============================================================

javascript_analysis() {

    section "JavaScript Analysis"

    if [[ ! -s "$JS_FILE" ]]; then
        warn "No JavaScript URLs found."
        return 0
    fi

    sort -u "$JS_FILE" > "$WORKDIR/javascript/javascript.txt"

    if command -v katana >/dev/null 2>&1; then

        katana \
            -list "$WORKDIR/javascript/javascript.txt" \
            -jc \
            -silent \
            -o "$WORKDIR/javascript/js-crawl.txt" \
            >> "$LOGFILE" 2>&1 || true

    fi

    success "JavaScript analysis completed."
}

# ============================================================
# GF Findings
# ============================================================

gf_analysis() {

    section "Pattern-Based Candidate Analysis"

    if ! command -v gf >/dev/null 2>&1; then
        warn "GF is not installed. Skipping."
        return 0
    fi

    local input="$WORKDIR/content/all-urls.txt"

    [[ ! -s "$input" ]] && return 0

    local patterns=(
        xss
        sqli
        ssrf
        lfi
        rce
        ssti
        redirect
        idor
        upload
        graphql
    )

    for pattern in "${patterns[@]}"; do

        if gf "$pattern" < "$input" \
            > "$WORKDIR/findings/gf-${pattern}.txt" 2>/dev/null; then

            sort -u \
                "$WORKDIR/findings/gf-${pattern}.txt" \
                -o "$WORKDIR/findings/gf-${pattern}.txt"

        fi

    done

    success "GF candidate analysis completed."
}

# ============================================================
# Subdomain Takeover
# ============================================================

takeover_check() {

    if ! command -v subzy >/dev/null 2>&1; then
        warn "Subzy not installed. Skipping."
        return 0
    fi

    section "Subdomain Takeover Candidate Check"

    subzy run \
        --targets "$SUBDOMAIN_FILE" \
        --hide_fails \
        > "$WORKDIR/findings/subzy.txt" \
        2>> "$LOGFILE" || true

    success "Subzy check completed."
}

# ============================================================
# Nuclei
# ============================================================

nuclei_scan() {

    [[ "${NO_NUCLEI:-0}" -eq 1 ]] && return 0

    if ! command -v nuclei >/dev/null 2>&1; then
        warn "Nuclei not installed. Skipping."
        return 0
    fi

    if [[ ! -s "$ALIVE_FILE" ]]; then
        warn "No live targets for Nuclei."
        return 0
    fi

    section "Nuclei Validation"

    nuclei \
        -l "$ALIVE_FILE" \
        -severity low,medium,high,critical \
        -c "$THREADS" \
        -rl "$RATE_LIMIT" \
        -jsonl \
        -o "$WORKDIR/findings/nuclei.jsonl" \
        >> "$LOGFILE" 2>&1 || true

    success "Nuclei scan completed."
}

# ============================================================
# Report
# ============================================================

generate_report() {

    section "Generating Report"

    local end_time
    local elapsed

    end_time="$(date +%s)"
    elapsed=$((end_time - START_TIME))

    local subdomains=0
    local alive=0
    local urls=0
    local parameters=0
    local js=0
    local ports=0

    [[ -f "$SUBDOMAIN_FILE" ]] &&
        subdomains="$(wc -l < "$SUBDOMAIN_FILE")"

    [[ -f "$ALIVE_FILE" ]] &&
        alive="$(wc -l < "$ALIVE_FILE")"

    [[ -f "$WORKDIR/content/all-urls.txt" ]] &&
        urls="$(wc -l < "$WORKDIR/content/all-urls.txt")"

    [[ -f "$PARAM_FILE" ]] &&
        parameters="$(wc -l < "$PARAM_FILE")"

    [[ -f "$JS_FILE" ]] &&
        js="$(wc -l < "$JS_FILE")"

    [[ -f "$PORT_FILE" ]] &&
        ports="$(wc -l < "$PORT_FILE")"

    cat > "$WORKDIR/reports/summary.txt" <<EOF
============================================================
Basic-Web-Enumeration
============================================================

Version       : ${VERSION}
Profile       : ${PROFILE}
Started       : $(date)
Duration      : ${elapsed} seconds

Output        : ${WORKDIR}

============================================================
DISCOVERY SUMMARY
============================================================

Subdomains    : ${subdomains}
Alive Web     : ${alive}
Open Ports    : ${ports}
URLs          : ${urls}
Parameters    : ${parameters}
JavaScript    : ${js}

============================================================
IMPORTANT
============================================================

Automated output represents reconnaissance data or candidate
findings. Results require manual validation.

============================================================
EOF

    success "Report: $WORKDIR/reports/summary.txt"
}

# ============================================================
# Main Pipeline
# ============================================================

main() {

    banner

    parse_args "$@"

    check_environment

    find_seclists

    check_tools

    prepare_workspace

    prepare_targets

    passive_recon

    if [[ "$PROFILE" != "passive" ]]; then

        bbot_recon

        dns_resolution

        permutation_recon

        http_discovery

        port_scan

        archives

        crawl

        analyze_urls

        content_discovery

        javascript_analysis

        gf_analysis

        takeover_check

        nuclei_scan

    fi

    generate_report

    section "Reconnaissance Complete"

    echo
    echo -e "${GREEN}Results:${NC}"
    echo
    echo "    $WORKDIR"
    echo

    echo -e "${WHITE}Summary:${NC}"
    echo
    cat "$WORKDIR/reports/summary.txt"
}

main "$@"
