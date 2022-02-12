module Types
  class Intersection
    include BaseType

    def self.from_types(*types)
      new(
        Set.new(
          types.flat_map do |type|
            type.try(:types)&.to_a || [type]
          end
        )
      )
    end

    def initialize(types)
      @types = types
    end
    attr_reader :types

    def message_send_result_typing(message, argument_typings)
      self.class.from_types(
        types.map do |type|
          type.message_send_result_typing(message, argument_typings)
        end
      )
    end

    def to_s
      "(#{types.map(&:to_s).join("|")})"
    end

    def ==(other)
      other.kind_of?(Intersection) && state == other.state
    end

    delegate :hash, to: :state
    alias state types

    class IntersectionTyping
      prepend Jobs::BaseJob

      def initialize(typings)
        @typings = typings
        @typings.each do |typing|
          typing.add_downstream(self)
        end
      end
      attr_reader :typings


      def complete?
        typings.all?(&:complete?)
      end

      def work!; end

      def type
        @type ||=
          if typings.all? { |typing| typing.type == typings.first.type }
            typings.first.type
          else
            Intersection.new(typings.map(&:type))
          end
      end
    end
  end
end
