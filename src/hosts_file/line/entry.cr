class HostsFile
  module Line
    class Entry
      include Line

      getter :ip
      @ip : IPAddress

      getter :hostnames
      @hostnames = [] of IPAddress | String

      def initialize(line)
        super(line)

        m = raw.match(/\A\s*([^\s]+)\s+([^\#]+).*\Z/).not_nil!
        @ip = IPAddress.parse(m[1])
        @hostnames = m[2].split(/\s+/).map { |hn|
          IPAddress.parse(hn).as(IPAddress) rescue hn
        }
      end
    end
  end
end
