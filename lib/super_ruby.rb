require "active_support/all"
require "active_model"

require_relative "core_ext/enumerator"
require_relative "core_ext/string"

require "zeitwerk"
loader = Zeitwerk::Loader.new
loader.push_dir 'lib/models'
loader.setup

module SuperRuby
end

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
