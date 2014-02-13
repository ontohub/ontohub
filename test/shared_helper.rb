require 'pathname'

module SharedHelper

  def app_root
    Pathname.new(File.expand_path('../../', __FILE__))
  end

  def gemset_definition_file
    rbenv = app_root.join('.rbenv-gemsets')
    rvm = app_root.join('.ruby-gemset')
    if rbenv.exist?
      rbenv
    elsif rvm.exist?
      rvm
    end
  end

  def gemsets
    file = gemset_definition_file
    file.readlines.map { |line| line.strip }.select { |line| !line.empty? }
  end

  def use_simplecov
    require 'simplecov'

    SimpleCov.start do
      add_group "Models",      "app/models"
      add_group "Controllers", "app/controllers"
      add_group "Helpers",     "app/helpers"
      add_group "Lib",         "lib"

      add_filter '/config/'
      add_filter '/spec/'
      add_filter '/test/'

      # these lines break SimpleCov on RVM environments (corny)
      #gemset_definition = app_root.join('.rbenv-gemsets')
      #gemsets.each do |gemset|
      #  add_filter "/#{gemset}/"
      #end
    end
    
    if defined? Coveralls
      # is loaded in the Rake task 'test:coveralls'
      Coveralls.wear_merged!('rails')
    end
  end

end
