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

      FileUtils.mkdir_p(path)
      Dir.chdir(path) do
        `git init .`
        `git config --local user.email "tester@localhost.localdomain"`
        `git config --local user.name "Tester"`
        `echo "(P x)" > Px.clif`
        `echo "(Q y)" > Qy.clif`
        `echo "(R z)" > Rz.clif`
        `git add Px.clif`
        `git commit -m "add Px.clif"`
        `git add Qy.clif`
        `git commit -m "add Qy.clif"`
        `git add Rz.clif`
        `git commit -m "add Rz.clif"`
        `git mv Px.clif PxMoved.clif`
        `git commit -m "move Px.clif to PxMoved.clif"`
        `git mv PxMoved.clif PxMoved2.clif`
        `git commit -m "move PxMoved.clif to PxMoved2.clif"`
        `git mv Qy.clif QyMoved.clif`
        `git mv Rz.clif RzMoved.clif`
        `git commit -m "move Qy.clif to QyMoved.clif, Rz.clif to RzMoved.clif"`

        # convert to bare repository
        `rm -rf *.clif`
        `mv .git/* .`
        `rm -rf .git`
      end

      new(path)
    end
  end
end
