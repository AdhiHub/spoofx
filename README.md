# SpoofX v1.0

**ARP Spoofing & MITM Packet Sniffer**

Discover live hosts, perform ARP spoofing attacks, and sniff network traffic. Works with or without dedicated tools installed.

## One-Line Install

```bash
curl -sL https://raw.githubusercontent.com/AdhiHub/spoofx/main/install.sh | sudo bash
```

## Features

| Feature | Description |
|---------|-------------|
| ARP Scan | Discover live hosts via arp-scan, arping, or ping sweep |
| ARP Spoof | MITM between target and gateway |
| Traffic Sniff | Capture packets with tcpdump |
| ARP Restore | Reset ARP tables and stop spoofing |
| Fallback Mode | Shows manual commands if tools are not installed |
| Logging | All activity saved to timestamped log |

## Usage

```bash
# Interactive menu (requires root)
sudo ./spoofx.sh

# Show help
./spoofx.sh -h
```

Menu options:
1. **ARP Scan** - Scan subnet for live hosts
2. **ARP Spoof** - Spoof target and gateway (MITM)
3. **Sniff Traffic** - Capture packets on an interface
4. **Restore ARP** - Reset ARP tables to normal state
5. **Help** - Usage information

## Requirements

- Bash 4+
- curl
- Root privileges
- Optional: arp-scan, arpspoof (dsniff), tcpdump

Works on **Linux** and **Termux** (Android) with root.

## Disclaimer

```
Use at your own risk. Developer(s) assume NO liability.
For authorized testing only on networks you own or have written permission.
```
