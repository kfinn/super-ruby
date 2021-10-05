module SuperRuby
  module Builtins
    module Types
      module TypeBase
        class Method
          def initialize(body)
            @body = body
          end
          attr_reader :body

          def to_bytecode_chunk!(
            super_self_bytecode_chunk,
            arguments_bytecode_chunks
          )
            body.call(
              super_self_bytecode_chunk,
              arguments_bytecode_chunks
            )
          end

          def force!; true; end
        end

        extend ActiveSupport::Concern

        included do
          include Singleton
          delegate :size, to: :class
        end

        class_methods do
          def typed_instance
            BytecodeChunk.new(
              value_type: Type.instance,
              llvm_symbol: instance
            )
          end

          def method(*identifiers, &body)
            identifiers.each do |identifier|
              builtin_methods[identifier] = Method.new(body)
            end
          end

          def builtin_methods
            @builtin_methods ||= {}
          end

          def atom_text
            name.split("::").last
          end

          def names
            [atom_text]
          end

          def size(size=nil)
            if size.present?
              @size = size
            else
              @size || 8
            end
          end
        end

        def to_s
          self.class.atom_text
        end

        def resolve(identifier)
          self.class.builtin_methods.fetch(identifier) do
            raise "unknown identifier: #{identifier}"
          end
        end

        def pointer_methods
          {}
        end
      end
    end
  end
end
