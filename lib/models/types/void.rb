module Types
  class Void
    include Singleton
    include BaseType

    class Instance
      include Singleton

      def to_s
        "Void"
      end
    end

    def instance
      Instance.instance
    end
  end
end
