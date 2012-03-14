FactoryGirl.define do
  factory :ontology_version do
    association :ontology
    association :user
  end
end
