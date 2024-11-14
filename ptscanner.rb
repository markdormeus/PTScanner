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
  puts "       =[ PTSCANNER v1.0.0                              ]"
  puts "+ -- --=[ Port scanning made easy                        ]"
  puts "+ -- --=[ Scanning common ports                          ]"
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
        $mutex.synchronize { print "\rProgress: #{(scanned_ports.to_f / total_ports * 100).round(2)}% complete\n" }
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
      puts "  scan <hostname/ip> - Scan common ports on specified host"
      puts "  help - Show this help message"
      puts "  exit/quit - Exit PTSCANNER"
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