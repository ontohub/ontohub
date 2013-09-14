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

      # Should always be fully linked, so every child should
      # have a linked (defined by the DO) pointing or sourcing
      # to/from it.
      factory :linked_distributed_ontology do |ontology|
        ontology.after(:build) do |ontology|
          logic = FactoryGirl.create(:logic)
          child_one = FactoryGirl.create(:ontology, logic: logic)
          child_two = FactoryGirl.create(:ontology, logic: logic)

          FactoryGirl.create(:link,
                            source: child_one,
                            target: child_two,
                            ontology: ontology)

          ontology.children.push(child_one, child_two)
        end
      end

    end
  end
end
