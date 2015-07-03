namespace :secret do
  desc 'Replace the secure secret key in your settings for the current environment'
  task :replace do
    files = Settings.instance_variable_get('@config_sources').map(&:path).
      select { |p| p.include?('settings') || p.include?('environments') }.
      select { |p| File.exist?(p) }.
      reverse
    pattern = /^ *(secret_token: *["']?)[0-9a-fA-F]+(["']?)$/
    new_secret = SecureRandom.hex(64)

    puts "Replacing the secret token for the #{Rails.env} environment in #{files.join(', ')}"
    files.each do |filepath|
      content  = File.read(filepath)
      if content.gsub!(pattern, "\\1#{new_secret}\\2")
        # write the new configuration
        File.open(filepath, 'w') {|f| f.write(content) }

        puts "Secret token succesfully replaced in #{filepath}"
        break
      else
        STDERR.puts "Secret token not found in #{filepath}"
      end
    end
  end
end
