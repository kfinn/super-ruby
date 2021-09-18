module SuperRuby
  class Memory
    class Allocation
      def initialize(type)
        @type = type
      end

      attr_accessor :type, :value

      def scope
        @scope ||= type.scope.spawn.tap do |draft_scope|
          assign_typed_instance = Values::Concrete.new(Builtins::Types::Method.instance, Builtins::Methods::Assign.instance)
          Builtins::Methods::Assign.names.each do |name|
            draft_scope.define! name, assign_typed_instance
          end
        end
      end

      def super_send!(list, caller_scope, memory)
        method = list.second.evaluate! self.scope, memory
        method.value.call! self, list, caller_scope, memory
      end

      def assign!(typed_value)
        self.value = typed_value.value
      end

      def to_s
        "(allocation #{type} #{value})"
      end
    end

    def allocate(type)
      next_allocation_id!.tap do |allocation_id|
        allocations[allocation_id] = Allocation.new(type)
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
 