class Support < ActiveRecord::Base
  belongs_to :logic
  belongs_to :language

  attr_accessible :exact, :logic_id, :language_id


  def to_s
    "#{self.logic.name} => #{self.language.name}"
  end
end
