class Repository < ActiveRecord::Base

  include Permissionable
  include Repository::Ontologies
  include Repository::GitRepositories
  include Repository::FilesList
  include Repository::Validations
  include Repository::Importing
  include Repository::Scopes
  include Repository::Symlink

  has_many :ontologies, dependent: :destroy
  has_many :url_maps, dependent: :destroy

  attr_accessible :name, :description, :source_type, :source_address, :is_private
  attr_accessor :user

  after_save :clear_readers

  scope :latest, order('updated_at DESC')
  scope :pub, where(is_private: false)
  scope :accessible_by, ->(user) do
    if user
      where("is_private = false
        OR id IN (SELECT item_id FROM permissions WHERE item_type = 'Repository' AND subject_type = 'User' AND subject_id = ?)
        OR id IN (SELECT item_id FROM permissions INNER JOIN team_users ON team_users.team_id = permissions.subject_id AND team_users.user_id = ?
          WHERE  item_type = 'Repository' AND subject_type = 'Team')", user, user)
    else
      pub
    end
  end

  def to_s
    name
  end

  def to_param
    path
  end

  # list all failed versions, grouped by their errors
  def show_failed_ontology_versions
    versions = self.ontologies.map{|o| o.versions.last}.compact
    failed_versions = versions.select{|v| v.state!="done"}.group_by do |v|
      err = v.state+": "+v.last_error.to_s
      if err.include?("exited with status")
        then err[0,50]+" ... "+err.match("exited with status.*")[0]
      else err.split("\n").first
      end
    end
    failed_versions
  end

  private

  def clear_readers
    if is_private_changed?
      permissions.where(role: 'reader').each { |p| p.destroy }
    end
  end
  
end
