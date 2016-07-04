class User < ActiveRecord::Base
  MINIMAL_ADMIN_COUNT = 1

  include User::Authentication

  has_many :comments
  has_many :team_users
  has_many :teams, :through => :team_users
  has_many :metadata
  has_many :permissions, :as => :subject
  has_many :keys
  has_many :api_keys
  has_many :authored_commits,
           class_name: Commit.to_s, foreign_key: 'author_id'
  has_many :committed_commits,
           class_name: Commit.to_s, foreign_key: 'committer_id'
  has_many :pushed_commits,
           class_name: Commit.to_s, foreign_key: 'pusher_id'
  has_many :ontology_versions, through: :pushed_commits

  attr_accessible :email, :name, :first_name, :admin, :password, :as => :admin

  strip_attributes :only => [:name, :email]

  scope :admin, where(:admin => true)

  scope :email_search, ->(query) { where "email ILIKE ?", "%" << query << "%" }

  scope :autocomplete_search, ->(query) {
    where("name ILIKE ? OR email ILIKE ?", "%" << query << "%", query)
  }

  after_save :change_pusher_name, if: :name_changed?

  before_destroy :check_remaining_admins
  before_destroy :remove_associations_from_commits

  validates_length_of :name, :in => 3..32

  def to_s
    name? ? name : email.split("@").first
  end

  # marks the user as deleted
  def delete
    self.encrypted_password = nil
    self.deleted_at = Time.now

    # nullify email fields
    @bypass_postpone       = true
    self.email             = nil
    self.unconfirmed_email = nil
    self.admin             = false

    save(:validate => false)
  end

  def email_required?
    deleted_at.nil?
  end

  def confirm!
    super

    if User.count < 2
      self.admin = true
      self.save
    end
  end

  def first_name
    name.split(' ')[0]
  end

  def team_permissions
    Permission.where(subject_id: teams.pluck(:id),
                     subject_type: 'Team')
  end

  def accessible_ids(type)
    user_permissions = permissions.where(item_type: type)
    user_permissions += team_permissions.where(item_type: type)
    user_permissions.map(&:item_id)
  end

  def owned_ids(type)
    user_permissions = permissions.where(item_type: type, role: 'owner')
    user_permissions += team_permissions.where(item_type: type, role: 'owner')
    user_permissions.map(&:item_id)
  end

  def accessible_ontologies
    Ontology.where(id: accessible_ids('Ontology'))
  end

  def accessible_repositories
    Repository.active.where(id: accessible_ids('Repository'))
  end

  def owned_deleted_repositories
    Repository.destroying.where(id: owned_ids('Repository'))
  end

  protected

  def check_remaining_admins
    if self.admin && User.admin.count <= MINIMAL_ADMIN_COUNT
      raise Permission::PowerVaccuumError, I18n.t(:admin_deletion_error_message, minimal_count: MINIMAL_ADMIN_COUNT)
    end
  end

  def remove_associations_from_commits
    authored_commits.find_each do |commit|
      commit.author = nil
      commit.save!
    end

    committed_commits.find_each do |commit|
      commit.committer = nil
      commit.save!
    end

    pushed_commits.find_each do |commit|
      commit.pusher = nil
      commit.save!
    end
  end

  def change_pusher_name
    pushed_commits.find_each do |commit|
      commit.pusher_name = name
      commit.save!
    end
  end
end
