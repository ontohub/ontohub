module Hets
  class HetsError < Exception; end

  class Config
    attr_reader :path

    def initialize
      yaml = YAML.load_file(File.join(Rails.root, 'config', 'hets.yml'))

      @path = first_which_exists yaml['hets_path']

      raise HetsError, 'Could not find hets' unless @path
      
      version = `#{@path} -V`
      raise ArgumentError, "Your version of hets is too old" if version.include?("2011")

      yaml.each_pair do |key, value|
        ENV[key.upcase] = first_which_exists value if key != 'hets_path'
      end
    end

  private

    def first_which_exists(array)
      array.each do |path|
        path = File.expand_path path
        return path if File.exists? path
      end

      nil
    end
  end

  # Runs hets with input_file and returns XML output file path.
  def self.parse(input_file)
    config = Config.new
    Rails.logger.debug "#{config.path} -o sym.xml -v2 '#{input_file}'"
    status = `#{config.path} -o xml -v2 '#{input_file}' 2>&1`
    status = status.split("\n").last
    Rails.logger.debug status
    if $?.exitstatus != 0 or status.starts_with? '*** Error'
      raise HetsError.new(status)
    end

    status.split(': ').last
  end
end
