RSpec.describe Workspace do
  let(:workspace) { Workspace.new }

  it 'correctly types an if expression with a redefined static variable' do
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
      Types::Intersection.new(
        [Types::Integer.instance, Types::Boolean.instance]
        )
      )
    )
    expect(workspace.result_value).to eq(true)
  end

  it 'correctly calls a procedure referencing a static variable' do
    workspace.add_source_string '(sequence ((define x 12) ((procedure () (x + 1)) call)))'
    workspace.evaluate!
    expect(workspace.result_type).to eq(Types::Integer.instance)
    expect(workspace.result_value).to eq(13)
  end

  it 'correctly calls a procedure referencing a dynamic variable' do
    workspace.add_source_string '((procedure (x) (x + 1)) call 100)'
    workspace.evaluate!
    expect(workspace.result_type).to eq(Types::Integer.instance)
    expect(workspace.result_value).to eq(101)
  end
end
