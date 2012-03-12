Factory.sequence :source_uri do |n|
  "gopher://host/ontology/#{n}"
end

FactoryGirl.define do
  factory :ontology_version do
    source_uri { Factory.next :source_uri }
    association :ontology
    association :user
  end
end
