module SuperRuby
  RSpec.describe AstNode do
    describe 'from_tokens' do
      let(:tokens) do
        source_file_lexer.each_token
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

        it 'contains the integer literal' do
          ast_node = AstNode.from_tokens(tokens)
          expect(ast_node.first).to be_kind_of(AstNodes::Atom)
          expect(ast_node.first.text).to eq "12"
        end
      end

      context 'with a binary operator applied to an Integer literal' do
        let(:super_code) do
          <<~SUPER
            (. 12 to_s)
          SUPER
        end

        it 'contains the binary operator applied to the Integer literal' do
          ast_node = AstNode.from_tokens(tokens.each)
          expect(ast_node.first).to be_kind_of(AstNodes::List)
          expect(ast_node.first.children.map(&:text)).to eq [".", '12', 'to_s']
        end
      end

      context 'with nested lists' do
        let(:super_code) do
          <<~SUPER
            (a b (c d) [e] {f} [({g h} i)])
          SUPER
        end

        it 'contains the nested lists' do
          root_ast_node = AstNode.from_tokens(tokens.each).first
          expect(root_ast_node).to be_kind_of(AstNodes::List)
          root_ast_node[0].tap do |a_atom|
            expect(a_atom).to be_kind_of(AstNodes::Atom)
            expect(a_atom.text).to eq 'a'
          end
          root_ast_node[1].tap do |b_atom|
            expect(b_atom).to be_kind_of(AstNodes::Atom)
            expect(b_atom.text).to eq 'b'
          end
          root_ast_node[2].tap do |cd_list|
            expect(cd_list).to be_kind_of(AstNodes::List)
            expect(cd_list.size).to eq 2
            cd_list[0].tap do |c_atom|
              expect(c_atom).to be_kind_of(AstNodes::Atom)
              expect(c_atom.text).to eq 'c'
            end
            cd_list[1].tap do |d_atom|
              expect(d_atom).to be_kind_of(AstNodes::Atom)
              expect(d_atom.text).to eq 'd'
            end
          end
          root_ast_node[3].tap do |e_list|
            expect(e_list).to be_kind_of(AstNodes::List)
            expect(e_list.size).to eq(1)
            e_list.first.tap do |e_atom|
              expect(e_atom).to be_kind_of(AstNodes::Atom)
              expect(e_atom.text).to eq 'e'
            end
          end
          root_ast_node[4].tap do |f_list|
            expect(f_list).to be_kind_of(AstNodes::List)
            expect(f_list.size).to eq(1)
            f_list.first.tap do |f_atom|
              expect(f_atom).to be_kind_of(AstNodes::Atom)
              expect(f_atom.text).to eq 'f'
            end
          end
          root_ast_node[5].tap do |gh_i_list_list|
            expect(gh_i_list_list).to be_kind_of(AstNodes::List)
            expect(gh_i_list_list.size).to eq(1)
            gh_i_list_list.first.tap do |gh_i_list|
              expect(gh_i_list).to be_kind_of(AstNodes::List)
              expect(gh_i_list.size).to eq(2)
              gh_i_list[0].tap do |gh_list|
                expect(gh_list).to be_kind_of(AstNodes::List)
                expect(gh_list.size).to eq(2)
                gh_list[0].tap do |g_atom|
                  expect(g_atom).to be_kind_of(AstNodes::Atom)
                  expect(g_atom.text).to eq('g')
                end                
                gh_list[1].tap do |h_atom|
                  expect(h_atom).to be_kind_of(AstNodes::Atom)
                  expect(h_atom.text).to eq('h')
                end
              end
              gh_i_list[1].tap do |i_atom|
                  expect(i_atom).to be_kind_of(AstNodes::Atom)
                  expect(i_atom.text).to eq('i')
              end
            end
          end
        end
      end
    end
  end
end
