class String
  def articlerize
    %w(a e i o u).include?(self[0].downcase) ? "an #{self}" : "a #{self}"
  end
end