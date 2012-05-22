
Factory.sequence :sentence_name do |n|
  "Ax#{n}"
end

FactoryGirl.define do
  factory :sentence do
    association :ontology_version, :factory => :ontology_version_with_file
    name { Factory.next :sentence_name }
    text { Faker::Lorem.sentence }
  end
end
