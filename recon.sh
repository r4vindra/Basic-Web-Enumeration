#!/usr/bin/env bash

# ============================================================
# recon.sh
# Professional Bug Bounty Recon Framework
#
# Author: r4vindra
#
# PURPOSE
# -------
# Orchestrates passive/active web reconnaissance while keeping
# every stage separated and reproducible.
#
# INPUT
# -----
#   ./recon.sh -d example.com
#   ./recon.sh -d example.com --passive
#   ./recon.sh -d example.com --full
#   ./recon.sh -l targets.txt --full
#
# IMPORTANT
# ---------
# Use only against assets that are explicitly in scope.
# ============================================================

set -Eeuo pipefail

VERSION="3.0"

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
# Defaults
# ============================================================

DOMAIN=""
TARGET_FILE=""
MODE="standard"

THREADS=50
NAABU_PORTS="80,81,443,4443,591,593,8000,8001,8008,8009,8080,8081,8088,8089,8090,8443,8888,9000,9001,9002,7001,7002,7003,7070,7443,8002,8003,8004,8083,8086,8091,8181,9003,9090,9443,10000"

WORDLIST=""
RESOLVERS=""

RUN_BBOT="auto"
RUN_CADUCEUS="auto"
RUN_TIMEMACHINE="auto"
RUN_GITHUB="auto"

START_TIME=$(date +%s)

# ============================================================
# Output
# ============================================================

RUN_ID=$(date +"%Y%m%d_%H%M%S")

ROOT_DIR=""

# ============================================================
# Helpers
# ============================================================

log() {
    echo -e "$1" | tee -a "$ROOT_DIR/logs/recon.log"
}

info() {
    log "${BLUE}[INFO]${NC} $1"
}

good() {
    log "${GREEN}[+]${NC} $1"
}

warn() {
    log "${YELLOW}[!]${NC} $1"
}

error() {
    log "${RED}[-]${NC} $1"
}

section() {
    log ""
    log "${MAGENTA}============================================================${NC}"
    log "${WHITE}$1${NC}"
    log "${MAGENTA}============================================================${NC}"
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

    echo -e "${WHITE}Bug Bounty Recon Framework v${VERSION}${NC}"
    echo -e "${GRAY}Discover → Correlate → Validate → Prioritize${NC}"
    echo
}

# ============================================================
# Usage
# ============================================================

usage() {

    cat <<EOF

Usage:

  $0 -d example.com
  $0 -d example.com --passive
  $0 -d example.com --full
  $0 -l targets.txt --full

Options:

  -d DOMAIN       Target root domain
  -l FILE         File containing target domains

  --passive       Passive reconnaissance only
  --standard      Standard reconnaissance
  --full          Full reconnaissance

  --threads N     Number of threads (default: 50)

  --wordlist FILE Permutation/content wordlist
  --resolvers FILE
                  DNS resolvers for puredns

  --no-bbot       Disable BBOT
  --no-github     Disable github-subdomains
  --no-caduceus   Disable Caduceus
  --no-ttm        Disable TheTimeMachine

  -h, --help      Show this help

Examples:

  $0 -d example.com

  $0 -d example.com --passive

  $0 -d example.com --full --threads 100

  $0 -l targets.txt --standard

EOF
}

# ============================================================
# Argument Parsing
# ============================================================

while [[ $# -gt 0 ]]; do

    case "$1" in

        -d)
            DOMAIN="$2"
            shift 2
            ;;

        -l)
            TARGET_FILE="$2"
            shift 2
            ;;

        --passive)
            MODE="passive"
            shift
            ;;

        --standard)
            MODE="standard"
            shift
            ;;

        --full)
            MODE="full"
            shift
            ;;

        --threads)
            THREADS="$2"
            shift 2
            ;;

        --wordlist)
            WORDLIST="$2"
            shift 2
            ;;

        --resolvers)
            RESOLVERS="$2"
            shift 2
            ;;

        --no-bbot)
            RUN_BBOT="no"
            shift
            ;;

        --no-github)
            RUN_GITHUB="no"
            shift
            ;;

        --no-caduceus)
            RUN_CADUCEUS="no"
            shift
            ;;

        --no-ttm)
            RUN_TIMEMACHINE="no"
            shift
            ;;

        -h|--help)
            usage
            exit 0
            ;;

        *)
            error "Unknown option: $1"
            usage
            exit 1
            ;;

    esac

done

# ============================================================
# Validate input
# ============================================================

if [[ -z "$DOMAIN" && -z "$TARGET_FILE" ]]; then

    usage

    read -rp "Enter target domain: " DOMAIN

fi

if [[ -n "$TARGET_FILE" && ! -f "$TARGET_FILE" ]]; then
    error "Target file does not exist: $TARGET_FILE"
    exit 1
fi

if [[ -n "$DOMAIN" ]]; then

    DOMAIN="${DOMAIN#http://}"
    DOMAIN="${DOMAIN#https://}"
    DOMAIN="${DOMAIN%%/*}"

fi

# ============================================================
# Initialize workspace
# ============================================================

if [[ -n "$DOMAIN" ]]; then
    ROOT_DIR="recon/${DOMAIN}_${RUN_ID}"
else
    ROOT_DIR="recon/target-list_${RUN_ID}"
fi

mkdir -p \
    "$ROOT_DIR"/{logs,scope,passive,subdomains,dns,permutations,infra,http,crawl,archives,content,js,findings,reports,raw}

touch "$ROOT_DIR/logs/recon.log"

# ============================================================
# Dependency helpers
# ============================================================

have() {
    command -v "$1" >/dev/null 2>&1
}

run_optional() {

    local tool="$1"
    shift

    if have "$tool"; then
        info "Running $tool..."
        "$@" || warn "$tool returned a non-zero exit status."
    else
        warn "$tool not installed — skipping."
    fi
}

# ============================================================
# Scope
# ============================================================

prepare_scope() {

    section "01 — Scope Preparation"

    if [[ -n "$DOMAIN" ]]; then

        echo "$DOMAIN" > "$ROOT_DIR/scope/domains.txt"

    else

        grep -Eiv '^[[:space:]]*(#|$)' "$TARGET_FILE" \
            | sed 's#https\?://##' \
            | sed 's#/.*##' \
            | tr '[:upper:]' '[:lower:]' \
            | sort -u \
            > "$ROOT_DIR/scope/domains.txt"

    fi

    cp "$ROOT_DIR/scope/domains.txt" \
       "$ROOT_DIR/scope/scope-original.txt"

    good "Scope saved."

    cat "$ROOT_DIR/scope/domains.txt"
}

# ============================================================
# Certificate Transparency
# ============================================================

crtsh() {

    section "02 — Certificate Transparency"

    while read -r domain; do

        curl -fsS \
            "https://crt.sh/?q=%25.${domain}&output=json" \
            2>/dev/null \
            | jq -r '.[].name_value' 2>/dev/null \
            | sed 's/\*\.//g'

    done < "$ROOT_DIR/scope/domains.txt" \
        | sort -u \
        > "$ROOT_DIR/passive/crtsh.txt"

    good "crt.sh results: $(wc -l < "$ROOT_DIR/passive/crtsh.txt")"

}

# ============================================================
# Subdomain Enumeration
# ============================================================

subdomain_enum() {

    section "03 — Passive Subdomain Enumeration"

    local output="$ROOT_DIR/passive"

    while read -r domain; do

        if have subfinder; then
            subfinder \
                -d "$domain" \
                -all \
                -silent \
                >> "$output/subfinder.txt" || true
        fi

        if have assetfinder; then
            assetfinder \
                --subs-only "$domain" \
                >> "$output/assetfinder.txt" || true
        fi

        if have findomain; then
            findomain \
                -t "$domain" \
                --quiet \
                >> "$output/findomain.txt" || true
        fi

        if have amass; then
            amass enum \
                -passive \
                -d "$domain" \
                -o "$output/amass-${domain}.txt" \
                >/dev/null 2>&1 || true
        fi

        if have github-subdomains && [[ "$RUN_GITHUB" != "no" ]]; then

            github-subdomains \
                -d "$domain" \
                -raw \
                -o "$output/github-${domain}.txt" \
                >/dev/null 2>&1 || true

        fi

    done < "$ROOT_DIR/scope/domains.txt"

    cat "$output"/*.txt 2>/dev/null \
        | sed 's/\*\.//g' \
        | tr '[:upper:]' '[:lower:]' \
        | grep -E '^[a-z0-9._-]+\.[a-z]{2,}$' \
        | sort -u \
        > "$ROOT_DIR/subdomains/passive-all.txt"

    good "Passive subdomains: $(wc -l < "$ROOT_DIR/subdomains/passive-all.txt")"
}

# ============================================================
# BBOT
# ============================================================

bbot_enum() {

    [[ "$RUN_BBOT" == "no" ]] && return

    if ! have bbot; then
        warn "BBOT not installed — skipping."
        return
    fi

    section "04 — BBOT Attack-Surface Discovery"

    while read -r domain; do

        mkdir -p "$ROOT_DIR/raw/bbot"

        bbot \
            -t "$domain" \
            -p subdomain-enum \
            -o "$ROOT_DIR/raw/bbot" \
            -n "bbot-${domain}" \
            || warn "BBOT failed for $domain."

    done < "$ROOT_DIR/scope/domains.txt"
}

# ============================================================
# DNS Resolution
# ============================================================

resolve_domains() {

    section "05 — DNS Resolution"

    local input="$ROOT_DIR/subdomains/passive-all.txt"
    local output="$ROOT_DIR/dns/resolved.txt"

    if have puredns && [[ -n "$RESOLVERS" && -f "$RESOLVERS" ]]; then

        puredns resolve \
            "$input" \
            --resolvers "$RESOLVERS" \
            --write "$output" \
            || true

    elif have dnsx; then

        dnsx \
            -l "$input" \
            -silent \
            -a \
            -resp \
            -o "$output" \
            || true

    else

        warn "puredns/dnsx unavailable."

        cp "$input" "$output"

    fi

    sort -u "$output" -o "$output"

    good "Resolved names: $(wc -l < "$output")"
}

# ============================================================
# Permutation
# ============================================================

permutation() {

    section "06 — Subdomain Permutation"

    local base="$ROOT_DIR/dns/resolved.txt"

    [[ ! -s "$base" ]] && {
        warn "No resolved domains available."
        return
    }

    if have gotator; then

        if [[ -n "$WORDLIST" && -f "$WORDLIST" ]]; then

            gotator \
                -sub "$base" \
                -perm "$WORDLIST" \
                -depth 2 \
                -mindup \
                -adv \
                -silent \
                > "$ROOT_DIR/permutations/gotator.txt" \
                || true

        else

            gotator \
                -sub "$base" \
                -depth 1 \
                -prefixes \
                -mindup \
                -silent \
                > "$ROOT_DIR/permutations/gotator.txt" \
                || true

        fi

        sort -u \
            "$ROOT_DIR/permutations/gotator.txt" \
            > "$ROOT_DIR/permutations/all.txt"

        if have puredns && [[ -n "$RESOLVERS" && -f "$RESOLVERS" ]]; then

            puredns resolve \
                "$ROOT_DIR/permutations/all.txt" \
                --resolvers "$RESOLVERS" \
                --write "$ROOT_DIR/dns/permutated-resolved.txt" \
                || true

        elif have dnsx; then

            dnsx \
                -l "$ROOT_DIR/permutations/all.txt" \
                -silent \
                > "$ROOT_DIR/dns/permutated-resolved.txt" \
                || true

        fi

        cat \
            "$ROOT_DIR/dns/resolved.txt" \
            "$ROOT_DIR/dns/permutated-resolved.txt" \
            2>/dev/null \
            | sort -u \
            > "$ROOT_DIR/subdomains/all-resolved.txt"

    else

        warn "gotator not installed — skipping permutations."

        cp "$base" "$ROOT_DIR/subdomains/all-resolved.txt"

    fi

    good "Final resolved subdomains: $(wc -l < "$ROOT_DIR/subdomains/all-resolved.txt")"
}

# ============================================================
# HTTP Fingerprinting
# ============================================================

http_probe() {

    section "07 — HTTP Discovery & Fingerprinting"

    if ! have httpx; then
        warn "httpx not installed."
        return
    fi

    httpx \
        -l "$ROOT_DIR/subdomains/all-resolved.txt" \
        -silent \
        -threads "$THREADS" \
        -status-code \
        -title \
        -tech-detect \
        -server \
        -location \
        -follow-redirects \
        -json \
        -o "$ROOT_DIR/http/httpx.json" \
        || true

    jq -r '.url' "$ROOT_DIR/http/httpx.json" \
        2>/dev/null \
        | sort -u \
        > "$ROOT_DIR/http/alive.txt"

    good "Live web targets: $(wc -l < "$ROOT_DIR/http/alive.txt")"
}

# ============================================================
# Port Scanning
# ============================================================

port_scan() {

    section "08 — Web Port Discovery"

    if ! have naabu; then
        warn "naabu not installed."
        return
    fi

    naabu \
        -list "$ROOT_DIR/subdomains/all-resolved.txt" \
        -ports "$NAABU_PORTS" \
        -c "$THREADS" \
        -silent \
        -o "$ROOT_DIR/infra/naabu.txt" \
        || true

    if have httpx && [[ -s "$ROOT_DIR/infra/naabu.txt" ]]; then

        httpx \
            -l "$ROOT_DIR/infra/naabu.txt" \
            -silent \
            -status-code \
            -title \
            -tech-detect \
            -server \
            -json \
            -o "$ROOT_DIR/http/naabu-httpx.json" \
            || true

    fi
}

# ============================================================
# Caduceus
# ============================================================

caduceus_scan() {

    [[ "$RUN_CADUCEUS" == "no" ]] && return

    if ! have caduceus; then
        warn "Caduceus not installed — skipping."
        return
    fi

    if ! have dnsx; then
        warn "dnsx required for basic IP extraction."
        return
    fi

    section "09 — Certificate / IP Correlation"

    dnsx \
        -l "$ROOT_DIR/subdomains/all-resolved.txt" \
        -a \
        -resp \
        -silent \
        > "$ROOT_DIR/infra/dns-ip.txt" \
        || true

    awk '{print $2}' "$ROOT_DIR/infra/dns-ip.txt" \
        | tr ',' '\n' \
        | grep -E '^[0-9]+\.' \
        | sort -u \
        > "$ROOT_DIR/infra/ips.txt"

    if [[ -s "$ROOT_DIR/infra/ips.txt" ]]; then

        caduceus \
            -i "$ROOT_DIR/infra/ips.txt" \
            -j \
            -p "443,4443,8443,9443" \
            > "$ROOT_DIR/infra/caduceus.jsonl" \
            || true

        good "Certificate scan completed."

    fi
}

# ============================================================
# Archives
# ============================================================

archive_enum() {

    section "10 — Historical URL Discovery"

    if have gau; then

        gau \
            --threads "$THREADS" \
            "$DOMAIN" \
            2>/dev/null \
            > "$ROOT_DIR/archives/gau.txt" \
            || true

    fi

    if have waybackurls; then

        echo "$DOMAIN" \
            | waybackurls \
            > "$ROOT_DIR/archives/waybackurls.txt" \
            || true

    fi

    if have curl; then

        curl -fsS \
            "https://web.archive.org/cdx/search/cdx?url=*.$DOMAIN/*&output=json&fl=original&collapse=urlkey" \
            2>/dev/null \
            | jq -r '.[1:][]?[0]' \
            2>/dev/null \
            | sort -u \
            > "$ROOT_DIR/archives/cdx.txt" \
            || true

    fi

    cat "$ROOT_DIR/archives"/*.txt 2>/dev/null \
        | sed '/^$/d' \
        | sort -u \
        > "$ROOT_DIR/archives/all-urls.txt"

    good "Historical URLs: $(wc -l < "$ROOT_DIR/archives/all-urls.txt")"
}

# ============================================================
# TheTimeMachine
# ============================================================

timemachine() {

    [[ "$RUN_TIMEMACHINE" == "no" ]] && return

    if ! command -v python3 >/dev/null 2>&1; then
        warn "python3 unavailable — skipping TheTimeMachine."
        return
    fi

    local ttm=""

    for candidate in \
        "$HOME/TheTimeMachine/thetimemachine.py" \
        "./TheTimeMachine/thetimemachine.py" \
        "./thetimemachine.py"; do

        if [[ -f "$candidate" ]]; then
            ttm="$candidate"
            break
        fi

    done

    if [[ -z "$ttm" ]]; then
        warn "TheTimeMachine not found."
        return
    fi

    section "11 — TheTimeMachine Historical Recon"

    mkdir -p "$ROOT_DIR/raw/thetimemachine"

    python3 "$ttm" "$DOMAIN" --fetch \
        > "$ROOT_DIR/raw/thetimemachine/fetch.txt" \
        2>&1 || true

    python3 "$ttm" "$DOMAIN" --subdomains \
        > "$ROOT_DIR/raw/thetimemachine/subdomains.txt" \
        2>&1 || true

    python3 "$ttm" "$DOMAIN" --parameters \
        > "$ROOT_DIR/raw/thetimemachine/parameters.txt" \
        2>&1 || true

    python3 "$ttm" "$DOMAIN" --backups \
        > "$ROOT_DIR/raw/thetimemachine/backups.txt" \
        2>&1 || true

    python3 "$ttm" "$DOMAIN" --listings \
        > "$ROOT_DIR/raw/thetimemachine/listings.txt" \
        2>&1 || true

}

# ============================================================
# Crawl
# ============================================================

crawl() {

    section "12 — Web Crawling"

    if [[ ! -s "$ROOT_DIR/http/alive.txt" ]]; then
        warn "No live web targets."
        return
    fi

    if have katana; then

        katana \
            -list "$ROOT_DIR/http/alive.txt" \
            -silent \
            -jc \
            -d 5 \
            -c "$THREADS" \
            > "$ROOT_DIR/crawl/katana.txt" \
            || true

    fi

    if have gospider; then

        gospider \
            -S "$ROOT_DIR/http/alive.txt" \
            -a \
            -r \
            --js \
            --sitemap \
            --robots \
            -d 5 \
            -c 10 \
            -t "$THREADS" \
            -q \
            > "$ROOT_DIR/crawl/gospider.txt" \
            || true

    fi

    cat \
        "$ROOT_DIR/crawl"/*.txt \
        "$ROOT_DIR/archives/all-urls.txt" \
        2>/dev/null \
        | grep -E '^https?://' \
        | sort -u \
        > "$ROOT_DIR/crawl/all-urls.txt"

    good "Unique URLs: $(wc -l < "$ROOT_DIR/crawl/all-urls.txt")"
}

# ============================================================
# URL Normalization
# ============================================================

normalize_urls() {

    section "13 — URL Normalization"

    local input="$ROOT_DIR/crawl/all-urls.txt"

    # Remove obvious static assets.
    grep -Eiv \
        '\.(jpg|jpeg|png|gif|svg|ico|woff|woff2|ttf|eot|css)$' \
        "$input" \
        | sort -u \
        > "$ROOT_DIR/content/interesting-urls.txt"

    # Parameterized endpoints.
    grep '?' \
        "$input" \
        | sort -u \
        > "$ROOT_DIR/content/parameterized.txt" || true

    # API-like endpoints.
    grep -Ei \
        '/(api|graphql|rest|v[0-9]+|swagger|openapi)(/|$)' \
        "$input" \
        | sort -u \
        > "$ROOT_DIR/content/api-endpoints.txt" || true

    # Sensitive extensions.
    grep -Ei \
        '\.(json|xml|yaml|yml|conf|config|ini|env|log|sql|bak|old|backup|zip|tar|gz|7z|rar|pem|key|crt|p12|pfx)$' \
        "$input" \
        | sort -u \
        > "$ROOT_DIR/content/sensitive-extensions.txt" || true

}

# ============================================================
# Parameter / Pattern Mining
# ============================================================

pattern_mining() {

    section "14 — Parameter & Attack-Surface Classification"

    local urls="$ROOT_DIR/content/parameterized.txt"

    [[ ! -s "$urls" ]] && return

    if have gf; then

        for pattern in \
            xss \
            sqli \
            ssrf \
            lfi \
            rce \
            ssti \
            redirect \
            idor \
            upload \
            debug \
            graphql \
            jwt; do

            gf "$pattern" < "$urls" \
                2>/dev/null \
                | sort -u \
                > "$ROOT_DIR/findings/gf-${pattern}.txt" \
                || true

        done

    else

        warn "gf not installed — using built-in parameter classification."

        grep -Ei \
            '[?&](url|uri|redirect|next|return|dest|destination|callback|path|file|page|template|id|user|account|query|search|q|cmd|command)=' \
            "$urls" \
            | sort -u \
            > "$ROOT_DIR/findings/high-interest-parameters.txt" \
            || true

    fi
}

# ============================================================
# JavaScript
# ============================================================

javascript_analysis() {

    section "15 — JavaScript Discovery"

    grep -Ei '\.js([?#]|$)' \
        "$ROOT_DIR/crawl/all-urls.txt" \
        | sort -u \
        > "$ROOT_DIR/js/javascript.txt" \
        || true

    if [[ ! -s "$ROOT_DIR/js/javascript.txt" ]]; then
        return
    fi

    if have subjs; then

        cat "$ROOT_DIR/http/alive.txt" \
            | subjs \
            | sort -u \
            > "$ROOT_DIR/js/subjs.txt" \
            || true

    fi

    # Extract common endpoint-like strings from URLs.
    grep -Eo \
        'https?://[^"'\'' ]+' \
        "$ROOT_DIR/js/javascript.txt" \
        2>/dev/null \
        | sort -u \
        > "$ROOT_DIR/js/js-urls.txt" \
        || true
}

# ============================================================
# Subdomain Takeover Signals
# ============================================================

takeover() {

    section "16 — Subdomain Takeover Signals"

    if ! have subzy; then
        warn "subzy not installed — skipping."
        return
    fi

    subzy run \
        --targets "$ROOT_DIR/subdomains/all-resolved.txt" \
        > "$ROOT_DIR/findings/subzy.txt" \
        2>&1 || true
}

# ============================================================
# Nuclei
# ============================================================

nuclei_scan() {

    section "17 — Nuclei Validation"

    if ! have nuclei; then
        warn "nuclei not installed — skipping."
        return
    fi

    if [[ ! -s "$ROOT_DIR/http/alive.txt" ]]; then
        warn "No HTTP targets for Nuclei."
        return
    fi

    nuclei \
        -list "$ROOT_DIR/http/alive.txt" \
        -silent \
        -severity low,medium,high,critical \
        -stats \
        -c "$THREADS" \
        -jsonl \
        -o "$ROOT_DIR/findings/nuclei.jsonl" \
        || true
}

# ============================================================
# Finding Summary
# ============================================================

generate_summary() {

    section "18 — Recon Summary"

    local summary="$ROOT_DIR/reports/summary.txt"

    {
        echo "============================================================"
        echo "                 r4vindra Recon Framework"
        echo "============================================================"
        echo
        echo "Run ID       : $RUN_ID"
        echo "Mode         : $MODE"
        echo "Started      : $(date)"
        echo
        echo "------------------------------------------------------------"
        echo "DISCOVERY"
        echo "------------------------------------------------------------"
        echo "Passive subdomains : $(wc -l < "$ROOT_DIR/subdomains/passive-all.txt" 2>/dev/null || echo 0)"
        echo "Resolved subdomains: $(wc -l < "$ROOT_DIR/subdomains/all-resolved.txt" 2>/dev/null || echo 0)"
        echo "Live HTTP targets  : $(wc -l < "$ROOT_DIR/http/alive.txt" 2>/dev/null || echo 0)"
        echo "Historical URLs    : $(wc -l < "$ROOT_DIR/archives/all-urls.txt" 2>/dev/null || echo 0)"
        echo "Unique URLs        : $(wc -l < "$ROOT_DIR/crawl/all-urls.txt" 2>/dev/null || echo 0)"
        echo
        echo "------------------------------------------------------------"
        echo "HIGH-VALUE FILES"
        echo "------------------------------------------------------------"
        echo
        echo "Parameterized:"
        echo "$ROOT_DIR/content/parameterized.txt"
        echo
        echo "API endpoints:"
        echo "$ROOT_DIR/content/api-endpoints.txt"
        echo
        echo "Sensitive extensions:"
        echo "$ROOT_DIR/content/sensitive-extensions.txt"
        echo
        echo "Nuclei:"
        echo "$ROOT_DIR/findings/nuclei.jsonl"
        echo
        echo "Subdomain takeover:"
        echo "$ROOT_DIR/findings/subzy.txt"
        echo
        echo "============================================================"

    } > "$summary"

    cat "$summary"

}

# ============================================================
# Final dashboard
# ============================================================

dashboard() {

    local end
    local duration

    end=$(date +%s)
    duration=$((end - START_TIME))

    section "19 — Recon Complete"

    good "Run completed in ${duration}s"

    echo
    echo -e "${WHITE}Workspace:${NC}"
    echo
    echo "  $ROOT_DIR"
    echo

    echo -e "${WHITE}Important files:${NC}"
    echo
    echo "  scope/domains.txt"
    echo "  subdomains/all-resolved.txt"
    echo "  http/alive.txt"
    echo "  infra/naabu.txt"
    echo "  archives/all-urls.txt"
    echo "  crawl/all-urls.txt"
    echo "  content/parameterized.txt"
    echo "  content/api-endpoints.txt"
    echo "  content/sensitive-extensions.txt"
    echo "  findings/"
    echo "  reports/summary.txt"
    echo

    echo -e "${GREEN}Next step:${NC}"
    echo "Review findings manually and validate anything interesting."
    echo
}

# ============================================================
# Pipeline
# ============================================================

main() {

    banner

    prepare_scope

    crtsh

    subdomain_enum

    if [[ "$MODE" != "passive" ]]; then

        bbot_enum

        resolve_domains

        permutation

        http_probe

        port_scan

        caduceus_scan

        archive_enum

        timemachine

        crawl

        normalize_urls

        pattern_mining

        javascript_analysis

        takeover

        nuclei_scan

    fi

    generate_summary

    dashboard
}

main "$@"
