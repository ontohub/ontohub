module RemoteRepository

  def self.instance(repository)
    "#{to_s}::#{repository.source_type.camelcase}".constantize.new(repository)
  end

  class Base
    attr_accessor :repository
    delegate :git, :git!, :destroy_git, :source_address, :local_path, :local_path_working_copy, to: :repository

    class_attribute :sync_method

    def initialize(repository)
      @repository = repository
    end

    def clone
      raise NotImplementedError
    end

    def synchronize
      repo_working_copy = GitRepository.new(local_path_working_copy)
      
      result_pull = repo_working_copy.send sync_method
      result_push = repo_working_copy.push

      {
        success: result_pull[:success] && result_push[:success],
        head_oid_pre: result_pull[:head_oid_pre],
        head_oid_post: result_pull[:head_oid_post]
      }
    end
  end

  class Git < Base

    self.sync_method = :pull

    def clone
      destroy_git

      result_wc   = GitRepository.clone_git(source_address, local_path_working_copy, false)
      result_bare = GitRepository.clone_git(local_path_working_copy, local_path, true)

      # reload repository
      git!

      result_remote_rm  = git.remote_rm_origin
      result_remote_set = GitRepository.new(local_path_working_copy).remote_set_url_push(local_path)

      unless result_wc[:success] && result_bare[:success] && result_remote_rm[:success] && result_remote_set[:success]
        raise Repository::ImportError, 'could not import repository'
      end
    end
  end

  class Svn < Base

    self.sync_method = :svn_rebase

    def clone
      result_clone = GitRepository.clone_svn(source_address, local_path, local_path_working_copy)
      unless result_clone[:success]
        raise Repository::ImportError, "could not import repository: #{result_clone[:err]}"
      end

      git!
    end
  end
end