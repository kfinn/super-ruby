module SuperRuby
  RSpec.describe AstNode do
    describe 'from_tokens' do
      let(:tokens) do
        DistantPeekableEnumerator.new(source_file_lexer.each_token)
      end
      let(:source_file_lexer) { SourceFileLexer.new source_file: mock_source_file }
      let(:mock_source_file) do
        instance_double(SourceFile).tap do |it|
          allow(it).to receive(:open_file).and_yield(StringIO.new(super_code))
        end
      end

      context 'with an Integer literal' do
        let(:super_code) do
          <<~SUPER
            12
          SUPER
        end

        xit 'contains the integer literal' do
          ast_node = AstNode.from_tokens(tokens)
          expect(ast_node).to be_kind_of(AstNodes::IntegerLiteral)
          puts ast_node
          puts ast_node.token
          puts ast_node.token.class
          puts ast_node.token.match
          puts ast_node.token.text
          expect(ast_node.text).to eq("12")
        end
      end

      # context 'with a binary operator applied to an Integer literal' do
      #   let(:super_code) do
      #     <<~SUPER
      #       12.to_s
      #     SUPER
      #   end

      #   it 'contains the binary operator applied to the Integer literal' do
      #     ast_node = AstNode.from_tokens(tokens.each)
      #     expect(ast_node).to be_kind_of(AstNodes::BinaryOperator)
      #     expect
      #     expect(ast_node.text).to eq("12")
      #   end
      # end
    end
  end
end
