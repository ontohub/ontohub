class AddAssociationFromCommitToUser < MigrationWithData
  def up
    rename_column :commits, :author, :author_name
    rename_column :commits, :committer, :committer_name

    add_column :commits, :author_email, :string
    add_column :commits, :committer_email, :string

    add_column :commits, :pusher_name, :string

    # We emphasize "null: true" because there may be no user
    add_column :commits, :author_id, :integer, null: true
    add_column :commits, :committer_id, :integer, null: true
    add_column :commits, :pusher_id, :integer, null: true

    add_index :commits, :author_id
    add_index :commits, :committer_id
    add_index :commits, :pusher_id

    up_data

    remove_column :ontology_versions, :user_id
  end

  def down
    add_column :ontology_versions, :user_id, :integer

    down_data

    remove_index :commits, :author_id
    remove_index :commits, :committer_id
    remove_index :commits, :pusher_id

    # We emphasize "null: true" because there may be no user
    remove_column :commits, :author_id
    remove_column :commits, :committer_id
    remove_column :commits, :pusher_id

    remove_column :commits, :pusher_name

    remove_column :commits, :author_email
    remove_column :commits, :committer_email

    rename_column :commits, :author_name
    rename_column :commits, :committer_name
  end

  protected

  def up_data
    OntologyVersion.find_each do |ontology_version|
      attrs = select_attributes(ontology_version, :user_id, :commit_oid, :name)
      commit = Commit.where(commit_oid: attrs[:commit_oid]).first
      update_columns(commit,
                     pusher_id: attrs[:user_id], pusher_name: attrs[:name])
    end

    up_split_name_and_email
  end

  def down_data
    Commit.find_each do |commit|
      attrs = select_attributes(commit,
                                :pusher_id, :commit_oid,
                                :author_name, :author_email,
                                :committer_name, :committer_email)
      down_ontology_version(attrs)
      down_commit(attrs)
    end
  end

  def up_split_name_and_email
    Commit.find_each do |commit|
      attrs = select_attributes(commit, :author_name, :committer_name)
      author_info =
        attrs[:author_name].match(/\A(?<name>.*) <(?<email>[^\>]*)>\z/)
      committer_info =
        attrs[:committer_name].match(/\A(?<name>.*) <(?<email>[^\>]*)>\z/)
      update_columns(commit, **data(author_info, committer_info))
    end
  end

  def data(author_info, committer_info)
    data = {author_name: author_info[:name],
            author_email: author_info[:email],
            committer_name: committer_info[:name],
            committer_email: committer_info[:email]}
    data[:author_id] =
      User.where(email: data[:author_email]).select(:id).first.try(:id)
    data[:committer_id] =
      User.where(email: data[:committer_email]).select(:id).first.try(:id)
    data
  end

  def down_ontology_version(attrs)
    ontology_version =
      OntologyVersion.where(commit_oid: attrs[:commit_oid]).first
    update_columns(ontology_version, user_id: attrs[:pusher_id])
  end

  def down_commit(attrs)
    author_info = "#{attrs[:author_name]} <#{attrs[:author_email]}>"
    committer_info = "#{attrs[:committer_name]} <#{attrs[:committer_email]}>"
    update_columns(commit,
                   author_name: author_info, committer_name: committer_info)
  end
end
