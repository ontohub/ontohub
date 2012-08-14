Factory.sequence :sentence_name do |n|
  "Ax#{n}"
end

FactoryGirl.define do
  factory :sentence do
    association :ontology, :factory => :single_ontology
    name { Factory.next :sentence_name }
    text { Faker::Lorem.sentence }
  end
end
