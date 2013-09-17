class Organisation < ActiveRecord::Base
  attr_accessible :acronym, :description, :name, :url
end
