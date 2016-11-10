require "../store"
require "../utils"

module Types
  class Remote
    @types : Array(String)

    def initialize
      @isempty = /^\s*$/
      @istype = /This object|Upon receiving|Represents|You can provide|A placeholder/
      @isparam = /^\s*([a-z0-9_]+)\s+([A-Z][a-z]+).*(Optional\.)?[A-Z].*$/
      @hasfields = /Field/
      @accept = /^[A-Z][A-Z0-9a-z]+$/
      @fields = Hash(String, Array(String)).new
      @field_types = Hash(String, Hash(String, Field)).new
      @types = parse(read())
    end

    def field_types
      @field_types
    end

    def fields
      @fields
    end

    def types
      @types
    end

    private def search_params(type : String, file : Array(String), i : Int)
      @fields[type] = [] of String
      @field_types[type] = Hash(String, Field).new
      loop {
        m = file[i].match(@isparam)
        if m
          s = m.to_s.match(/Optional/)
          @fields[type].push(m[1])
          @field_types[type][m[1]] = { type: m[2], opt: (s[0] if s) }
        end
        if file[i].match(@isempty)
          return i - 1
        end
        i += 1
      }
    end

    private def search_method(file : Array(String), i : Int)
      start = i
      last = nil
      until file[i].match(@accept)
        return nil if i == 0
        last = file[i]
        i -= 1
      end
      last = file[i]
      return search_params(last, file, start+1)
    end

    def read() : Array(String)
      text = file_safe(Store.get("remote_file")).split("\n")
      #text = `curl -s https://core.telegram.org/bots/api | html2text -ascii -nobs -style pretty`.split("\n")
      types = [] of String

      text.each_with_index { |c, i|
        line = text[i]
        if line.match(@istype)
          types.push(text[i - 2])
        end
      }

      text.each_with_index { |c, i|
        line = text[i]
        if line.match(@hasfields)
          i = search_method(text, i)
        end
      }

      return types
    end

    def parse(types) : Array(String)
      return types
        .map { |str| str.strip }
        .reject { |str| str.empty? }
        .sort_by! { |str| str.downcase }
    end
  end
end
