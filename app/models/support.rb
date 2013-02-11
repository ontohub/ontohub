class Support < ActiveRecord::Base
  belongs_to :logic
  belongs_to :language
  
  attr_accessible :exact, :logic_id, :language_id
  
end
