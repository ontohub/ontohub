if %w(development production).include?(Rails.env)
  require 'rack-mini-profiler'

  # initialization is skipped so trigger it
  Rack::MiniProfilerRails.initialize!(Rails.application)

  # profile specific methods
  Rails.application.config.to_prepare do
    ::Rack::MiniProfiler.profile_method(GitRepository, :commits) do |a|
      "GitRepository#commits: fetching commits"
    end
    ::Rack::MiniProfiler.profile_method(GitRepository, :get_file!) do |a|
      "GitRepository#get_file!: fetching a file"
    end
    ::Rack::MiniProfiler.profile_method(RepositoryFile, :content) do |a|
      "RepositoryFile#content: fetching file/dir content"
    end
    ::Rack::MiniProfiler.profile_method(LinkHelper, :fancy_link) do |a|
      "LinkHelper#fancy_link: creating a link"
    end
  end
end
