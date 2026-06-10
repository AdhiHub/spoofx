# SPOOFX — ARP Spoofing & MITM Toolkit

**Discover live hosts on a network, perform ARP spoofing attacks, and sniff traffic.**

Part of the **AdhiHub** security toolkit.

---

## What It Does

| Mode | What It Does |
|------|-------------|
| **ARP Scan** | Scans your local network to find live hosts and their IP/MAC addresses |
| **ARP Spoof** | Convinces the target and gateway you're the other one (MITM) — traffic flows through your machine |
| **Sniff Traffic** | Captures packets flowing through your interface so you can inspect them |
| **Restore ARP** | Restores the network to normal state when you're done |

If tools like `arp-scan` or `arpspoof` are installed: SpoofX uses them.
If not: SpoofX shows you the **exact manual commands** to copy-paste.

---

## One-Line Install

```bash
curl -fsSL https://raw.githubusercontent.com/AdhiHub/spoofx/main/install.sh | bash
```

After install:

```bash
sudo spoofx
```

---

## How to Use

**Root is required** for ARP operations.

```bash
# Interactive menu
sudo spoofx

# Help
spoofx -h
```

### Menu Options

1. **ARP Scan** — Enter your network (e.g. `192.168.1.0/24`) to discover live hosts
2. **ARP Spoof** — Enter target IP and gateway IP to start MITM
3. **Sniff Traffic** — Enter interface name (e.g. `wlan0`) to capture packets
4. **Restore ARP** — Enter target IP and gateway IP to clean up

---

## Step-by-Step Example

```
1) ARP Scan
   Enter network: 192.168.1.0/24
   [+] Found: 192.168.1.1 (gateway)
   [+] Found: 192.168.1.105 (target)

2) ARP Spoof
   Target IP: 192.168.1.105
   Gateway IP: 192.168.1.1
   [+] Spoofing started... traffic now flows through you

3) Sniff Traffic
   Interface: wlan0
   [+] Capturing packets... (saved to capture.pcap)

4) Restore ARP
   Target IP: 192.168.1.105
   Gateway IP: 192.168.1.1
   [+] ARP tables restored
```

---

## Requirements

- **Linux** or **Termux** (Android) with **root**
- Bash 4+
- Optional: arp-scan, arpspoof (dsniff), tcpdump

---

## Run Without Installing

```bash
git clone https://github.com/AdhiHub/spoofx.git
cd spoofx
chmod +x spoofx.sh
sudo ./spoofx.sh
```

---

> **⚠️ DISCLAIMER: FOR EDUCATIONAL PURPOSES ONLY**
>
> Use at your own risk. Developer(s) assume NO liability.
> Only use on networks you own or have explicit written permission to test.
> ARP spoofing without permission is illegal in most jurisdictions.
