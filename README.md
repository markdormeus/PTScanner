# PTScanner

PTScanner is a Ruby-based port scanning tool with a command-line interface inspired by Metasploit. It's designed to scan common ports on specified hosts, providing a user-friendly interface and visual feedback during the scanning process.

## Features

- Metasploit-like command-line interface
- Scans a predefined list of common ports
- Multi-threaded scanning for improved performance
- Visual progress bar to track scanning progress
- DNS resolution for hostnames
- Detailed results output

## Installation

1. Ensure you have Ruby installed on your system.
2. Clone this repository.
3. Navigate to the project directory on your host.

## Usage

Run the script:
```bash
ruby ptscanner.rb
```
Once the PTScanner interface loads, you can use the following commands:

- `scan <hostname/ip>`: Scan common ports on the specified host
- `help`: Display available commands
- `exit` or `quit`: Exit PTScanner

Example:
```bash
ptscanner> scan example.com
```
## Common Ports Scanned

PTScanner checks the following ports by default:
21, 22, 23, 25, 53, 80, 110, 135, 139, 143, 443, 445, 993, 995, 1723, 3306, 3389, 5900, 8080.

## Disclaimer

This tool is for educational purposes only. Ensure you have permission before scanning any networks or systems you do not own. Unauthorized port scanning may be illegal in some jurisdictions.
