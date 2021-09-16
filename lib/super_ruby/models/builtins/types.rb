module SuperRuby
  module Builtins
    module Types
      VOID = Values::Type.new(0)
      TYPE = Values::Type.new(8)
      INTEGER = Values::Type.new(8)
      FLOAT = Values::Type.new(8)
      STRING = Values::Type.new(16)
      POINTER = Values::Type.new(8)

      ALL = {
        'Void' => Values::Concrete.new(TYPE, VOID),
        'Type' => Values::Concrete.new(TYPE, TYPE),
        'Integer' => Values::Concrete.new(TYPE, INTEGER),
        'Float' => Values::Concrete.new(TYPE, FLOAT),
        'String' => Values::Concrete.new(TYPE, STRING),
        'Pointer' => Values::Concrete.new(TYPE, POINTER)
      }.freeze
      def self.all
        ALL
      end
    end
  end
end
