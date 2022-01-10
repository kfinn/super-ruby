require_relative "super_ruby"

workspace = Workspace.new
print "> "
$stdin.each_line do |line|
  workspace.add_source_string line
  workspace.evaluate!
  puts "#{workspace.result_type}: #{workspace.result_value}"
  print "> "
end
puts
puts "exiting"
