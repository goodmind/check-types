require "option_parser"
require "chalk_box"

require "./command/*"
require "../store"

class Command
  extend ChalkBox

  @selection = [] of String

  def initialize(@options : Array(String))
    Store.set("remote_file", "botapidoc.txt")
    Store.set("local_file", "botlocaltypes.txt")
  end

  def options
    @options
  end

  def run
    OptionParser.parse(options) do |parser|
      parser.banner = "Usage: check-types [arguments] [dir]"
      parser.on("-r FILE", "--remote=FILE", "File from cURL") { |file| Store.set("remote_file", file) }
      parser.on("-l FILE", "--local=FILE", "File from TypeScript") { |file| Store.set("local_file", file) }
      parser.on("-s ARRAY", "--select", "Some types") { |arr|
        selection = JSON.parse(arr)
        @selection = selection.map { |s| s.to_s }
      }
      parser.on("-ts", "--typescript", "TypeScript render") {}
      parser.on("-tc", "--tcomb", "TComb render") {}
      parser.on("-h", "--help", "Show this help") {
        puts parser
        exit
      }

      parser.unknown_args do |argv, a|
        if options.empty?
          puts parser
          exit
        end

        command = options.first?

        if command
          case
          when "update".starts_with?(command)
            options.shift
            update
          else
            main(argv, @selection)
          end
        end
      end
    end
  end
end
