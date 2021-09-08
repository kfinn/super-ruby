class String
  def super_whitespace?
    self.squish.blank?
  end

  SUPER_INDENT_CHARACTERS = Set.new(["{", "(", "["]).freeze
  def super_indent?
    SUPER_INDENT_CHARACTERS.include? self
  end

  SUPER_DEDENT_CHARACTERS = Set.new(["}", ")", "]"]).freeze
  def super_dedent?
    SUPER_DEDENT_CHARACTERS.include? self
  end

  SUPER_CONTROL_FLOW_CHARACTERS = Set.new([*SUPER_INDENT_CHARACTERS, *SUPER_DEDENT_CHARACTERS]).freeze
  def super_control_flow?
    SUPER_CONTROL_FLOW_CHARACTERS.include? self
  end

  SUPER_STRING_LITERAL_TERMINATORS = Set.new(['"', "'"]).freeze
  def super_string_literal_terimator?
    SUPER_STRING_LITERAL_TERMINATORS.include? self
  end
end
