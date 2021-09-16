module SuperRuby
  module Values
    class Type
      attr_reader :size

      def initialize(size)
        @size = size
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
