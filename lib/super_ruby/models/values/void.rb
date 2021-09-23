module SuperRuby
  module Values
    class Void
      include Singleton

      def value_type
        Builtins::Types::Void.instance
      end
    end
  end
end
