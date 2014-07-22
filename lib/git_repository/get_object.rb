module GitRepository::GetObject
  # depends on GitRepository
  extend ActiveSupport::Concern

  # can throw error: Rugged::OdbError: Object not found - failed to find pack entry
  def get_object(rugged_commit, object_path='')
    object = rugged_commit.tree
    object_path.split('/').each do |part|
      return nil unless object[part]
      object = @repo.lookup(object[part][:oid]) unless part.empty?
    end

    object
  end
end
