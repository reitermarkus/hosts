require "./line/*"

class Hosts
  module Line
    def self.parse(line : String)
      case line
      when /\A\s*\Z/
        Empty.new(line)
      when /\A\s*\#/
        Comment.new(line)
      else
        Entry.new(line)
      end
    end

    getter :raw
    @raw : String

    def empty?
      self.is_a? Empty
    end

    def entry?
      self.is_a? Entry
    end

    def comment?
      self.is_a? Comment
    end

    def initialize(line)
      @raw = line
    end
  end
end
