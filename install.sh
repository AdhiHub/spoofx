#!/bin/bash

RED='\033[1;31m'; GREEN='\033[1;32m'; CYAN='\033[1;36m'; YELLOW='\033[1;33m'; RESET='\033[0m'

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[!] Please run as root (sudo)${RESET}"
    exit 1
fi

echo -e "${CYAN}[*] Installing SpoofX v1.0...${RESET}"

if command -v apt &>/dev/null; then
    apt update && apt install curl -y
elif command -v pkg &>/dev/null; then
    pkg update && pkg install curl -y
fi

curl -sL "https://raw.githubusercontent.com/AdhiHub/spoofx/main/spoofx.sh" -o /usr/local/bin/spoofx.sh 2>/dev/null || {
    echo -e "${RED}[!] Download failed. Check internet connection.${RESET}"
    exit 1
}

chmod +x /usr/local/bin/spoofx.sh

echo -e "${GREEN}[✓] SpoofX installed successfully!${RESET}"
echo -e "${CYAN}Run: sudo spoofx.sh${RESET}"
echo ""
echo -e "${YELLOW}DISCLAIMER: Use at your own risk. Developer(s) assume NO liability.${RESET}"
