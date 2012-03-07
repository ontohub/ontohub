Factory.sequence :uri do |n|
  "schema://host/ontology/#{n}"
end

FactoryGirl.define do
  factory :ontology do
    uri { Factory.next :uri }
    name { Faker::Name.name }
  end
end
