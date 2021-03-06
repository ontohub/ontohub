FactoryGirl.define do
  sequence(:git_repository_path) do |n|
    Rails.root.join('tmp', 'test', 'git_repository', n.to_s).to_s
  end

  factory :git_repository do |git_repository|
    skip_create
    initialize_with { new(generate :git_repository_path) }
  end

  factory :git_repository_with_commits, class: GitRepository do |git_repository|
    skip_create

    initialize_with do
      path = generate :git_repository_path
      exec_silently = ->(cmd) { Subprocess.run('bash', '-c', cmd) }

      FileUtils.mkdir_p(path)
      Dir.chdir(path) do
        exec_silently.call('git init .')
        exec_silently.call(
          'git config --local user.email "tester@localhost.localdomain"')
        exec_silently.call('git config --local user.name "Tester"')
        exec_silently.call('echo "(P x)" > file-0.clif')
        exec_silently.call('echo "(Q y)" > file-1.clif')
        exec_silently.call('git add file-0.clif')
        exec_silently.call('git commit -m "add file-0.clif"')
        exec_silently.call('git add file-1.clif')
        exec_silently.call('git commit -m "add file-1.clif"')

        # convert to bare repository
        exec_silently.call('rm -rf *.clif')
        exec_silently.call('mv .git/* .')
        exec_silently.call('rm -rf .git')
      end

      new(path)
    end
  end

  factory :git_repository_with_moved_ontologies, class: GitRepository do |git_repository|
    skip_create

    initialize_with do
      root_path = File.expand_path('../../../', __FILE__)
      fixture_path = File.join(root_path, 'spec/fixtures/ontologies/clif/')
      path = generate :git_repository_path
      exec_silently = ->(cmd) { Subprocess.run('bash', '-c', cmd) }

      FileUtils.mkdir_p(path)
      Dir.chdir(path) do
        exec_silently.call('git init .')
        exec_silently.call('git config --local user.email "tester@localhost.localdomain"')
        exec_silently.call('git config --local user.name "Tester"')
        exec_silently.call("cp #{fixture_path}/Px.clif Px.clif")
        exec_silently.call("cp #{fixture_path}/Qy.clif Qy.clif")
        exec_silently.call("cp #{fixture_path}/Rz.clif Rz.clif")
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

  factory :git_repository_small_push, class: GitRepository do |git_repository|
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
        exec_silently.call('git add Px.clif')
        exec_silently.call('git commit -m "add Px.clif"')

        # convert to bare repository
        exec_silently.call('rm -rf *.clif')
        exec_silently.call('mv .git/* .')
        exec_silently.call('rm -rf .git')
      end

      new(path)
    end
  end

  factory :git_repository_big_push, class: GitRepository do |git_repository|
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
        exec_silently.call('echo "(A x)" > Ax.clif')
        exec_silently.call('echo "(B y)" > By.clif')
        exec_silently.call('echo "(C z)" > Cz.clif')
        exec_silently.call('git add Px.clif')
        exec_silently.call('git commit -m "add Px.clif"')
        exec_silently.call('git add Qy.clif')
        exec_silently.call('git commit -m "add Qy.clif"')
        exec_silently.call('git add Rz.clif')
        exec_silently.call('git commit -m "add Rz.clif"')
        exec_silently.call('git add Ax.clif')
        exec_silently.call('git commit -m "add Ax.clif"')
        exec_silently.call('git add By.clif')
        exec_silently.call('git commit -m "add By.clif"')
        exec_silently.call('git add Cz.clif')
        exec_silently.call('git commit -m "add Cz.clif"')

        # convert to bare repository
        exec_silently.call('rm -rf *.clif')
        exec_silently.call('mv .git/* .')
        exec_silently.call('rm -rf .git')
      end

      new(path)
    end
  end

  factory :git_repository_big_commit, class: GitRepository do |git_repository|
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
        exec_silently.call('echo "(A x)" > Ax.clif')
        exec_silently.call('echo "(B y)" > By.clif')
        exec_silently.call('echo "(C z)" > Cz.clif')
        exec_silently.call('git add *.clif')
        exec_silently.call('git commit -m "add a lot of ontology files"')

        # convert to bare repository
        exec_silently.call('rm -rf *.clif')
        exec_silently.call('mv .git/* .')
        exec_silently.call('rm -rf .git')
      end

      new(path)
    end
  end
end
