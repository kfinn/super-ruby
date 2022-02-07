RSpec.describe Workspace do
  let(:workspace) { Workspace.new }

  it 'specializes and calls a procedure with no arguments' do
    workspace.add_source_string '(((procedure (x) 12) specialize (ConcreteProcedure (Integer) Integer)) call 1)'
    workspace.evaluate!
    expect(workspace.result_type).to eq(Types::Integer.instance)
    expect(workspace.result_value).to eq 12
  end

  it 'can define a specialized procedure with no arguments and call it' do
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

  it 'correctly calls a procedure referencing a static variable' do
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
    expect(workspace.result_type).to eq (Types::Integer.instance)
    expect(workspace.result_value).to eq (100)
  end

  it 'returns the value of a conditional expression inside of a procedure' do
    workspace.add_source_string '(define quantize (procedure (x) (if (x > 50) 100 0)))'
    workspace.add_source_string '(define quantize_integer (quantize specialize (ConcreteProcedure (Integer) Integer)))'
    workspace.add_source_string '(quantize_integer call 51)'
    workspace.evaluate!
    expect(workspace.result_type).to eq (Types::Integer.instance)
    expect(workspace.result_value).to eq (100)
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
    expect(workspace.result_type).to eq (Types::Integer.instance)
    expect(workspace.result_value).to eq (5)
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
    expect(workspace.result_type).to eq (Types::Integer.instance)
    expect(workspace.result_value).to eq (201)
  end
end
