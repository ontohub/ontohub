FactoryGirl.define do
  sequence :mapping_name do |n|
    "Map#{n}"
  end

  factory :mapping do
    iri { FactoryGirl.generate :iri }
    name { FactoryGirl.generate :mapping_name }
    kind { 'view' }
    association :ontology

    after(:build) do |mapping|
      mapping.locid = "#{mapping.ontology.locid}//#{mapping.name}"
    end

    factory :import_mapping do
      kind 'import'
    end
  end

  factory :logic_mapping do
    association :user
    iri { FactoryGirl.generate :iri }
  end

  factory :language_mapping do
    association :user
    iri { FactoryGirl.generate :iri }
  end
end
