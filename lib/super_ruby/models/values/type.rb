module SuperRuby
  module Values
    class Type
      attr_reader :size

      def initialize(size)
        @size = size
      end

      VOID = new(0)
      TYPE = new(8)
      INTEGER = new(8)
      FLOAT = new(8)
      STRING = new(16)
      POINTER = new(8)

      BUILTINS = {
        'Void' => Concrete.new(TYPE, VOID),
        'Type' => Concrete.new(TYPE, TYPE),
        'Integer' => Concrete.new(TYPE, INTEGER),
        'Float' => Concrete.new(TYPE, FLOAT),
        'String' => Concrete.new(TYPE, STRING),
        'Pointer' => Concrete.new(TYPE, POINTER)
      }.freeze
      def self.builtins
        BUILTINS
      end

      def to_s
        case self
        when VOID
          "Void"
        when TYPE
          "Type"
        when INTEGER
          "Integer"
        when FLOAT
          "Float"
        when STRING
          "String"
        when POINTER
          "Pointer"
        else
          "Unknown"
        end
      end
    end
  end
end
