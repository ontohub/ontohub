FactoryGirl.define do
  sequence :sentence_name do |n|
    "Ax#{n}"
  end

  factory :sentence do
    association :ontology, :factory => :single_ontology
    name { FactoryGirl.generate :sentence_name }
    text { Faker::Lorem.sentence }

    after(:create) do |sentence|
      LocId.where(
                    locid: "#{sentence.ontology.locid}//#{sentence.name}",
                    assorted_object_id: sentence,
                    assorted_object_type: sentence.class,
                  ).first_or_create
    end

    trait :of_meta_ontology do
      text { 'Class: <https://github.com/ontohub/OOR_Ontohub_API/blob/master/Domain_fields.owl#Accounting_and_taxation>       SubClassOf: <https://github.com/ontohub/OOR_Ontohub_API/blob/master/Domain_fields.owl#Business_and_administration>' }
    end
  end

end
