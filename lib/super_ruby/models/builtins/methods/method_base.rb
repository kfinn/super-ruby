module SuperRuby
  module Builtins
    module Methods
      module MethodBase
        extend ActiveSupport::Concern

        included do
          include Singleton

          delegate :arguments, :body, :names, to: :class

          def force!
            true
          end
        end
        
        class_methods do
          def atom_text
            name.split("::").last.underscore
          end

          def names(*names)
            if names.present?
              @names = names
            else
              @names ||= [atom_text]
            end
          end

          def arguments(*arguments)
            if arguments.present?
              @arguments = arguments.map(&:to_s)
            else
              @arguments || []
            end
          end

          def bytecode(&bytecode_builder)
            if bytecode_builder.present?
              @bytecode_builder = bytecode_builder
            end
          end
          attr_reader :bytecode_builder

          def to_llvm_function_name(type)
            BytecodeSymbolId.next("builtin_method_#{type.to_s}_#{self.atom_text}")
          end
        end

        def scope
          Builtins
        end

        def to_s
          "#{self.class.atom_text}"
        end
      end
    end
  end
end
