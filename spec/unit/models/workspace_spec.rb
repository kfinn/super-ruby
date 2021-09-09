module SuperRuby
  RSpec.describe Workspace do
    describe 'evaluate' do
      let(:workspace) { Workspace.new source }
      let(:source) { SourceString.new super_code }

      context 'with a program containing only an int literal' do
        let(:super_code) { '1' }
        it 'is the int literal' do
          expect(workspace.evaluate).to eq 1
        end
      end

      context 'with a program containing only a float literal' do
        let(:super_code) { '0.5' }
        it 'is the float literal' do
          expect(workspace.evaluate).to eq 0.5
        end
      end

      context 'with a program containing only a string literal' do
        let(:super_code) { '"ffff\""'}
        it 'is the unescaped string literal' do
          expect(workspace.evaluate).to eq 'ffff"'
        end
      end

      context 'with a program containing a sequence of literals' do
        let(:super_code) do
          <<~SUPER
            12
            1.7
            "eeee"
            7
          SUPER
        end

        it 'is the value of the final expression' do
          expect(workspace.evaluate).to eq 7
        end
      end
    end
  end
end
