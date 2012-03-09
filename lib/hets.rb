module Hets
  class HetsError < Exception; end

  class Config
    attr_reader :path

    def initialize
      yaml = YAML.load_file(File.join(Rails.root, 'config', 'hets.yml'))

      @path = first_which_exists yaml['hets_path']

      raise ArgumentError.new('Wrong hets path.') unless @path

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

    status = `#{config.path} -o sym.xml -v2 #{input_file} 2>/dev/null`

    begin
      status.split("\n").last.split(': ').last
    rescue NoMethodError
      raise HetsError.new(status)
    end
  end
end
