module SuperRuby
  module Builtins
    module Types
      class Pointer
        def initialize(target_type)
          @target_type = target_type
        end

        attr_reader :target_type

        def to_llvm_type
          LLVM::Pointer(target_type.to_llvm_type)
        end

        def methods
          @methods ||= {
            "free" => Methods::Free.instance,
            "read" => Methods::Read.instance,
            "write" => Methods::Write.instance
          }
        end

        def resolve(identifier)
          methods.fetch(identifier) do
            target_type.pointer_methods.fetch(identifier) do
              raise "unknown identifier: #{identifier}"
            end
          end
        end

        def to_s
          "(Pointer #{target_type})"
        end
      end
    end
  end
end
