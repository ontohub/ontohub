Factory.sequence :iri do |n|
  "gopher://host/ontology/#{n}"
end

FactoryGirl.define do
  factory :ontology do
    iri { Factory.next :iri }
    name { Faker::Name.name }
    description { Faker::Lorem.paragraph }
  end
end
