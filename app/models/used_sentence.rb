class UsedSentence < ActiveRecord::Base
  belongs_to :basic_proof
  belongs_to :sentence
  # attr_accessible :title, :body
end
