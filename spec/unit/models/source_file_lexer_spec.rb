module SuperRuby
  RSpec.describe SourceFileLexer do
    describe 'each_token' do
      let(:source_file_lexer) { SourceFileLexer.new source_file: mock_source_file }
      let(:mock_source_file) do
        instance_double(SourceFile).tap do |it|
          allow(it).to receive(:open_file).and_yield(StringIO.new(mock_source_file_contents))
        end
      end

      context 'with a struct definition' do
        let(:mock_source_file_contents) do
          <<~SUPER
          (define SomeStruct (struct (id Integer)))
          SUPER
        end

        it 'yields each token from the struct definition' do
          expect(
            source_file_lexer.each_token.to_a.map(&:text)
          ).to eq ([
            "(",
            "define",
            "SomeStruct",
            "(",
            "struct",
            "(",
            "id",
            "Integer",
            ")",
            ")",
            ")"
          ])
        end
      end

      context 'with a String literal' do
        let(:mock_source_file_contents) do
          <<~SUPER
            (define name "Kevin \\"superKevin\\" Finn")
          SUPER
        end

        it 'yields each token, including the String literal' do
          expect(source_file_lexer.each_token.to_a.map(&:text)).to eq([
            '(',
            'define',
            'name',
            '"Kevin \"superKevin\" Finn"',
            ')'
          ])
        end
      end
    end
  end
end
