require_relative "super_ruby"

workspace = Workspace.new(evaluation_strategy: :evaluate_with_bytecode)
print "> "
$stdin.each_line do |line|
  workspace.add_source_string line
  workspace.evaluate!
  puts "#{workspace.result_type}: #{workspace.result_value}"
  print "> "
end
puts
puts "exiting"
