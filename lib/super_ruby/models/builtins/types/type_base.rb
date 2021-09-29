module SuperRuby
  module Builtins
    module Types
      module TypeBase
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

          def methods(*methods)
            if methods.present?
              @methods = methods.map(&:instance)
            else
              @methods || []
            end
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
          found = self.class.methods.find { |m| m.names.include? identifier }
           raise "unknown identifier: #{identifier}"  unless found.present?
           found
        end

        def pointer_methods
          {}
        end
      end
    end
  end
end
