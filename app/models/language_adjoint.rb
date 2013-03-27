class LanguageAdjoint < ActiveRecord::Base
  include Resourcable
  include Permissionable

  belongs_to :translation, class_name: 'LanguageMapping'
  belongs_to :projection, class_name: 'LanguageMapping'
  belongs_to :user

  validates_presence_of :translation, :projection, :iri

  after_create :add_permission

  attr_accessible :iri, :translation, :projection, :translation_id, :projection_id

  def to_s
    "#{iri}: #{translation} ADJOINTS #{projection}"
  end

  private

  def add_permission
    permissions.create! :subject => self.user, :role => 'owner' if self.user
  end
end
