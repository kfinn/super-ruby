module SuperRuby
  class SourceFile
    def initialize(filename)
      @filename = filename
    end
    
    attr_reader :filename

    def each_char(&block)
      File.open filename do |file|
        file.each_char(&block)
      end
    end
  end
end
