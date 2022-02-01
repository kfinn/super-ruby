class BufferBuilder
  delegate :<<, :[], to: :storage

  def pointer
    Pointer.new(self, 0)
  end

  Pointer = Struct.new(:buffer_builder, :index) do
    def next!
      buffer_builder[index].tap do
        self.index += 1
      end
    end
  end

  private

  def storage
    @storage ||= []
  end
end
