RSpec.describe Workspace do
  let(:workspace) { Workspace.new }

  describe 'result_typing' do
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
  end
end
