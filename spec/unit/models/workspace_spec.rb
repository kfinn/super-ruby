module SuperRuby
  RSpec.describe Workspace do
    describe 'evaluate!' do
      let(:workspace) { Workspace.new source }
      let(:source) { SourceString.new super_code }

      context 'with a program containing only an int literal' do
        let(:super_code) do
          <<~SUPER
            1
          SUPER
        end
        it 'is the int literal' do
          expect(workspace.evaluate!).to eq Values::Concrete.new(Values::Type::INTEGER, 1)
        end
      end

      context 'with a program containing only a float literal' do
        let(:super_code) do
          <<~SUPER
           0.5
          SUPER
        end
        it 'is the float literal' do
          expect(workspace.evaluate!).to eq Values::Concrete.new(Values::Type::FLOAT, 0.5)
        end
      end

      context 'with a + operation on two constants' do
        let(:super_code) { '(+ 1 2)' }
        it 'adds the two constants' do
          expect(workspace.evaluate!).to eq Values::Concrete.new(Values::Type::INTEGER, 3)
        end
      end

      context 'with a small program that has function calls' do
        let(:super_code) do
          <<~SUPER
            (sequence (
              (
                define
                plus_one
                (
                  procedure
                  (x)
                  (+ x 1)
                )
              )

              (plus_one 2)
            ))
          SUPER
        end

        it 'performs the function call and returns the result, 3' do
          expect(workspace.evaluate!). to eq Values::Concrete.new(Values::Type::INTEGER, 3)
        end
      end

      context 'with a small program that has function calls and memory allocation & dereferencing' do
        let(:super_code) do
          <<~SUPER
            (sequence (
              (
                define
                increment
                (x)
                (
                  assign
                  (dereference x)
                  (+ (dereference x) 1)
                )
              )

              (
                define
                allocate_and_increment
                (initial_value)
                (
                  sequence
                  (
                    (declare x)
                    (assign x (allocate 8))
                    (assign (dereference x) initial_value)
                    (increment x)
                    (dereference x)
                  )
                )
              )

              (allocate_and_increment 1)
            ))
          SUPER
        end

        xit 'evalutes the program and returns the correct value of 2' do
          expect(workspace.evaluate!).to eq Values::Concrete.new(Values::Type::INTEGER, 2)
        end
      end
    end
  end
end
