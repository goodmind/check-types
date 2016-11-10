def file_safe(file_name : String)
  begin
    file = File.read(file_name)
  rescue e : Exception
    puts "check-types: #{e}"
    exit 1
  end

  file
end
