FactoryGirl.define do
  factory :axiom do
    association :ontology, factory: :single_ontology
    name { FactoryGirl.generate :sentence_name }
    text { Faker::Lorem.sentence }

    after(:create) do |axiom|
      LocId.where(
                    locid: "#{axiom.ontology.locid}//#{axiom.name}",
                    assorted_object_id: axiom.id,
                    assorted_object_type: axiom.class.to_s
                  ).first_or_create
    end
  end
end
