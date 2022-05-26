require 'tempfile'

RSpec.describe Workspace do
  let(:workspace) { Workspace.new }

  describe "#evaluate!" do
    it 'specializes and calls a procedure with no arguments' do
      workspace.add_source_string '(((procedure (x) 12) specialize (ConcreteProcedure (Integer) Integer)) call 1)'
      workspace.evaluate!
      expect(workspace.result_type).to eq(Types::Integer.instance)
      expect(workspace.result_value).to eq 12
    end

    it 'calls a defined specialized procedure with no arguments' do
      workspace.add_source_string '(sequence((define sp ((procedure () 13) specialize (ConcreteProcedure () Integer))) (sp call)))'
      workspace.evaluate!
      expect(workspace.result_type).to eq(Types::Integer.instance)
      expect(workspace.result_value).to eq 13
    end

    it 'correctly evaluates an if expression with a redefined static variable' do
      workspace.add_source_string '(define x 12)'
      workspace.add_source_string <<~SUPER.squish
        (
          if
          true
          (
            sequence
            (
              (
                define x true
              )
              x
            )
          )
          x
        )
      SUPER
      workspace.evaluate!
      expect(workspace.result_type).to(eq(
        Types::Intersection.from_types(
          Types::Integer.instance, Types::Boolean.instance
          )
        )
      )
      expect(workspace.result_value).to eq(true)
    end

    it 'calls a procedure referencing a static variable in an outer scope' do
      workspace.add_source_string '(sequence ((define x 12) (((procedure () (x + 1)) specialize (ConcreteProcedure () Integer)) call)))'
      workspace.evaluate!
      expect(workspace.result_type).to eq(Types::Integer.instance)
      expect(workspace.result_value).to eq(13)
    end

    it 'correctly calls a procedure referencing a dynamic variable' do
      workspace.add_source_string '(((procedure (x) (x + 1)) specialize (ConcreteProcedure (Integer) Integer)) call 100)'
      workspace.evaluate!
      expect(workspace.result_type).to eq(Types::Integer.instance)
      expect(workspace.result_value).to eq(101)
    end

    it 'correctly evaluates nested conditionals' do
      workspace.add_source_string '(if true (if false 1 (if true 2)) 4)'
      workspace.evaluate!
      expect(workspace.result_type).to eq(Types::Intersection.from_types(Types::Integer.instance, Types::Void.instance))
      expect(workspace.result_value).to eq(2)
    end

    it 'specializes the same abstract procedure with multiple types of arguments' do
      workspace.add_source_string <<~SUPER
        (sequence (
          (define identity (procedure (x) x))
          (define boolean_identity (identity specialize (ConcreteProcedure (Boolean) Boolean)))
          (define integer_identity (identity specialize (ConcreteProcedure (Integer) Integer)))
          (
            if
            (boolean_identity call true)
            (integer_identity call 100)
            (integer_identity call 200)
          )
        ))
      SUPER
      workspace.evaluate!
      expect(workspace.result_type).to eq(Types::Integer.instance)
      expect(workspace.result_value).to eq(100)
    end

    it 'returns the value of a conditional expression inside of a procedure' do
      workspace.add_source_string '(define quantize (procedure (x) (if (x > 50) 100 0)))'
      workspace.add_source_string '(define quantize_integer (quantize specialize (ConcreteProcedure (Integer) Integer)))'
      workspace.add_source_string '(quantize_integer call 51)'
      workspace.evaluate!
      expect(workspace.result_type).to eq(Types::Integer.instance)
      expect(workspace.result_value).to eq(100)
    end

    xit 'specializes and calls recursive procedures' do
      workspace.add_source_string <<~SUPER
        (
          define
          fibonacci 
          (
            (
              procedure
              (n)
              (
                if (n < 2)
                1
                ((fibonacci call (n - 1)) + (fibonacci call (n - 2)))
              )
            )
            specialize
            (ConcreteProcedure (Integer) Integer)
          )
        )
      SUPER
      workspace.add_source_string '(fibonacci call 5)'
      workspace.evaluate!
      expect(workspace.result_type).to eq(Types::Integer.instance)
      expect(workspace.result_value).to eq(8)
    end

    it 'can call concrete procedures passed as function pointers' do
      workspace.add_source_string <<~SUPER
        (
          define
          increment
          (
            (procedure (x) (x + 1))
            specialize
            (ConcreteProcedure (Integer) Integer)
          )
        )
      SUPER
      workspace.add_source_string <<~SUPER
        (
          define
          decrement
          (
            (procedure (x) (x - 1))
            specialize
            (ConcreteProcedure (Integer) Integer)
          )
        )
      SUPER
      workspace.add_source_string <<~SUPER
        (
          define
          apply
          (
            (procedure (p x) (p call x))
            specialize
            (ConcreteProcedure ((ConcreteProcedure (Integer) Integer) Integer) Integer)
          )
        )
      SUPER
      workspace.add_source_string('(define x 12)')
      workspace.add_source_string <<~SUPER
        (
          if
          (x > 0)
          (apply call increment x)
          (apply call decrement x)
        )
      SUPER
      workspace.evaluate!
      expect(workspace.result_type).to eq(Types::Integer.instance)
      expect(workspace.result_value).to eq(13)
    end

    it 'repeatedly specializes the same abstract procedure' do
      workspace.add_source_string <<~SUPER
        (sequence(
          (define identity (procedure (x) x))
          (
            if
            ((identity specialize (ConcreteProcedure (Boolean) Boolean)) call true)
            (((identity specialize (ConcreteProcedure (Integer) Integer)) call 100) + ((identity specialize (ConcreteProcedure (Integer) Integer)) call 101))
            2
          )
        ))
      SUPER
      workspace.evaluate!
      expect(workspace.result_type).to eq(Types::Integer.instance)
      expect(workspace.result_value).to eq(201)
    end

    it 'computes the type of values' do
      workspace.add_source_string <<~SUPER
        (1 type)
      SUPER
      workspace.evaluate!
      expect(workspace.result_type).to eq(Types::Type.instance)
      expect(workspace.result_value).to eq(Types::Integer.instance)
    end

    it 'specializes procedures by using the type bulitin' do
      workspace.add_source_string <<~SUPER
        (
          (
            (procedure (x) x)
            specialize
            (ConcreteProcedure ((1 type)) (1 type))
          )
          call
          1
        )
      SUPER
      workspace.evaluate!
      expect(workspace.result_type).to eq(Types::Integer.instance)
      expect(workspace.result_value).to eq(1)
    end

    it 'automatically specializes simple abstract procedures on call' do
      workspace.add_source_string <<~SUPER
        ((procedure (x) (x + 1)) call 10)
      SUPER
      workspace.evaluate!
      expect(workspace.result_type).to eq(Types::Integer.instance)
      expect(workspace.result_value).to eq(11)
    end

    it 'allows defining dynamic variables with let' do
      workspace.add_source_string <<~SUPER
        (sequence (
          (let x Integer (12 + 15))
          (x + 1)
        ))
      SUPER
      workspace.evaluate!
      expect(workspace.result_type).to eq(Types::Integer.instance)
      expect(workspace.result_value).to eq(28)
    end

    it 'allows mutating dynamic variables declared with let' do
      workspace.add_source_string <<~SUPER
        (sequence (
          (let x Integer (12 + 15))
          (x= 7)
          (x + 1)
        ))
      SUPER
      workspace.evaluate!
      expect(workspace.result_type).to eq(Types::Integer.instance)
      expect(workspace.result_value).to eq(8)
    end

    it 'allows defining and calling methods on types' do
      workspace.add_source_string <<~SUPER
        (sequence(
          (Integer define_method foo () 14)
          (let x Integer 13)
          (x foo)
        ))
      SUPER
      workspace.evaluate!
      expect(workspace.result_type).to eq(Types::Integer.instance)
      expect(workspace.result_value).to eq 14
    end

    it 'allows calling a procedure which defines a variable' do
      workspace.add_source_string <<~SUPER
        (sequence(
          (define add_variable (binding) (binding let x Integer 12))
          (add_variable call self)
          x
        ))
      SUPER
    end

    xit 'allows calling a procedure which defines a method on a type, then calling that method' do
      workspace.add_source_string <<~SUPER
        (sequence(
          (define method_definer
            (procedure (t) (t define_method my_method () (self + 1)))
          )
          (method_definer call Integer)
          (let my_integer Integer 7)
          (my_integer my_method)
        ))
      SUPER
      workspace.evaluate!
      expect(workspace.result_type).to eq(Types::Integer.instance)
      expect(workspace.result_value).to eq 8
    end
  end

  describe "compile!" do
    it 'compiles an Integer constant' do
      workspace.add_source_string <<~SUPER
        (define main
          (
            (procedure () 13)
            specialize
            (ConcreteProcedure () Integer)
          )
        )      
      SUPER
      result = nil
      Tempfile.open("test.ll") do |file|
        workspace.compile!(file)
        file.rewind
        result = `/usr/local/opt/llvm/bin/lli #{file.path}`
      end
      expect($?.success?).to eq(true)
      expect(result).to eq("13\n")
    end

    it 'compiles addition between two Integer constants' do
      workspace.add_source_string <<~SUPER
        (define main
          (
            (procedure () (13 + 14))
            specialize
            (ConcreteProcedure () Integer)
          )
        )      
      SUPER
      result = nil
      Tempfile.open("test.ll") do |file|
        workspace.compile!(file)
        file.flush
        result = `/usr/local/opt/llvm/bin/lli #{file.path}`
      end
      expect($?.success?).to eq(true)
      expect(result).to eq("27\n")
    end

    it 'compiles a program that returns a globally defined constant' do
      workspace.add_source_string <<~SUPER
        (define result 12)
        (define main
          (
            (procedure () (result + result))
            specialize
            (ConcreteProcedure () Integer)
          )
        )
      SUPER
      result = nil
      Tempfile.open("test.ll") do |file|
        workspace.compile!(file)
        file.flush
        result = `/usr/local/opt/llvm/bin/lli #{file.path}`
      end
      expect($?.success?).to eq(true)
      expect(result).to eq("24\n")
    end
  end
end
