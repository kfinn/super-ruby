module SuperRuby
  class SourceFile
    include ActiveModel::Model

    attr_accessor :filename

    delegate :each_token, to: :source_file_lexer
    def source_file_lexer
      @source_file_lexer ||= SourceFileLexer.new self
    end

    def open_file
      File.open(filename) { |file| yield file }
    end
  end
end
