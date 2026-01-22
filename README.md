# cisco-umbrella-watcher

A macOS background agent that automatically enables Cisco Umbrella when Cisco Secure Client is running, and disables it when the client closes.

## Why?

Cisco Umbrella can interfere with local development and certain network configurations. This tool automatically toggles Umbrella protection based on whether you have the Cisco Secure Client (VPN) open, so you get protection when connected to VPN but not when working locally.

## Requirements

- macOS
- Xcode Command Line Tools (for Swift compiler)
- Cisco Secure Client installed

## Installation

### 1. Install umbrellactl

```bash
sudo make install-umbrellactl
```

### 2. Configure passwordless sudo for umbrellactl

```bash
sudo make setup-sudoers
```

This creates `/etc/sudoers.d/umbrellactl` allowing your user to run `umbrellactl` without a password.

### 3. Build and install the watcher binary

```bash
make
sudo make install
```

### 4. Install and start the launch agent

```bash
make install-agent
```

## Usage

Once installed, the agent runs automatically in the background. It will:

- **Enable Umbrella** (`umbrellactl -e`) when Cisco Secure Client launches
- **Disable Umbrella** (`umbrellactl -d`) when Cisco Secure Client closes
- Show macOS notifications for each action

## Make targets

| Target | Description |
|--------|-------------|
| `make` | Build the watcher binary |
| `sudo make install` | Install watcher binary to `/usr/local/bin` |
| `sudo make install-umbrellactl` | Install umbrellactl to `/usr/local/bin` |
| `sudo make setup-sudoers` | Configure passwordless sudo for umbrellactl |
| `make install-agent` | Install and load the launch agent |
| `make uninstall-agent` | Unload and remove the launch agent |
| `make restart` | Restart the launch agent |
| `sudo make uninstall` | Remove watcher binary from `/usr/local/bin` |
| `sudo make uninstall-umbrellactl` | Remove umbrellactl from `/usr/local/bin` |
| `sudo make remove-sudoers` | Remove sudoers configuration |
| `make clean` | Remove locally built binary |

## Logs

Logs are written to:
- `/tmp/cisco-umbrella-watcher.out` (stdout)
- `/tmp/cisco-umbrella-watcher.err` (stderr)

## Uninstallation

```bash
make uninstall-agent
sudo make uninstall
sudo make uninstall-umbrellactl
sudo make remove-sudoers
```

## Supported Cisco Client versions

- Cisco AnyConnect (`com.cisco.anyconnect.gui`) - version 5.1.2.x and earlier
- Cisco Secure Client (`com.cisco.secureclient.gui`) - version 5.1.3.x and later
