class ChangeRepositoryAccessFromPrivateToPrivateRw < ActiveRecord::Migration
  def up
    Repository.find_each do |repo|
      repo.access = 'private_rw' if repo.access == 'private'
      repo.save! if repo.changed?
    end
  end

  def down
    Repository.find_each do |repo|
      repo.access = 'private' if repo.access.start_with? 'private_'
      repo.save! if repo.changed?
    end
  end
end
