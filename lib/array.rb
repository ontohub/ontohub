class Array
  def sample!
    self.delete(self.sample)
  end
end
