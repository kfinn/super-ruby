module SuperRuby
  module Builtins
    module Procedures
      class ProcedureBase
        def self.atom_text
          name.split("::").last.underscore
        end

        def self.names(*names)
          if names.present?
            @names = names
          else
            @names ||= [atom_text]
          end
        end

        def self.arguments(*arguments)
          if arguments.present?
            @arguments = arguments.map(&:to_s)
          else
            @arguments || []
          end
        end

        def self.body(&body)
          if body.present?
            @body = body
          end
          @body
        end

        delegate :arguments, :body, to: :class

        def call!(list, caller_scope, memory)
          call_scope = caller_scope.extract_argument_values_for_call(
            self,
            list,
            caller_scope,
            memory
          )

          evaluate! call_scope, memory
        end

        def evaluate!(call_scope, memory)
          call_scope_arguments = self.class.arguments.each_with_object({}) do |argument, draft_call_scope_arguments|
            draft_call_scope_arguments[argument.to_sym] = call_scope.resolve(argument)
          end

          body.call(scope, memory, **call_scope_arguments)
        end

        def scope
          Builtins
        end

        def to_s
          "(builtin_procedure #{self.class.atom_text})"
        end
      end
    end
  end
end
