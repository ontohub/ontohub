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

      factory :heterogeneous_ontology do |ontology|
        ontology.after(:build) do |ontology|
          logic_one = FactoryGirl.create(:logic)
          logic_two = FactoryGirl.create(:logic)
          ontology.children << FactoryGirl.create(:ontology, logic: logic_one)
          ontology.children << FactoryGirl.create(:ontology, logic: logic_two)
        end
      end

      factory :homogeneous_ontology do |ontology|
        ontology.after(:build) do |ontology|
          logic_one = FactoryGirl.create(:logic)
          ontology.children << FactoryGirl.create(:ontology, logic: logic_one)
          ontology.children << FactoryGirl.create(:ontology, logic: logic_one)
        end
      end
    end

  end
end
