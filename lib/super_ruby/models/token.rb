module SuperRuby
  class Token
    include ActiveModel::Model
    attr_accessor :text, :match
  end
end
