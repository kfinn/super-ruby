module SuperRuby
  class SourceFileLexer
    include ActiveModel::Model
    attr_accessor :source_file

    def each_token(&block)
      return enum_for(__method__) unless block_given?

      open_file do |file|
        current_match = TokenMatch.new
        file.each_char do |character|
          current_match = current_match.consume! character, &block
        end
      end
    end

    delegate :open_file, to: :source_file
  end
end
