class TokensParser
  attr_accessor :tokens
  include ActiveModel::Model

  def to_ast
    Sequence.from(tokens)
  end
end
