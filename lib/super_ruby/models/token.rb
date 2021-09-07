module SuperRuby
  class Token
    include ActiveModel::Model
    attr_accessor :text, :match

    def ==(other)
      other.kind_of?(Token) && to_attributes == other.to_attributes
    end
    alias eql? ==

    def to_attributes
      { text: text }
    end
  end
end
