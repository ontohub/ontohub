def create_commits!(repository)
  repository.git.commits { |c| repository.commit_for!(c.oid) }
end

def attach_commit!(ontology_version)
  commit = Commit.find_by_commit_oid(ontology_version.commit_oid)
  ontology_version.commit = commit
  ontology_version.save!
end

namespace :migrate_data do
  desc "migrate ontology-versions to commit-references"
  task :introduce_commits => :environment do
    Repository.find_each { |r| create_commits!(r) }
    OntologyVersion.find_each { |ov| attach_commit!(ov) }
  end
end
