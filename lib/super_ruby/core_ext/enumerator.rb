class Enumerator
  def empty?
    peek
    false
  rescue StopIteration
    true
  end
end
