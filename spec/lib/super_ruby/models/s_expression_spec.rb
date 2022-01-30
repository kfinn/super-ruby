RSpec.describe SExpression do
  describe 'from_tokens' do
    let(:tokens) do
      source_file_lexer.each_token
    end
    let(:source_file_lexer) { Lexer.new source_string }
    let(:source_string) do
      SourceString.new super_code
    end

    context 'with an Integer literal' do
      let(:super_code) do
        <<~SUPER
          12
        SUPER
      end

      it 'contains the integer literal' do
        s_expression = SExpression.from_tokens(tokens)
        expect(s_expression.first).to be_kind_of(SExpressions::Atom)
        expect(s_expression.first.text).to eq "12"
      end
    end

    context 'with a binary operator applied to an Integer literal' do
      let(:super_code) do
        <<~SUPER
          (. 12 to_s)
        SUPER
      end

      it 'contains the binary operator applied to the Integer literal' do
        s_expression = SExpression.from_tokens(tokens.each)
        expect(s_expression.first).to be_kind_of(SExpressions::List)
        expect(s_expression.first.children.map(&:text)).to eq [".", '12', 'to_s']
      end
    end

    context 'with nested lists' do
      let(:super_code) do
        <<~SUPER
          (a b (c d) [e] {f} [({g h} i)])
        SUPER
      end

      it 'contains the nested lists' do
        root_s_expression = SExpression.from_tokens(tokens.each).first
        expect(root_s_expression).to be_kind_of(SExpressions::List)
        root_s_expression[0].tap do |a_atom|
          expect(a_atom).to be_kind_of(SExpressions::Atom)
          expect(a_atom.text).to eq 'a'
        end
        root_s_expression[1].tap do |b_atom|
          expect(b_atom).to be_kind_of(SExpressions::Atom)
          expect(b_atom.text).to eq 'b'
        end
        root_s_expression[2].tap do |cd_list|
          expect(cd_list).to be_kind_of(SExpressions::List)
          expect(cd_list.size).to eq 2
          cd_list[0].tap do |c_atom|
            expect(c_atom).to be_kind_of(SExpressions::Atom)
            expect(c_atom.text).to eq 'c'
          end
          cd_list[1].tap do |d_atom|
            expect(d_atom).to be_kind_of(SExpressions::Atom)
            expect(d_atom.text).to eq 'd'
          end
        end
        root_s_expression[3].tap do |e_list|
          expect(e_list).to be_kind_of(SExpressions::List)
          expect(e_list.size).to eq(1)
          e_list.first.tap do |e_atom|
            expect(e_atom).to be_kind_of(SExpressions::Atom)
            expect(e_atom.text).to eq 'e'
          end
        end
        root_s_expression[4].tap do |f_list|
          expect(f_list).to be_kind_of(SExpressions::List)
          expect(f_list.size).to eq(1)
          f_list.first.tap do |f_atom|
            expect(f_atom).to be_kind_of(SExpressions::Atom)
            expect(f_atom.text).to eq 'f'
          end
        end
        root_s_expression[5].tap do |gh_i_list_list|
          expect(gh_i_list_list).to be_kind_of(SExpressions::List)
          expect(gh_i_list_list.size).to eq(1)
          gh_i_list_list.first.tap do |gh_i_list|
            expect(gh_i_list).to be_kind_of(SExpressions::List)
            expect(gh_i_list.size).to eq(2)
            gh_i_list[0].tap do |gh_list|
              expect(gh_list).to be_kind_of(SExpressions::List)
              expect(gh_list.size).to eq(2)
              gh_list[0].tap do |g_atom|
                expect(g_atom).to be_kind_of(SExpressions::Atom)
                expect(g_atom.text).to eq('g')
              end                
              gh_list[1].tap do |h_atom|
                expect(h_atom).to be_kind_of(SExpressions::Atom)
                expect(h_atom.text).to eq('h')
              end
            end
            gh_i_list[1].tap do |i_atom|
                expect(i_atom).to be_kind_of(SExpressions::Atom)
                expect(i_atom.text).to eq('i')
            end
          end
        end
      end
    end
  end
end
