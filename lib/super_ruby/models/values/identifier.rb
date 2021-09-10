module SuperRuby
  module Values
    class Identifier
      def initialize(name)
        @name = name
      end
      attr_reader :name

      def ==(other)
        other.kind_of?(Identifier) && name == other.name
      end
      alias eql? ==

      def hash
        { name: name }.hash
      end
    end
  end
end
