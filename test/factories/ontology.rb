Factory.sequence :iri do |n|
  "gopher://host/ontology/#{n}"
end

FactoryGirl.define do
  factory :ontology do
    iri { Factory.next :iri }
    name { Faker::Name.name }
    description { Faker::Lorem.paragraph }
    
    factory :single_ontology, class: SingleOntology do
    end
    
    factory :distributed_ontology, class: DistributedOntology do
    end
    
  end
end
