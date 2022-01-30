module Types
  class Intersection
    def initialize(types)
      @types = types
    end
    attr_reader :types

    def message_send_result_typing(message, argument_typings)
      IntersectionTyping.new(
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

    def state
      Set.new(types)
    end

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