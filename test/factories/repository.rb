FactoryGirl.define do
  factory :repository do
    sequence(:name) { |n| "Repository #{n}" }
    description { Faker::Lorem.paragraph }

    factory :repository_with_remote do |repository|
      repository.after(:build) do |repository|
        path = '/tmp/ontohub/test/unit/git/repository'
        git_repository = GitRepository.new(path)
        userinfo = {
          email: 'janjansson.com',
          name: 'Jan Jansson',
          time: Time.now
        }
        filepath1 = "cat.clif"
        filepath2 = "Px.clif"
        message = 'Some commit message'
        commit_add1 = git_repository.commit_file(userinfo, '(Cat mat)', filepath1, message)
        commit_add2 = git_repository.commit_file(userinfo, '(P x)', filepath2, message)
        commit_add3 = git_repository.commit_file(userinfo, '(Cat mat2)', filepath1, message)

        repository.source_type = 'git'
        repository.source_address = path
      end
    end
  end
end
