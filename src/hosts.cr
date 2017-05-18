#!/usr/bin/env crystal

require "./hosts_file"

action : Symbol | Nil = nil
hostname : String | Nil = nil
ip : String | Nil = nil
file = "/etc/hosts"

OptionParser.parse! do |parser|
  parser.banner = "Usage: #{File.basename(__FILE__, ".cr")} [arguments]"
  parser.on("-l", "--list", "List hosts entries.") { action = :list }
  parser.on("-a", "--add", "Add hosts entry.") { action = :add }
  parser.on("-d", "--delete", "Delete hosts entry.") { action = :delete }
  parser.on("-h HOSTNAME", "--hostname HOSTNAME", "Hostname") { |h| hostname = h }
  parser.on("-i IP", "--ip IP", "IP address") { |i| ip = i }
  parser.on("-f FILE", "--file FILE", "Hosts file") { |f| file = f }
end

hosts = HostsFile.new(file)

begin
  case action
  when :add
    hosts.add(hostname.not_nil!, ip.not_nil!)
  when :delete
    hosts.delete(hostname.not_nil!)
  when :list
    hosts.entries.each do |ip, hostnames|
      puts ip.to_s

      hostnames.each do |hostname|
        puts "  #{hostname}"
      end
    end
  else
    STDERR.puts "Error: Action argument -a or -r required."
    exit(1)
  end
rescue e
  STDERR.puts e
  exit(1)
end
