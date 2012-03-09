FactoryGirl.define do
  factory :permission do
    role { "owner" }
    association :subject, :factory => :user
    association :object, :factory => :ontology
  end
end
