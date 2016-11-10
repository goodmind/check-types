module Types
  class Render
    enum Kind
      TypeScript
      TComb
    end

    def initialize(kind : String)
      @kind = case kind
        when "typescript"
          Kind::TypeScript
        when "tcomb"
          Kind::TComb
        else
          raise "Unknown render: #{kind}"
      end
    end

    def print(field : String, field_type : Hash(String, Field))
      case @kind
        when Kind::TypeScript
          typescript(field, field_type)
        when Kind::TComb
          tcomb(field, field_type)
      end
    end

    def typescript(field, field_type)

    end

    def tcomb(field, field_type)

    end
  end
end
