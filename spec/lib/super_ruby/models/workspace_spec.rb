module SuperRuby
  RSpec.describe Workspace do
    describe 'evaluate!' do
      let(:workspace) { Workspace.new source }
      let(:source) { SourceString.new super_code }
      let(:result) { workspace.evaluate!(result_type).tap { @evaluated = true } }
      let(:result_type) { LLVM::Int }

      after { @evaluated && result&.dispose }

      context 'with a program containing only an int literal' do
        let(:super_code) do
          <<~SUPER
            1
          SUPER
        end
        it 'is the int literal' do
          expect(result.to_i).to eq 1
        end
      end

      context 'with a program containing only a float literal' do
        let(:super_code) do
          <<~SUPER
           0.5
          SUPER
        end
        let(:result_type) { LLVM::Double }

        it 'is the float literal' do
          expect(result.to_f(LLVM::Double)).to eq 0.5
        end
      end

      context 'sending + to an Integer constant with another Integer constant argument' do
        let(:super_code) { '(1 + 2)' }
        it 'adds the two constants' do
          expect(result.to_i).to eq 3
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
                  ((x Integer))
                  Integer
                  (x + 1)
                )
              )

              (plus_one call 2)
            ))
          SUPER
        end

        it 'performs the function call and returns the result, 3' do
          expect(result.to_i).to eq 3
        end
      end

      context 'with a procedure that acts like a constructor' do
        let(:super_code) do
          <<~SUPER
            (sequence(
              (
                define
                construct_x
                (
                  procedure
                  ()
                  (Pointer Integer)
                  (sequence(
                    (define result (Integer new))
                    (result write 123)
                    result
                  ))
                )
              )
              (define constructed_x (construct_x call))
              (define result (constructed_x read))
              (constructed_x free)
              result
            ))
          SUPER
        end

        it 'handles allocating, dereferencing, and freeing memory' do
          expect(result.to_i).to eq 123
        end
      end

      context 'with a procedure that writes to a pointer' do
        # 
        let(:super_code) do
          <<~SUPER
          (sequence(
            (define shared_pointer (Integer new))
            (define initialize
              (procedure
                ((to_initialize (Pointer Integer)))
                Void
                (to_initialize write 234)
              )
            )
            (initialize call shared_pointer)
            (define result (shared_pointer read))
            (shared_pointer free)
            result
          ))
          SUPER
        end

        it 'returns the value written to the pointer' do
          expect(result.to_i).to eq 234
        end
      end

      context 'with a small program that has memory allocation & dereferencing' do
        let(:super_code) do
          <<~SUPER
            (sequence(
              (define x_pointer (Integer new))
              (x_pointer write 4)
              (x_pointer write ((x_pointer read) + 1))
              (define result (x_pointer read))
              (x_pointer free)
              result
            ))
          SUPER
        end
        
        it 'performs the memory operations correctly' do
          expect(result.to_i).to eq 5
        end
      end

      context 'with a small program that has function calls and memory opeartions' do
        let(:super_code) do
          <<~SUPER
            (sequence (
              (
                define
                increment
                (
                  procedure
                  ((x (Pointer Integer)))
                  Void
                  (
                    x
                    write
                    ((x read) + 1)
                  )
                )
              )

              (
                define
                allocate_and_increment
                (
                  procedure
                  ((initial_value Integer))
                  Integer
                  (sequence(
                    (define x (Integer new))
                    (x write initial_value)
                    (increment call x)
                    (define result (x read))
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
          expect(result.to_i).to eq 2
        end
      end

      context 'with a recursive procedure and a conditional' do
        let(:super_code) do
          <<~SUPER
            (sequence(
              (
                define
                fib
                (
                  procedure
                  ((n Integer))
                  Integer
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
          expect(result.to_i).to eq 13
        end
      end

      context 'with locally scoped variables' do
        let(:super_code) do
          <<~SUPER
          (sequence(
            (var x Integer 12)
            (var y Integer 17)
            (var z Integer ((x read) + (y read)))
            (z read)
          ))
          SUPER
        end

        it 'allows those fields to be written to and read from' do
          expect(result.to_i).to eq 29
        end
      end

      context 'with a custom type declaration with a field' do
        let(:super_code) do
          <<~SUPER
          (sequence(
            (define
              CustomStruct
              (
                struct
                (
                  (var lhs Integer 10)
                  (var rhs Integer 12)
                  (var sum Integer)
                )
              )
            )
            
            (var instance CustomStruct)
            ((instance lhs) write 100)
            ((instance sum) write (((instance lhs) read) + ((instance rhs) read)))
            ((instance sum) read)
          ))
          SUPER
        end

        it 'allows that field to be written to and read from' do
          expect(result.to_i).to eq 112
        end
      end
    end
  end
end
