class RecreateRepositorySymlinks < ActiveRecord::Migration
  def self.up
    Repository.find_each do |repository|
      repository.send(:symlinks_remove)
      repository.send(:symlinks_update)
    end
  end

  def self.down
    Repository.find_each do |repository|
      repository.send(:symlinks_remove)
      repository.send(:symlinks_update)
    end
  end
end
