# Clementinose Proxmox Utils
A collection of terminal tools to manage Proxmox nodes, LXC containers, and monitor node statistics like power usage, temperature, fan speeds, and network usage—all from your terminal.
🟢 Features
- LXC SSH setup – Easily configure SSH access to your containers.
- Proxmox SSH setup – Configure SSH access for your Proxmox nodes.
- Node Power Monitor – Display actual power consumption with monthly/yearly estimates.
- Node Temperature Monitor – Check CPU and system temperatures.
- Node Fan Monitor – Monitor fan speeds in real-time.
- Node Network Monitor – See network usage in MB, GB, TB, and get hourly, daily, monthly, yearly estimates.
- One-line installation – Run the entire menu in one command.
⚡ How to Run
1. Cool UI Version
This is the modern, enhanced terminal menu with a better UI:
```bash
bash <(curl -fsSL "https://raw.githubusercontent.com/Clementinose/proxmox-utils/main/menu.sh?t=$(date +%s)")
