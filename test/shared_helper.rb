require 'pathname'
require 'simplecov'

module SharedHelper

  APP_ROOT = Pathname.new(File.expand_path('../../', __FILE__)).expand_path

  class AppRootFilter < SimpleCov::Filter
    def matches?(source_file)
      source_file.filename.sub(/^#{excluded_path.to_s}.*/, '').empty?
    end

    def excluded_path
      APP_ROOT.join(filter_argument).expand_path
    end
  end

  def app_root
    Pathname.new(File.expand_path('../../', __FILE__))
  end

  def gemset_definition_file
    rbenv = app_root.join('.rbenv-gemsets')
    rbenv if rbenv.exist?
  end

  def gemsets
    file = gemset_definition_file
    if File.exist? file.to_s
      file.readlines.map(&:strip).select { |line| !line.empty? }
    else
      []
    end
  end

  def use_simplecov

    SimpleCov.start do
      add_group "Models",      "app/models"
      add_group "Controllers", "app/controllers"
      add_group "Helpers",     "app/helpers"
      add_group "Lib",         "lib"

      add_filter AppRootFilter.new('config/')
      add_filter AppRootFilter.new('spec/')
      add_filter AppRootFilter.new('test/')

      gemsets.each do |gemset|
        add_filter AppRootFilter.new("#{gemset}/")
      end
    end
    
    if defined? Coveralls
      # is loaded in the Rake task 'test:coveralls'
      Coveralls.wear_merged!('rails')
    end
  end

end
