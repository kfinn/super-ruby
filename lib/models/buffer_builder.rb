class BufferBuilder
  delegate :<<, :[], to: :storage

  def pointer
    Pointer.new(self, 0)
  end

  Pointer = Struct.new(:buffer_builder, :index) do
    def dereference
      buffer_builder[index]
    end

    def succ
      dup.tap { |duped| duped.index = index + 1 }
    end

    def preview
      buffer_builder[index..(index + 10)]
    end
  end

  private

  def storage
    @storage ||= []
  end
end