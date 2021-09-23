require "active_support/all"
require "active_model"

require "super_ruby/core_ext/enumerator"
require "super_ruby/core_ext/string"

require "llvm/core"
require "llvm/execution_engine"

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
