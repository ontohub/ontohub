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
      mapping.versions << FactoryGirl.build(:mapping_version, mapping: mapping)
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
