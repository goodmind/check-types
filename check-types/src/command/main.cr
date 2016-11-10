require "../types"

class Command
  private def main(argv)
    dir = File.expand_path(argv[0])
    r = Types::Remote.new
    l = Types::Local.new(dir)

    Types.check(l, r)
  end
end
