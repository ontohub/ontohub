class Comment < ActiveRecord::Base

  belongs_to :commentable,
    :polymorphic   => true,
    :counter_cache => true

  belongs_to :user

  attr_accessible :text

  scope :latest, order('id DESC')

  validates :text, :length => { :minimum => 10 }

end
