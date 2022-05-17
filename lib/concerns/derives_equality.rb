module DerivesEquality
  extend ActiveSupport::Concern

  def ==(other)
    other.kind_of?(self.class) && state == other.state
  end

  included do
    delegate :hash, to: :state
  end

  def state
    raise 'unimplemented'
  end
end
