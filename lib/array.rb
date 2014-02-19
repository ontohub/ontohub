class Array
  def sample!
    self.delete(self.sample)
  end

  def head
    slice(0)
  end

  def tail
    slice(1..-1)
  end

end
