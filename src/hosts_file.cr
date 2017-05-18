require "ipaddress"

require "tempfile"
require "file_utils"

require "option_parser"

require "./hosts_file/*"

class HostsFile
  getter :file

  IP_LENGTH = 15

  def initialize(file)
    @file = File.expand_path(file)
  end

  protected def lines
    lines = [] of Line
    each_line { |l| lines << l }
    lines
  end

  protected def each_line
    File.open(file, "r") do |f|
      while line = f.gets
        yield Line.parse(line)
      end
    end
  end

  def add(hostname : IPAddress | String, ip : IPAddress | String)
    ip = IPAddress.parse(ip) if ip.is_a?(String)

    if hostname.is_a?(String)
      begin
        hostname = IPAddress.parse(hostname)
      rescue ArgumentError
      end
    end

    each_line do |line|
      next unless line.entry?

      next unless line.as(Line::Entry).ip == ip
      next unless line.as(Line::Entry).hostnames.includes?(hostname)

      puts line.as(Line::Entry).to_s

      raise "Already in hosts file."
    end

    File.open(file, "a") do |f|
      f.puts ip.to_s.ljust(IP_LENGTH, ' ') + " " + hostname.to_s
    end
  end

  def delete(hostname : IPAddress | String)
    changed = false

    new_contents = lines.map { |line|
      if line.entry?
        entry = line.as(Line::Entry)

        if entry.hostnames.includes?(hostname)
          changed = true

          entry.hostnames.delete(hostname)
          next if entry.hostnames.empty?

          ip_string = Regex.escape(entry.ip.to_s)
          hostnames_string = entry.hostnames.map { |hn| hn.to_s }.join(" ")
          changed_line = entry.raw.sub(/\A(\s*#{ip_string}\s+)(?:[^\s]+(?:\s+[^\s\#]+)*)/, "\\1#{hostnames_string}")

          line = Line::Entry.new(changed_line)
        end
      end

      line
    }.compact.map { |l| l.raw }.join("\n")

    unless changed
      return
    end

    tempfile = Tempfile.open("foo") { |f|
      f.puts new_contents
    }

    # atomically overwrite existing file
    FileUtils.mv tempfile.path, file
  end
end
