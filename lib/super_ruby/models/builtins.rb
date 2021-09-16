module SuperRuby
  module Builtins
    MACROS = [
      Macros::Define,
      Macros::Sequence,
      Macros::Procedure,
      Macros::If
    ].freeze

    PROCEDURES = [
      Procedures::Allocate,
      Procedures::Assign,
      Procedures::Dereference,
      Procedures::Equals,
      Procedures::Free,
      Procedures::Minus,
      Procedures::Plus,
      Procedures::SizeOf
    ].freeze

    ALL = [*MACROS, *PROCEDURES].each_with_object({}) do |builtin, acc|
      builtin_instance = builtin.new
      builtin.names.each do |name|
        raise "duplicate builtin name: #{name}" if acc.include? name
        acc[name] = builtin_instance
      end
    end.merge(Types.all).freeze
    def self.resolve(identifier)
      raise "unknown identifier: #{identifier}" unless ALL.include? identifier
      ALL[identifier]
    end

    def self.spawn
      Scope.new
    end
  end
end