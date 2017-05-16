require "../spec_helper"

require "tempfile"

describe HostsFile::Line do
  describe ".parse" do
    it "correctly parses comments" do
      parsed_line = HostsFile::Line.parse("# this is a comment\n")
      parsed_line.should be_a(HostsFile::Line::Comment)
    end

    it "correctly parses an empty line with tabs" do
      parsed_line = HostsFile::Line.parse("\t\t")
      parsed_line.should be_a(HostsFile::Line::Empty)
    end

    it "correctly parses an empty line with spaces" do
      parsed_line = HostsFile::Line.parse("\ \t")
      parsed_line.should be_a(HostsFile::Line::Empty)
    end

    it "correctly parses a completely empty line" do
      parsed_line = HostsFile::Line.parse("\t\t")
      parsed_line.should be_a(HostsFile::Line::Empty)
    end

    it "correctly parses a normal line" do
      ip = IPAddress.parse("1.2.3.4")
      hostname = "hostname"

      parsed_line = HostsFile::Line.parse("#{ip} #{hostname}")
      parsed_line.should be_a(HostsFile::Line::Entry)

      entry = parsed_line.as(HostsFile::Line::Entry)

      entry.ip.should eq(ip)
      entry.hostnames.should contain(hostname)
    end
  end
end
