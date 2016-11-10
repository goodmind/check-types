require "../store"

def update_file(key, cmd, success, error)
  begin
    File.write(Store.get(key), cmd)
  rescue e : Exception
    puts Command.chalk.red(" ✖ #{error}")
    puts Command.chalk.red("#{e}")
  else
    puts Command.chalk.green(" ✔ #{success}")
  end
end

def update_remote_file
  update_file(
    "update_remote_file",
    `curl -s https://core.telegram.org/bots/api | html2text -ascii -nobs -style pretty`,
    "Remote file successfully updated!",
    "Remote file not updated"
  )
end

def update_local_file(dir)
  update_file(
    "update_local_file",
    `remote-types #{dir}`,
    "Local file successfully updated!",
    "Local file not updated"
  )
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
