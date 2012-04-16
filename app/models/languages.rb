class Languages < ActiveRecord::Base
  has_many :supports
  has_many :ontologies
  has_many :serializations
end
