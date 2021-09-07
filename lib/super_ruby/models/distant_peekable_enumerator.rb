module SuperRuby
  class DistantPeekableEnumerator
    def initialize(enumerator)
      @enumerator = enumerator
    end

    def peek(offset = 0)
      while offset >= peeked.size
        puts("calling enumerator.next")
        peeked << enumerator.next
      end

      if offset == peeked.size
        puts("calling enumerator.peek")
        enumerator.peek
      else
        peeked[offset]
      end
    end

    def next
      return peeked.unshift if peeked.any?
      puts("calling enumerator.next")
      enumerator.next
    end

    delegate :each, :empty?, to: :enumerator

    private
    attr_reader :enumerator

    def peeked
      @peeked ||= []
    end
  end
end
