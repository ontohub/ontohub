class Resource < ActiveRecord::Base
  belongs_to :resourcable
  attr_accessible :kind, :uri
end
