# -*- ruby -*-

def run_spec(file)
  unless File.exist?(file)
    puts "#{file} does not exist"
    return
  end

  puts   "Running #{file}"
  system "bundle exec rspec #{file}"
  puts
end

watch("spec/.*/*_spec\.rb") do |match|
  run_spec match[0]
end

# lib/senor_armando/rack/foo.rb => spec/rack/foo_spec.rb
watch("(?:app|lib)/senor_armando/(.*)\.rb") do |match|
  run_spec %{spec/#{match[1]}_spec.rb}
end

# bin/armando_echo.rb => spec/endpoint/echo_spec.rb
watch("bin/armando_(.*)\.rb") do |match|
  run_spec %{spec/endpoint/#{match[1]}_spec.rb}
end
