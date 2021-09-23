module SuperRuby
  class TypedBytecodeReference
    def initialize(type, llvm_reference)
      @type = type
      @llvm_reference = llvm_reference
    end

    attr_reader :type, :llvm_reference

    def super_send!(list, caller_scope, memory)
      if type == Builtins::Types::Macro.instance
        return value.call! list, scope, memory
      end

      method = list.second.evaluate! type.scope, memory
      method.value.call! self, list, scope, memory
    end
  end
end
