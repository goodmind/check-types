require "json"
require "../store"
require "../utils"

module Types
  extend self

  class Local
    @types : Array(String)

    def initialize(dir : String)
      @dir = dir
      @foreign_types = [
        "Request",
        "UpdateCallbackQuery",
        "UpdateChosenInlineResult",
        "UpdateInlineQuery",
        "UpdateMessage",
        "UpdatesState",
        "WebhookInfo",
        "WebhookResponse"
      ]
      @types = parse(read(dir))
      @fields = JSON.parse(file_safe(Store.get("local_file"))) # JSON.parse(`remote-types #{dir}`)
    end

    def fields
      @fields
    end

    def types
      @types
    end

    def read(dir)
      types = ""
      Dir.glob("#{dir}/*.ts") do |ts_file|
        types += File.read(ts_file)
      end
      return types
    end

    def parse(types)
      return types
        .lines
        .grep(/export const/)
        .map { |str| str.gsub(/export const (.*)=( )?(.*)?\n/, "\\1") }
        .map { |str| str.strip }
        .sort_by! { |str| str.downcase } - @foreign_types
    end
  end
end
