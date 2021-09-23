module SuperRuby
  module Builtins
    module Types
      class Procedure
        class ArgumentList
          include Enumerable
          attr_reader :arguments
          delegate :each, to: :arguments

          def initialize(arguments)
            @arguments = arguments
          end

          def to_llvm_type
            map(&:to_llvm_type)
          end
        end

        Argument = Struct.new(:name, :type) do
          delegate :to_llvm_type, to: :type
        end

        def initialize(arguments, return_type)
          @arguments = arguments
          @return_type = return_type
        end

        attr_reader :arguments, :return_type

        def to_llvm_type
          LLVM::Function(
            to_llvm_arguments_type,
            to_llvm_return_type
          )
        end

        def to_llvm_arguments_type
          arguments.to_llvm_type
        end

        def to_llvm_return_type
          return_type.to_llvm_type
        end

        def methods
          @methods ||= {
            "call" => Methods::Call.new(self)
          }
        end

        def resolve(identifier)
          methods.fetch(identifier) do
            raise "unknown identifier: #{identifier}"
          end
        end
      end
    end
  end
end
