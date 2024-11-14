require 'socket'
require 'timeout'
require 'resolv'

$stdout.sync = true  
$mutex = Mutex.new   

def scan_port(ip, port, timeout = 1)
  begin
    Timeout::timeout(timeout) do
      TCPSocket.new(ip, port).close
      $mutex.synchronize { puts "Port #{port} is open" }
      return :open
    end
  rescue Errno::ECONNREFUSED
    $mutex.synchronize { puts "Port #{port} is closed" }
    return :closed
  rescue Timeout::Error
    $mutex.synchronize { puts "Port #{port} timed out" }
    return :filtered
  rescue SocketError => e
    $mutex.synchronize { puts "Error scanning port #{port}: #{e.message}" }
    return :error
  rescue => e
    $mutex.synchronize { puts "Unexpected error scanning port #{port}: #{e.message}" }
    return :error
  end
end

def scan_ports(ip, start_port, end_port, threads = 10)
  puts "Scanning ports #{start_port} to #{end_port} on #{ip}"
  results = { open: 0, closed: 0, filtered: 0, error: 0 }
  total_ports = end_port - start_port + 1
  scanned_ports = 0

  (start_port..end_port).each_slice(threads) do |ports|
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


hostname = 'example.com'  
start_port = 1
end_port = 100  

begin
  ip = Resolv.getaddress(hostname)
  puts "Resolved #{hostname} to #{ip}"
  scan_ports(ip, start_port, end_port)
rescue Resolv::ResolvError => e
  puts "Could not resolve hostname: #{e.message}"
end