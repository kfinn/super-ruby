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
          expect(workspace.evaluate!).to eq Values::Concrete.new(Builtins::Types::Integer.instance, 1)
        end
      end

      context 'with a program containing only a float literal' do
        let(:super_code) do
          <<~SUPER
           0.5
          SUPER
        end
        it 'is the float literal' do
          expect(workspace.evaluate!).to eq Values::Concrete.new(Builtins::Types::Float.instance, 0.5)
        end
      end

      context 'sending + to an Integer constant with another Integer constant argument' do
        let(:super_code) { '(1 + 2)' }
        it 'adds the two constants' do
          expect(workspace.evaluate!).to eq Values::Concrete.new(Builtins::Types::Integer.instance, 3)
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
                  (x + 1)
                )
              )

              (plus_one call 2)
            ))
          SUPER
        end

        it 'performs the function call and returns the result, 3' do
          expect(workspace.evaluate!).to eq Values::Concrete.new(Builtins::Types::Integer.instance, 3)
        end
      end

      context 'with a small program that has memory allocations' do
        let(:super_code) do
          <<~SUPER
            (sequence(
              (
                define
                x
                (Integer new)
              )
              (
                define
                increment
                (
                  procedure
                  (x_pointer)
                  ((x_pointer dereference) = ((x_pointer dereference) + 1))
                )
              )
              ((x dereference) = 0)
              (increment call x)
              (define result (x dereference))
              (x free)
              result
            ))
          SUPER
        end

        it 'handles allocating, dereferencing, and freeing memory' do
          result = workspace.evaluate!
          expect(result.type).to eq Builtins::Types::Integer.instance
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
                    (x dereference)
                    =
                    ((x dereference) + 1)
                  )
                )
              )

              (
                define
                allocate_and_increment
                (
                  procedure
                  (initial_value)
                  (sequence(
                    (define x (Integer new))
                    ((x dereference) = initial_value)
                    (increment call x)
                    (define result (x dereference))
                    (x free)
                    result
                  ))
                )
              )

              (allocate_and_increment call 1)
            ))
          SUPER
        end

        it 'evalutes the program and returns the correct value of 2' do
          workspace.evaluate!.tap do |result|
            expect(result.type).to eq Builtins::Types::Integer.instance
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
                    (n == 0)
                    1
                    (
                      if
                      (n == 1)
                      1
                      ((fib call (n - 1)) + (fib call (n - 2)))
                    )
                  )
                )
              )

              (fib call 6)
            ))
          SUPER
        end

        it 'evaluates the recursive program and returns the correct value' do
          expect(workspace.evaluate!).to eq Values::Concrete.new(Builtins::Types::Integer.instance, 13)
        end
      end
    end
  end
end
