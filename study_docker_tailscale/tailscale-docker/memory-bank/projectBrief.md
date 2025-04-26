Here’s the updated **Project Brief** with a focus solely on the Tailscale Docker setup, excluding Surge configuration:

# Project Brief

## Overview
This project involves running Tailscale in a Docker container on macOS to securely route traffic through a VPN, ensuring the solution works without interfering with macOS's native network extensions. The setup is designed to allow domain-specific routing, but the focus is on the isolated and functional Tailscale setup inside Docker.

## Core Features
- **Tailscale in Docker**: Running Tailscale inside a Docker container using userspace networking on macOS.
- **Tailscale Authentication**: Use Google Sign-In for authentication or generate an auth key for Tailscale login.
- **Isolated Network Configuration**: Ensuring Tailscale runs separately from other VPN tools like Surge to prevent conflicts.
- **Userspace Networking**: Because macOS Docker Desktop does not support TUN/TAP, the setup uses userspace networking to bypass this limitation.

## Target Users
- Developers or teams who require a secure Tailscale VPN setup within a Docker container on macOS, without conflicting with other network tools or VPNs.

## Technical Preferences (optional)
- **Docker**: The Tailscale Docker image `tailscale/tailscale` will be used for the container.
- **Userspace Networking**: Use userspace networking since macOS Docker Desktop doesn't support TUN/TAP.
- **Authentication**: Use Google Sign-In for authentication, or generate an auth key for use in Docker.
- **macOS**: The solution is designed to work on macOS with Docker Desktop.

---

### SOCKS5 Proxy Info for Surge Setup

Once Tailscale is running and you have the SOCKS5 proxy set up, you can configure Surge to route traffic through the Tailscale VPN using the following details:

- **SOCKS5 Proxy Host**: `localhost`
- **SOCKS5 Proxy Port**: `<port_number>` (e.g., `1080`)

Use this SOCKS5 proxy information to configure Surge or any other network-related tool that supports SOCKS5 proxying.
