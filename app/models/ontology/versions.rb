module Ontology::Versions
  extend ActiveSupport::Concern

  included do
    has_many :versions,
      :dependent     => :destroy,
      :class_name    => 'OntologyVersion'

    attr_accessible :versions_attributes
    accepts_nested_attributes_for :versions
    
    after_create :create_permission_for_first_version

  end
  
  protected
  
  def create_permission_for_first_version
    version = versions.first
    permissions.create! :subject => version.user, :role => 'owner' if version
  end
  
end
