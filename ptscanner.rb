require 'socket'
require 'timeout'
require 'resolv'

$stdout.sync = true
$mutex = Mutex.new

COMMON_PORTS = [21, 22, 23, 25, 53, 80, 110, 135, 139, 143, 443, 445, 993, 995, 1723, 3306, 3389, 5900, 8080]

def print_banner
  banner = <<-BANNER
    ____  _____ ____   ____    _    _   _ _   _ _____ ____  
   |  _ \\|_   _/ ___| / ___|  / \\  | \\ | | \\ | | ____|  _ \\ 
   | |_) | | | \\___ \\| |     / _ \\ |  \\| |  \\| |  _| | |_) |
   |  __/  | |  ___) | |___ / ___ \\| |\\  | |\\  | |___|  _ < 
   |_|     |_| |____/ \\____/_/   \\_\\_| \\_|_| \\_|_____|_| \\_\\
                                                            
  BANNER
  puts banner
end

def print_info
  puts "       =[              PTSCANNER v1.0.0              ]"
  puts "+ -- --=[           Port scanning made easy          ]"
  puts "+ -- --=[            Scanning common ports           ]"
  puts "PTSCANNER tip: Use 'help' to see available commands"
  puts
end

def scan_port(ip, port, timeout = 1)
  begin
    Timeout::timeout(timeout) do
      TCPSocket.new(ip, port).close
      $mutex.synchronize { puts "Port #{port} is open" }
      return :open
    end
  rescue Errno::ECONNREFUSED
    return :closed
  rescue Timeout::Error
    return :filtered
  rescue SocketError => e
    $mutex.synchronize { puts "Error scanning port #{port}: #{e.message}" }
    return :error
  rescue => e
    $mutex.synchronize { puts "Unexpected error scanning port #{port}: #{e.message}" }
    return :error
  end
end

def scan_ports(ip, threads = 10)
  puts "Scanning common ports on #{ip}"
  results = { open: 0, closed: 0, filtered: 0, error: 0 }
  total_ports = COMMON_PORTS.length
  scanned_ports = 0

  COMMON_PORTS.each_slice(threads) do |ports|
    threads = ports.map do |port|
      Thread.new do
        result = scan_port(ip, port)
        results[result] += 1
        scanned_ports += 1
      end
    end
    threads.each(&:join)
  end

  puts "\nScan complete. Results:"
  results.each { |status, count| puts "#{status.capitalize}: #{count}" }
end

def main_loop
  loop do
    print "ptscanner > "
    input = gets.chomp.split
    command = input.shift

    case command
    when "exit", "quit"
      puts "Exiting PTSCANNER..."
      break
    when "scan"
      if input.length != 1
        puts "Usage: scan <hostname/ip>"
      else
        hostname = input[0]
        begin
          ip = Resolv.getaddress(hostname)
          puts "Resolved #{hostname} to #{ip}"
          scan_ports(ip)
        rescue Resolv::ResolvError => e
          puts "Could not resolve hostname: #{e.message}"
        end
      end
    when "help"
      puts "Available commands:"
      puts "scan <hostname/ip> - Scan common ports on specified host"
      puts "help - Show this help message"
      puts "ports - Define common ports"
      puts "exit/quit - Exit PTSCANNER"
    when "ports"
      puts "Port 21 (FTP): Used for File Transfer Protocol, which allows for the transfer of files between systems."
      puts "Port 22 (SSH): Secure Shell, commonly used for secure logins and data transfers over networks."
      puts "Port 23 (Telnet): Used for the Telnet protocol, enabling remote access to servers in a non-encrypted form (less secure than SSH)."
      puts "Port 25 (SMTP): Simple Mail Transfer Protocol, used for sending emails."
      puts "Port 53 (DNS): Domain Name System, used for translating domain names to IP addresses."
      puts "Port 80 (HTTP): Hypertext Transfer Protocol, the standard protocol for web traffic on the internet."
      puts "Port 110 (POP3): Post Office Protocol 3, used by email clients to retrieve messages from a mail server."
      puts "Port 135 (RPC): Remote Procedure Call, often used in Windows environments for various network services."
      puts "Port 139 (NetBIOS): Network Basic Input/Output System, used for file and printer sharing in Windows."
      puts "Port 143 (IMAP): Internet Message Access Protocol, used by email clients to retrieve and manage messages on a server."
      puts "Port 443 (HTTPS): HTTP Secure, used for encrypted web traffic."
      puts "Port 445 (SMB): Server Message Block, used for file sharing in Windows."
      puts "Port 993 (IMAP over SSL): Secure IMAP, for encrypted email retrieval."
      puts "Port 995 (POP3 over SSL): Secure POP3, for encrypted email retrieval."
      puts "Port 1723 (PPTP): Point-to-Point Tunneling Protocol, used for VPNs."
      puts "Port 3306 (MySQL): Default port for MySQL database connections."
      puts "Port 3389 (RDP): Remote Desktop Protocol, used for remote access to Windows systems."
      puts "Port 5900 (VNC): Virtual Network Computing, used for remote desktop access."
      puts "Port 8080 (HTTP Alternative): Often used as an alternative to port 80 for web traffic or for proxy servers."
    else
      puts "Unknown command. Type 'help' for available commands."
    end
  end
end


# Main execution
system("clear") || system("cls")  # Clear the screen
print_banner
print_info
main_loop