module SuperRuby
  RSpec.describe Lexer do
    describe 'each_token' do
      let(:source_file_lexer) { Lexer.new source_string }
      let(:source_string) do
        SourceString.new source_string_contents
      end

      context 'with source that does not end in any whitespace' do
        context 'with a control flow character' do
          let(:source_string_contents) { "(" }
          it 'yields the control flow character' do
            expect(source_file_lexer.each_token.to_a.map(&:text)).to eq(["("])
          end
        end
        context 'with a symbol' do
          let(:source_string_contents) { "fff" }
          it 'yields the symbol' do
            expect(source_file_lexer.each_token.to_a.map(&:text)).to eq(["fff"])
          end
        end
        context 'with a string literal' do
          let(:source_string_contents) { '"s"' }
          it 'yields the string literal' do
            expect(source_file_lexer.each_token.to_a.map(&:text)).to eq(['"s"'])
          end
        end
        context 'with an unterminated string literal' do
          let(:source_string_contents) { '"s' }
          it 'raises' do
            expect { source_file_lexer.each_token.to_a }.to raise_error(/unterminated string literal/)
          end
        end
      end

      context 'with a struct definition' do
        let(:source_string_contents) do
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
        let(:source_string_contents) do
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
