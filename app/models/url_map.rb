class UrlMap < ActiveRecord::Base
  belongs_to :repository
  attr_accessible :source, :target

  delegate :permission?, to: :repository

  validates :target, presence: true
  validates :source, presence: true, uniqueness: { scope: :repository_id }

  def to_s
    "#{source}=#{target}"
  end
end
