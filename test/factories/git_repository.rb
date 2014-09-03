FactoryGirl.define do
  sequence(:git_repository_path) do |n|
    Rails.root.join('tmp', 'test', 'git_repository', n.to_s).to_s
  end

  factory :git_repository do |git_repository|
    skip_create
    initialize_with { new(generate :git_repository_path) }
  end

  factory :git_repository_with_moved_ontologies, class: GitRepository do |git_repository|
    skip_create

    initialize_with do
      path = generate :git_repository_path
      exec_silently = ->(cmd) { Subprocess.run('bash', '-c', cmd) }

      FileUtils.mkdir_p(path)
      Dir.chdir(path) do
        exec_silently.call('git init .')
        exec_silently.call('git config --local user.email "tester@localhost.localdomain"')
        exec_silently.call('git config --local user.name "Tester"')
        exec_silently.call('echo "(P x)" > Px.clif')
        exec_silently.call('echo "(Q y)" > Qy.clif')
        exec_silently.call('echo "(R z)" > Rz.clif')
        exec_silently.call('git add Px.clif')
        exec_silently.call('git commit -m "add Px.clif"')
        exec_silently.call('git add Qy.clif')
        exec_silently.call('git commit -m "add Qy.clif"')
        exec_silently.call('git add Rz.clif')
        exec_silently.call('git commit -m "add Rz.clif"')
        exec_silently.call('git mv Px.clif PxMoved.clif')
        exec_silently.call('git commit -m "move Px.clif to PxMoved.clif"')
        exec_silently.call('git mv PxMoved.clif PxMoved2.clif')
        exec_silently.call('git commit -m "move PxMoved.clif to PxMoved2.clif"')
        exec_silently.call('git mv Qy.clif QyMoved.clif')
        exec_silently.call('git mv Rz.clif RzMoved.clif')
        exec_silently.call('git commit -m "move Qy.clif to QyMoved.clif, Rz.clif to RzMoved.clif"')

        # convert to bare repository
        exec_silently.call('rm -rf *.clif')
        exec_silently.call('mv .git/* .')
        exec_silently.call('rm -rf .git')
      end

      new(path)
    end
  end
end
