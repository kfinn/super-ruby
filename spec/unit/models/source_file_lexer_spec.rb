module SuperRuby
  RSpec.describe SourceFileLexer do
    let(:source_file_lexer) { SourceFileLexer.new source_file: mock_source_file }
    let(:mock_source_file) do
      instance_double(SourceFile).tap do |it|
        allow(it).to receive(:open_file).and_yield(StringIO.new(mock_source_file_contents))
      end
    end

    context 'with a struct definition' do
      let(:mock_source_file_contents) do
        <<~SUPER
          SomeStruct = struct { id: Integer; }
        SUPER
      end

      it 'yields each token from the struct definition' do
        expect(
          source_file_lexer.each_token.to_a.map(&:text)
        ).to eq ([
          "SomeStruct",
          "=",
          "struct",
          "{",
          "id",
          ":",
          "Integer",
          ";",
          "}"
        ])
      end
    end

    context 'with a procedure definition' do
      let(:mock_source_file_contents) do
        <<~SUPER
          SomeProcedure = (id: Integer) -> *Record { nil }
        SUPER
      end

      it 'yields each token from the procedure definition' do
        expect(source_file_lexer.each_token.to_a.map(&:text)).to eq([
          "SomeProcedure",
          "=",
          "(",
          "id",
          ":",
          "Integer",
          ")",
          "->",
          "*",
          "Record",
          "{",
          "nil",
          "}"
        ])
      end
    end

    context 'with Integer literals' do
      let(:mock_source_file_contents) do
        <<~SUPER
          id = -103 + 12
        SUPER
      end

      it 'yields each token, including the Integer literals' do
        expect(source_file_lexer.each_token.to_a.map(&:text)).to eq([
          "id",
          "=",
          "-",
          "103",
          "+",
          "12"
        ])
      end
    end

    context 'with Float literals' do
      let(:mock_source_file_contents) do
        <<~SUPER
          id = -103. + 12.12
        SUPER
      end

      it 'yields each token, including the Float literals' do
        expect(source_file_lexer.each_token.to_a.map(&:text)).to eq([
          "id",
          "=",
          "-",
          "103.",
          "+",
          "12.12"
        ])
      end
    end

    context 'with a dot operator applied to an Integer literal' do
      let(:mock_source_file_contents) do
        <<~SUPER
          description = 12.to_s
        SUPER
      end

      it 'yields each token, including the integer literal, dot operator, and identifier' do
        expect(source_file_lexer.each_token.to_a.map(&:text)).to eq([
          "description",
          "=",
          "12",
          ".",
          "to_s"
        ])
      end
    end

    context 'with a dot operator applied to a Float literal' do
      let(:mock_source_file_contents) do
        <<~SUPER
          description = 12.0.to_s
        SUPER
      end

      it 'yields each token, including the integer literal, dot operator, and identifier' do
        expect(source_file_lexer.each_token.to_a.map(&:text)).to eq([
          "description",
          "=",
          "12.0",
          ".",
          "to_s"
        ])
      end
    end

    context 'with a String literal' do
      let(:mock_source_file_contents) do
        <<~SUPER
          name = "Kevin \\"superKevin\\" Finn"
        SUPER
      end

      it 'yields each token, including the String literal' do
        expect(source_file_lexer.each_token.to_a.map(&:text)).to eq([
          "name",
          "=",
          "\"Kevin \\\"superKevin\\\" Finn\""
        ])
      end
    end
  end
end
