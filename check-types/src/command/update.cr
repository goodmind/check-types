require "../store"

def update_remote_file
  File.write(Store.get("update_remote_file"), `curl -s https://core.telegram.org/bots/api | html2text -ascii -nobs -style pretty`)
  puts Command.chalk.green(" ✔ Remote file successfully updated!")
end

def update_local_file(dir)
  File.write(Store.get("update_local_file"), `remote-types #{dir}`)
  puts Command.chalk.green(" ✔ Local file successfully updated!")
end

class Command
  private def update
    Store.set("update_remote_file", Store.get("remote_file"))
    Store.set("update_local_file", Store.get("local_file"))

    OptionParser.parse(options) do |parser|
      parser.banner = "Usage: check-types update [arguments]"
      parser.on("-r FILE", "--remote=FILE", "File from cURL") { |file| Store.set("update_remote_file", file) }
      parser.on("-l FILE", "--local=FILE", "File from TypeScript") { |file| Store.set("update_local_file", file) }
      parser.on("-h", "--help", "Show this help") {
        puts parser
        exit
      }

      parser.unknown_args do |argv, a|
        update_remote_file
        update_local_file(File.expand_path(argv.first)) if argv.first?
      end
    end
  end
end
