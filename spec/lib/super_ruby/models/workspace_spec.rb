RSpec.describe Workspace do
  let(:workspace) { Workspace.new }

  it 'specializes and calls a procedure with no arguments' do
    workspace.add_source_string '(((procedure (x) 12) specialize Integer) call 1)'
    workspace.evaluate!
    expect(workspace.result_type).to eq(Types::Integer.instance)
    expect(workspace.result_value).to eq 12
  end

  it 'can define a specialized procedure with no arguments and call it' do
    workspace.add_source_string '(sequence((define sp ((procedure () 13) specialize)) (sp call)))'
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
    workspace.add_source_string '(sequence ((define x 12) (((procedure () (x + 1)) specialize) call)))'
    workspace.evaluate!
    expect(workspace.result_type).to eq(Types::Integer.instance)
    expect(workspace.result_value).to eq(13)
  end

  it 'correctly calls a procedure referencing a dynamic variable' do
    workspace.add_source_string '(((procedure (x) (x + 1)) specialize Integer) call 100)'
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
        (define boolean_identity (identity specialize Boolean))
        (define integer_identity (identity specialize Integer))
        (
          if
          (boolean_identity call true)
          (integer_identity call 100)
          (integer_identity call 200)
        )
      ))
    SUPER
    workspace.evaluate!
    # expect(workspace.result_type).to eq (Types::Integer.instance)
    expect(workspace.result_value).to eq (100)
  end
end
