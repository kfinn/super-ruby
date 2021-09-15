module SuperRuby
  class Memory
    class Allocation
      def initialize(size)
        @data = nil
      end

      attr_accessor :data
      delegate :type, :value, to: :data

      def assign!(data)
        self.data = data
      end
    end

    def allocate(size)
      next_allocation_id!.tap do |allocation_id|
        allocations[allocation_id] = Allocation.new(size)
      end
    end

    def free(allocation_id)
      allocations.delete allocation_id
    end

    def get(allocation_id)
      allocations[allocation_id]
    end

    def allocations
      @allocations ||= {}
    end

    def next_allocation_id!
      @next_allocation_id ||= 1
      result = @next_allocation_id
      @next_allocation_id += 1
      result
    end
  end
end
 