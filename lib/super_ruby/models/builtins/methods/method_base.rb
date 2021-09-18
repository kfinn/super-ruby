module SuperRuby
  module Builtins
    module Methods
      module MethodBase
        extend ActiveSupport::Concern

        included do
          include Singleton

          delegate :arguments, :body, to: :class
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

          def body(&body)
            if body.present?
              @body = body
            end
            @body
          end
        end

        def call!(super_self, list, caller_scope, memory)
          call_scope = caller_scope.extract_argument_values_for_method_call(
            self,
            list,
            caller_scope,
            memory
          )

          evaluate! super_self, call_scope, memory
        end

        def evaluate!(super_self, call_scope, memory)
          call_scope_arguments = self.class.arguments.each_with_object({}) do |argument, draft_call_scope_arguments|
            draft_call_scope_arguments[argument.to_sym] = call_scope.resolve(argument)
          end

          body.call(super_self, scope, memory, **call_scope_arguments)
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
