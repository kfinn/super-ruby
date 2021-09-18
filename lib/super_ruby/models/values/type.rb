module SuperRuby
  module Values
    class Type
      attr_reader :size

      def initialize(size)
        @size = size
      end

      def to_s
        case self
        when Builtins::Types::Void.instance
          "Void"
        when Builtins::Types::Type.instance
          "Type"
        when Builtins::Types::Integer.instance
          "Integer"
        when Builtins::Types::Float.instance
          "Float"
        when Builtins::Types::String.instance
          "String"
        when Builtins::Types::Pointer.instance
          "Pointer"
        when Builtins::Types::Procedure.instance
          "Procedure"
        when Builtins::Types::Method.instance
          "Method"
        else
          "Unknown"
        end
      end
    end
  end
end
