module RemoteRepository

  def self.instance(repository)
    "#{to_s}::#{repository.source_type.camelcase}".constantize.new(repository)
  end

  class Base
    attr_accessor :repository, :user
    delegate :git,
      :git!,
      :source_address,
      :local_path,
      :local_path_working_copy,
      :save_current_ontologies,
      to: :repository

    class_attribute :sync_method

    def initialize(repository)
      @repository = repository
      @user = repository.permissions.where(subject_type: User, role: 'owner').first!.subject
    end

    def clone
      raise NotImplementedError
    end
  end

  class Git < Base

    self.sync_method = :pull

    def clone
      git.clone_from_origin source_address
      save_current_ontologies(user)
    end

    def synchronize
      result = git.fetch_and_reset
      save_current_ontologies(user)
      result
    end
  end

  class Svn < Base

    self.sync_method = :svn_rebase

    def clone
      repository.destroy_git
      
      FileUtils.mkdir_p(Ontohub::Application.config.git_working_copies_root)

      result_clone = GitRepository.clone_svn(source_address, local_path, local_path_working_copy)
      unless result_clone[:success]
        raise Repository::ImportError, "Could not import repository: #{result_clone[:err]}"
      end

      save_current_ontologies(user)

      git!
    end

    def synchronize
      repo_working_copy = GitRepository.new(local_path_working_copy)
      
      result_pull = repo_working_copy.send sync_method
      result_push = repo_working_copy.push

      save_current_ontologies(user)

      {
        success: result_pull[:success] && result_push[:success],
        head_oid_pre: result_pull[:head_oid_pre],
        head_oid_post: result_pull[:head_oid_post]
      }
    end
  end
end
