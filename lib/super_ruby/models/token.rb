module SuperRuby
  Token = Struct.new(:match) do
    delegate :text, to: :match
  end
end
