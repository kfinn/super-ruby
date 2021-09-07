class String
  def is_super_dot?
    self == "."
  end

  SUPER_WHITESPACE_CHARACTERS = Set.new([" ", "\t", "\r", "\n", "\f", "\v"]).freeze
  def is_super_whitespace?
    SUPER_WHITESPACE_CHARACTERS.include? self
  end

  SUPER_WORDBREAK_PUNCTUATION_CHARACTERS = Set.new(["{", "}", "(", ")", "[", "]", ";", ":", ",", "."]).freeze
  def is_super_wordbreak_punctuation?
    SUPER_WORDBREAK_PUNCTUATION_CHARACTERS.include? self
  end

  SUPER_IDENTIFIER_START_CHARACTERS = Set.new([*"A".."Z", *"a".."z", "_"]).freeze
  def is_super_identifier_start?
    SUPER_IDENTIFIER_START_CHARACTERS.include? self
  end

  SUPER_INTEGER_LITERAL_START_CHARACTERS = Set.new([*"0".."9"]).freeze
  def is_super_integer_literal_start?
    SUPER_INTEGER_LITERAL_START_CHARACTERS.include? self
  end

  SUPER_INTEGER_LITERAL_CHARACTERS = Set.new([*SUPER_INTEGER_LITERAL_START_CHARACTERS, "_"]).freeze
  def is_super_integer_literal?
    SUPER_INTEGER_LITERAL_CHARACTERS.include? self
  end

  SUPER_STRING_LITERAL_TERMINATOR_CHARACTERS = Set.new(["\""]).freeze
  def is_super_string_literal_terminator?
    SUPER_STRING_LITERAL_TERMINATOR_CHARACTERS.include? self
  end

  SUPER_NON_PUNCTUATION_CHARACTERS = Set.new([
    *SUPER_WHITESPACE_CHARACTERS,
    *SUPER_IDENTIFIER_START_CHARACTERS,
    *SUPER_INTEGER_LITERAL_START_CHARACTERS
  ])
  def is_super_punctuation?
    !SUPER_NON_PUNCTUATION_CHARACTERS.include? self
  end

  SUPER_WORDBREAK_CHARACTERS = Set.new([*SUPER_WORDBREAK_PUNCTUATION_CHARACTERS, *SUPER_WHITESPACE_CHARACTERS]).freeze
  def is_super_wordbreak?
    SUPER_WORDBREAK_CHARACTERS.include? self
  end
end
