Factory.sequence :uri do |n|
  "gopher://host/ontology/#{n}"
end

FactoryGirl.define do
  factory :ontology do
    uri { Factory.next :uri }
    name { Faker::Name.name }
    description { Faker::Lorem.paragraph }
  end
end
