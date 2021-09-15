module SuperRuby
  module Values
    class Type
      attr_reader :name, :size, :scope

      def initialize(name, size, scope)
        @name = name
        @size = size
        @scope = scope
      end

      VOID = new("Void", 0, nil)
      TYPE = new("Type", 8, nil)
      INTEGER = new("Integer", 8, nil)
      FLOAT = new("Float", 8, nil)
      STRING = new("String", 16, nil)

      BUILTINS = {
        'Void' => VOID,
        'Type' => TYPE,
        'Integer' => INTEGER,
        'Float' => FLOAT,
        'String' => STRING
      }.freeze
      def self.builtins
        BUILTINS
      end

      alias to_s name
    end
  end
end
