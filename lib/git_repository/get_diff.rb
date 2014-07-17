module GitRepository::GetDiff
  # depends on GitRepository
  extend ActiveSupport::Concern

  # Represents a added/changed/deleted file
  class FileChange
    attr_accessor :directory, :name, :status, :delta

    def initialize(repo, directory, name, delta)
      @repo      = repo
      @directory = directory
      @name      = name
      @delta     = delta
      @status    = delta.status
      @binary    = delta.binary
      @diff      = nil
      @diff_size = delta
    end

    %i( added modified deleted renamed ).each do |status|
      define_method :"#{status}?" do
        @status == status
      end
    end

    def path
      directory.join(name).to_s
    end

    def binary?
      @binary
    end

    def mime_info
      @mime_info ||= GitRepository.mime_info(name)
    end

    def mime_type
      mime_info[:mime_type]
    end

    def mime_category
      mime_info[:mime_category]
    end

    def editable?
      GitRepository.mime_type_editable?(mime_type)
    end

    def diff
      @diff ||= begin
        patch = delta.diff.patch
        if patch.size > Settings.max_combined_diff_size
          :diff_too_large
        else
          patch
        end
      end
    end
  end

  # returns a list of files changed by a commit
  def changed_files(commit_oid=nil)
    rugged_commit = get_commit(commit_oid)
    file_changes = []
    if rugged_commit
      commit = GitRepository::History::Commit.new(rugged_commit)
      commit.deltas.each do |delta|
        path = Pathname.new(delta.new_file[:path])
        file_changes << FileChange.new(self, path.dirname, path.basename, delta)
      end
    end

    file_changes
  end
end
