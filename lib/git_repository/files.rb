module GitRepository::Files
  # depends on GitRepository
  extend ActiveSupport::Concern

  class GitFile
    attr_reader :name, :path, :oid, :mime_type, :mime_category

    def initialize(repository, rugged_commit, path)
      @path = path
      self.repository = repository
      if !repository.path_exists?(path, rugged_commit.oid)
        fail GitRepository::PathNotFoundError, "Path doesn't exist: #{path}"
      end
      self.rugged_object = repository.get_object(rugged_commit, path)

      @oid  = rugged_commit.oid
      @name = path.split('/')[-1]

      if file?
        mime_info      = repository.class.mime_info(name)
        @mime_type     = mime_info[:mime_type]
        @mime_category = mime_info[:mime_category]
      end
    end

    def size
      case type
      when :file
        rugged_object.size
      when :dir
        content.size
      end
    end

    def content
      @content ||= case type
        when :file
          rugged_object.content
        when :dir
          repository.folder_contents(oid, path)
        end
    end

    def file?
      type == :file
    end

    def dir?
      type == :dir
    end

    def type
      case rugged_object.type
      when :blob
        :file
      when :tree
        :dir
      end
    end

    def last_change
      @last_change ||= git.entry_info(path, oid)
    end

    protected
    attr_accessor :repository, :rugged_object
  end
end
