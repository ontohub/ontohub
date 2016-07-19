FactoryGirl.define do
  factory :commit do
    association :repository
    association :author, factory: :user
    association :committer, factory: :user
    association :pusher, factory: :user
    commit_oid { SecureRandom.hex(20) }

    after(:build) do |commit|
      commit.author_name = commit.author.name
      commit.committer_name = commit.committer.name
      commit.pusher_name = commit.pusher.name

      commit.author_email = commit.author.email
      commit.committer_email = commit.committer.email
    end
  end
end
