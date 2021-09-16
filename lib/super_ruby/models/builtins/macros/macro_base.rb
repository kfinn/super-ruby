module SuperRuby
  module Builtins
    module Macros
      class MacroBase
        def self.names
          [atom_text]
        end

        def self.atom_text
          name.split("::").last.underscore
        end

        def to_s
          "(builtin_procedure #{self.class.atom_text})"
        end
      end
    end
  end
end
