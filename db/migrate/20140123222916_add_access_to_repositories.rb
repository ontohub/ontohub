class AddAccessToRepositories < ActiveRecord::Migration
  def up
    rename_column :repositories, :is_private, :access
    change_column :repositories, :access, :string, null: false, default: 'public_r'

    # This is PostgreSQL specific. In SQLite for example, a boolean typechanged
    # into a string becomes 't' or 'f'.
    Repository.find_each do |repo|
      repo.access = 'private'  if repo.access == 'true'
      repo.access = 'public_r' if repo.access == 'false'
      repo.save! if repo.changed?
    end
  end

  def down
    Repository.find_each do |repo|
      repo.access = 'true'  if repo.access == 'private'
      repo.access = 'false' if repo.access.start_with? 'public_'
      repo.save! if repo.changed?
    end

    change_column :repositories, :access, :boolean, default: false
    rename_column :repositories, :access, :is_private
  end
end
