module SuperRuby
  module Builtins
    module Macros
      module MacroBase
        extend ActiveSupport::Concern

        included do
          include Singleton
        end

        class_methods do
          def typed_instance
            Values::Concrete.new(
              Types::Macro.instance,
              instance
            )
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
