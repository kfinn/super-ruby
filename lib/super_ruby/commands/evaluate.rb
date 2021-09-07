# frozen_string_literal: true

require_relative '../command'

module SuperRuby
  module Commands
    class Evaluate < SuperRuby::Command
      def initialize(file, options)
        @file = file
        @options = options
      end

      def execute(input: $stdin, output: $stdout)
        # Command logic goes here ...
        output.puts "OK"
      end
    end
  end
end
