FactoryGirl.define do
  factory :category do
    association :ontology, :factory => :single_ontology
  end
end
