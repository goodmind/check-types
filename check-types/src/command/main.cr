require "../types"

class Command
  private def main(argv, selected)
    puts selected

    dir = File.expand_path(argv[0])
    r = Types::Remote.new
    l = Types::Local.new(dir, selected)

    Types.check(l, r)
  end
end
