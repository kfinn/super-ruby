module SuperRuby
  module Builtins
    module Types
      module TypeBase
        extend ActiveSupport::Concern

        included do
          include Singleton
          delegate :scope, to: :class
        end

        class_methods do
          def typed_instance
            Values::Concrete.new(
              Types::Type.instance,
              instance
            )
          end

          def methods(*methods)
            methods.each do |method|
              method.names.each do |name|
                scope.define! name, Values::Concrete.new(Method.instance, method.instance)
              end
            end
          end

          def scope
            @scope ||= Scope.new(Scope.empty)
          end

          def atom_text
            name.split("::").last
          end

          def names
            [atom_text]
          end
        end

        def to_s
          self.class.atom_text
        end
      end
    end
  end
end
