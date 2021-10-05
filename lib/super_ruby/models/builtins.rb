module SuperRuby
  module Builtins
    MACROS = [
      Macros::Define,
      Macros::Sequence,
      Macros::Procedure,
      Macros::If,
      Macros::Pointer,
      Macros::Var,
      Macros::Struct
    ].freeze

    TYPES = [
      Types::Float,
      Types::Integer,
      Types::Type,
      Types::Void
    ]

    ALL = [*MACROS, *TYPES].each_with_object({}) do |builtin, acc|
      builtin_instance = builtin.typed_instance
      builtin.names.each do |name|
        raise "duplicate builtin name: #{name}" if acc.include? name
        acc[name] = builtin_instance
      end
    end
    def self.resolve(identifier)
      raise "unknown identifier: #{identifier}" unless ALL.include? identifier
      ALL[identifier]
    end

    def self.spawn
      Scope.new
    end
  end
end
