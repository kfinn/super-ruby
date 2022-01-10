module Types
  class ConcreteProcedure
    def initialize(argument_types, return_type)
      @argument_types = argument_types
      @return_type = return_type
    end

    attr_reader :argument_types, :return_type

    def ==(other)
      other.kind_of?(ConcreteProcedure) && state == other.state
    end
  
    delegate :hash, to: :state
  
    def state
      [argument_types, return_type]
    end

    def to_s
      "(#{argument_types.map(&:to_s).join(", ")}) -> #{return_type.to_s}"
    end
  end
end
