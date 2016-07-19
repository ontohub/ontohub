class FillEmptyCommits < MigrationWithData
  def self.up
    Commit.where(author_name: nil).find_each(&:fill_commit_instance!)
  end

  def self.down
    raise IrreversibleMigration
  end
end
