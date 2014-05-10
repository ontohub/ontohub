module GitRepository::Config

  protected

  def get_config(key)
    git_exec 'config', key
  end

  def set_section(section, options)
    section = Array.wrap(section)

    remove_section section
    add_section    section, options
  end

  def add_section(section, options)
    mainsection, subsection = *section

    File.open("#{local_path}/config","a") do |f|
      f.puts "[#{mainsection}" << (subsection ? " \"#{subsection}\"" : '') << "]"
      options.each do |key,value|
        f.puts "\t#{key} = #{value}"
      end
    end
  end

  # Removes a config section
  def remove_section(section)
    git_exec 'config', '--remove-section', section.join(".")
    true
  rescue Exception => e
    raise unless e.message.include?('No such section')
    false
  end

end
