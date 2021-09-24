module SuperRuby
  module Builtins
    module Macros
      module MacroBase
        extend ActiveSupport::Concern

        included do
          include Singleton
        end

        class_methods do
          class LazyBytecodeChunk
            def initialize(macro)
              @macro = macro
            end

            attr_reader :macro
            attr_accessor :llvm_symbol

            def to_bytecode_chunk!
              self
            end
            
            def super_send!(list)
              self.llvm_symbol = macro.to_bytecode_chunk!(list)
            end
          end

          def typed_instance
            LazyBytecodeChunk.new(instance)
          end

          def names
            [atom_text]
          end

          def atom_text
            name.split("::").last.underscore
          end
        end

        def to_s
          "(builtin_macro #{self.class.atom_text})"
        end
      end
    end
  end
end
