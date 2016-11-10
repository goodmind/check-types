require "chalk_box"
require "./types/*"

module Types
  extend ChalkBox
  extend self

  alias Field = NamedTuple(type: String, opt: String | Nil)
  alias FieldError = NamedTuple(fields: Array(String), type: String)

  def Types.check(local, remote)
    diff = remote.types - local.types

    unless diff.empty?
      puts chalk.red(" ✖ Missing types")
      puts chalk.red("   -------------")
      diff.each { |type|
        puts "   #{type}"
      }
      exit 1
    else
      errors = local.types.map { |type|
        diff_fields = (remote.fields[type]? || [] of String) - local.fields[type].as_a
        { fields: diff_fields, type: type }
      }.reject { |err| err[:fields].empty? }

      if errors.empty?
        puts chalk.green(" ✔ Types are fine")
      else
        puts ""
        puts chalk.red(" Missing fields in")
        puts ""
        errors.each { |err|
          puts chalk.red(" ✖ #{err[:type]}")
          print "   "
          err[:type].size.times { print chalk.red("-") }
          puts ""
          err[:fields].each { |field|
            m = remote.field_types[err[:type]][field]
            puts "   #{field}#{m[:opt] && '?'}: #{m[:type]}"
          }
          puts ""
        }
        exit 1
      end
    end
  end
end
