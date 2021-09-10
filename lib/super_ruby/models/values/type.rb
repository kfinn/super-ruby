module SuperRuby
  module Values
    class Type
      attr_reader :size, :scope

      def initialize(size, scope)
        @size = size
        @scope = scope
      end

      VOID = new(0, nil)
      TYPE = new(8, nil)
      INTEGER = new(8, nil)
      FLOAT = new(8, nil)
      STRING = new(16, nil)
    end
  end
end
