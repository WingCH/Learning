# Project Brief

## Overview
Building a secure proxy that routes specific domains through a Tailscale VPN using Docker and Surge. This solution isolates the Tailscale VPN in a Docker container to avoid conflicts with macOS’s network extension.

## Core Features
- **Tailscale VPN in Docker**: Run Tailscale inside a Docker container in userspace mode on macOS.
- **Domain Routing**: Use Surge to route traffic for specific domains through the Tailscale VPN.
- **Isolation**: Ensure that the Tailscale VPN does not conflict with other VPN solutions like Surge.

## Target Users
- Developers or teams that need to securely route traffic for specific domains through a Tailscale VPN while maintaining a separate network configuration.

## Technical Preferences (optional)
- **Docker**: Tailscale running in Docker for macOS.
- **Surge**: Used to configure domain routing through Tailscale.
- **No Auth Key Access**: Use Google Sign-In for Tailscale authentication (if auth keys are not available).