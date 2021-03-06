module Types
  class Intersection
    include BaseType
    include DerivesEquality

    def self.from_types(*types)
      types_set = Set.new(
        types.flat_map do |type|
          type.try(:types)&.to_a || [type]
        end
      )
      return types_set.first if types_set.size == 1
      new(types_set)
    end

    def initialize(types)
      @types = types
    end
    attr_reader :types

    def message_send_result_type_inference(type_inference)
      self.class.from_types(
        types.map do |type|
          type.message_send_result_type_inference(type_inference)
        end
      )
    end

    def to_s
      "(#{types.map(&:to_s).join("|")})"
    end

    alias state types

    class IntersectionTyping
      prepend Jobs::BaseJob

      def initialize(type_inferences)
        @type_inferences = type_inferences
      end
      attr_reader :type_inferences
      attr_accessor :added_downstreams


      def complete?
        type_inferences.all?(&:complete?)
      end

      def work!
        if !added_downstreams
          self.added_downstreams = true
          type_inferences.each do |type_inference|
            type_inference.add_downstream(self)
          end  
        end
      end

      def type
        @type ||=
          if type_inferences.all? { |type_inference| type_inference.type == type_inferences.first.type }
            type_inferences.first.type
          else
            Intersection.new(type_inferences.map(&:type))
          end
      end
    end
  end
end
