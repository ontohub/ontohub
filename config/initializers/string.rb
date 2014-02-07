class String
  def encoding_utf8
    self.force_encoding("UTF-8").encode("utf-8", "binary", :undef => :replace)
  end
end