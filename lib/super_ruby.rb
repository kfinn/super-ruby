require "active_support/all"
require "active_model"

require_relative "core_ext/enumerator"
require_relative "core_ext/string"

require "zeitwerk"
loader = Zeitwerk::Loader.new
loader.push_dir 'lib/models'
loader.push_dir 'lib/concerns'
loader.setup

module SuperRuby
end
