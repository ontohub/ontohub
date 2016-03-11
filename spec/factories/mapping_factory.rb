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
      LocId.create(
                    locid: "#{mapping.ontology.locid}//#{mapping.name}",
                    assorted_object: mapping,
                  )
    end

    factory :import_mapping do
      kind 'import'
    end
  end

  factory :language_mapping do
    association :user
    iri { FactoryGirl.generate :iri }
  end
end
