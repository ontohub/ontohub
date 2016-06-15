class CreateMissingCommits < ActiveRecord::Migration
  def self.up
    OntologyVersion.find_each do |ontology_version|
      if ontology_version.commit.nil?
        commit = Commit.where(repository_id: self,
                              commit_oid: commit_oid,
                              pusher_id: ontology_version.user.id
                              pusher_name: ontology_version.user.name).
          first_or_initialize
        commit.fill_commit_instance!
      end
    end
  end

  def self.down
    raise IrreversibleMigration
  end
end
