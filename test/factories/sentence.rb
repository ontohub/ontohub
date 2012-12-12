
FactoryGirl.define do
  sequence :sentence_name do |n|
    "Ax#{n}"
  end
  
  factory :sentence do
    association :ontology, :factory => :single_ontology
    name { FactoryGirl.generate :sentence_name }
    text { Faker::Lorem.sentence }
  end
end
