require_relative "super_ruby"

workspace = Workspace.new
workspace.add_source(SourceIo.new($stdin))
workspace.compile!
