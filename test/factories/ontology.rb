FactoryGirl.define do
  
  sequence :iri do |n|
    "gopher://host/ontology/#{n}"
  end
  
  factory :ontology do
    iri { FactoryGirl.generate :iri }
    name { Faker::Name.name }
    description { Faker::Lorem.paragraph }
    
    factory :single_ontology, class: SingleOntology do
    end
    
    factory :distributed_ontology, class: DistributedOntology do
    end
  end
end
