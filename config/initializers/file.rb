class File
  def self.real_basepath(filepath)
    File.join(File.dirname(filepath),
      File.basename(filepath,
        File.extname(filepath))).sub('./', '')
  end
end
