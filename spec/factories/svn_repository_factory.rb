FactoryGirl.define do
  sequence(:svn_repository_path_bare) do |n|
    Rails.root.join('tmp', 'test', 'svn_repository_bare', n.to_s).to_s
  end

  sequence(:svn_repository_path_work) do |n|
    Rails.root.join('tmp', 'test', 'svn_repository_work', n.to_s).to_s
  end

  factory :svn_repository, class: Array do |svn_repository|
    skip_create

    initialize_with do
      exec_silently = ->(cmd) { Subprocess.run('bash', '-c', cmd) }

      path_bare = generate :svn_repository_path_bare
      path_work = generate :svn_repository_path_work
      FileUtils.mkdir_p(File.dirname(path_bare))
      Dir.chdir(File.dirname(path_bare)) do
        exec_silently.call("svnadmin create #{File.basename(path_bare)}")
        exec_silently.call("svn co file://#{path_bare} #{path_work}")
      end

      [path_bare, path_work]
    end
  end
end
