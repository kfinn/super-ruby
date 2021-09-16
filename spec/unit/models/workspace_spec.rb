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
          expect(workspace.evaluate!).to eq Values::Concrete.new(Builtins::Types::INTEGER, 1)
        end
      end

      context 'with a program containing only a float literal' do
        let(:super_code) do
          <<~SUPER
           0.5
          SUPER
        end
        it 'is the float literal' do
          expect(workspace.evaluate!).to eq Values::Concrete.new(Builtins::Types::FLOAT, 0.5)
        end
      end

      context 'with a + operation on two constants' do
        let(:super_code) { '(+ 1 2)' }
        it 'adds the two constants' do
          expect(workspace.evaluate!).to eq Values::Concrete.new(Builtins::Types::INTEGER, 3)
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
          expect(workspace.evaluate!).to eq Values::Concrete.new(Builtins::Types::INTEGER, 3)
        end
      end

      context 'with a small program that has memory allocations' do
        let(:super_code) do
          <<~SUPER
            (sequence(
              (
                define
                x
                (allocate (size_of Integer))
              )
              (
                define
                increment
                (
                  procedure
                  (x_pointer)
                  (assign (dereference x_pointer) (+ (dereference x_pointer) 1))
                )
              )
              (assign (dereference x) 0)
              (increment x)
              (define result (dereference x))
              (free x)
              result
            ))
          SUPER
        end

        it 'handles allocating, dereferencing, and freeing memory' do
          result = workspace.evaluate!
          expect(result.type).to eq Builtins::Types::INTEGER
          expect(result.value).to eq 1

          expect(workspace.memory.allocations).to be_empty
        end
      end

      context 'with a small program that has function calls and memory allocation & dereferencing' do
        let(:super_code) do
          <<~SUPER
            (sequence (
              (
                define
                increment
                (
                  procedure
                  (x)
                  (
                    assign
                    (dereference x)
                    (+ (dereference x) 1)
                  )
                )
              )

              (
                define
                allocate_and_increment
                (
                  procedure
                  (initial_value)
                  (
                    sequence
                    (
                      (define x (allocate 8))
                      (assign (dereference x) initial_value)
                      (increment x)
                      (define result (dereference x))
                      (free x)
                      result
                    )
                  )
                )
              )

              (allocate_and_increment 1)
            ))
          SUPER
        end

        it 'evalutes the program and returns the correct value of 2' do
          workspace.evaluate!.tap do |result|
            expect(result.type).to eq Builtins::Types::INTEGER
            expect(result.value).to eq 2
          end
          expect(workspace.memory.allocations).to be_empty
        end
      end

      context 'with a recursive procedure' do
        let(:super_code) do
          <<~SUPER
            (sequence(
              (
                define
                fib
                (
                  procedure
                  (n)
                  (
                    if
                    (== n 0)
                    1
                    (
                      if
                      (== n 1)
                      1
                      (+ (fib (- n 1)) (fib (- n 2)))
                    )
                  )
                )
              )

              (fib 6)
            ))
          SUPER
        end

        it 'evaluates the recursive program and returns the correct value' do
          expect(workspace.evaluate!).to eq Values::Concrete.new(Builtins::Types::INTEGER, 13)
        end
      end
    end
  end
end
