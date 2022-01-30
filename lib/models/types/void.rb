module Types
  class Void
    include Singleton

    class Instance
      include Singleton
    end

    def instance
      Instance.instance
    end
  end
end
