FactoryGirl.define do
  sequence :mapping_name do |n|
    "Map#{n}"
  end

  factory :mapping do
    iri { FactoryGirl.generate :iri }
    name { FactoryGirl.generate :mapping_name }
    kind { 'view' }
    association :ontology

    after(:create) do |mapping|
      LocId.where(
                    locid: "#{mapping.ontology.locid}//#{mapping.name}",
                  ).first_or_create!(
                  assorted_object_id: mapping.id,
                  assorted_object_type: mapping.class.to_s,
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
