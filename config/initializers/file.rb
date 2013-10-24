class File

  def self.real_basepath(filepath)
    File.join(File.dirname(filepath),
      File.basename(filepath,
        File.extname(filepath))).sub('./', '')
  end

  def self.relative_path(dir, path)
    if path.starts_with? dir
      path.gsub(/^#{dir}\//, '')
    end
  end

end
