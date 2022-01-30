module Types
  class Void
    include Singleton

    class Instance
      include Singleton

      def to_s
        "Void"
      end
    end

    def instance
      Instance.instance
    end

    def to_s
      "Void"
    end
  end
end
