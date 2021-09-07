require "active_support"
require "active_model"

require "super_ruby/core_ext/string"

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.push_dir 'lib/super_ruby/commands', namespace: SuperRuby
loader.push_dir 'lib/super_ruby/core_ext', namespace: SuperRuby
loader.push_dir 'lib/super_ruby/models', namespace: SuperRuby
loader.push_dir 'lib/super_ruby/templates', namespace: SuperRuby
loader.setup

module SuperRuby
  class Error < StandardError; end
end
