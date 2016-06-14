FactoryGirl.define do
  factory :commit do
    association :repository
    association :pusher, factory: :user
    commit_oid { SecureRandom.hex(20) }

    after(:build) do |commit|
      commit.author_name = commit.pusher.name
      commit.committer_name = commit.pusher.name
      commit.pusher_name = commit.pusher.name

      commit.author_email = commit.pusher.email
      commit.committer_email = commit.pusher.email

      commit.author = commit.pusher
      commit.committer = commit.pusher
    end
  end
end
