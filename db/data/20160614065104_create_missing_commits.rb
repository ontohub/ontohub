class CreateMissingCommits < MigrationWithData
  def self.up
    OntologyVersion.where(commit_id: nil).find_each do |ontology_version|
      commit = Commit.where(repository_id: ontology_version.repository.id,
                            commit_oid: ontology_version.commit_oid).
        first_or_create!
      fill_in_commit_data(commit, ontology_version)
      ontology_version.commit = commit
      ontology_version.save!
    end
  end

  def self.down
    raise IrreversibleMigration
  end

  protected

  def retrieve_user_info(ontology_version)
    user_id = select_attributes(ontology_version, :user_id)[:user_id]
    user = User.select(%i(name email)).where(id: user_id).first
    # select first admin, if no user is specified in the ontology version
    user ||= User.order(:id).where(admin: true).first
    "#{user.name} <#{user.email}>"
  end

  def fill_in_commit_data(commit, ontology_version)
    user_info = retrieve_user_info(ontology_version)
    update_columns(commit,
                   author: user_info,
                   committer: user_info,
                   author_date: ontology_version.created_at,
                   commit_date: ontology_version.created_at)
  end
end
