
FactoryGirl.define do
  factory :comment do
    association :user
    association :commentable, :factory => :ontology
    text { Faker::Lorem.paragraph }
  end
end
