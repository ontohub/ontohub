# A users SSH Key
class Key < ActiveRecord::Base
  
  include Key::Fingerprint
  include Key::Filesystem

  belongs_to :user

  attr_accessible :key, :name

  strip_attributes :only => [:key, :name]

  validates :name, presence: true, length: { within: 0..50 }
  validates :key, presence: true, length: { within: 0..5000 }, format: { with: /\A(ssh|ecdsa)-.*\Z/ }, uniqueness: true

  def shell_id
    "key-#{id}"
  end

end
