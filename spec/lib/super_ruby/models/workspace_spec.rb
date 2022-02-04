RSpec.describe Workspace do
  let(:workspace) { Workspace.new }

  it 'can specialize and call a simple procedure' do
    # (sequence((define sp ((procedure () 12) specialize)) (sp call)))
    # (sequence ((define x 12) (((procedure () (x + 1)) specialize) call)))
    workspace.add_source_string '(((procedure (x) 12) specialize Integer) call 1)'
    workspace.evaluate!
    expect(workspace.result_type).to eq(Types::Integer.instance)
    expect(workspace.result_value).to eq 12
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
end
