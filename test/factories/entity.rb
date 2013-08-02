FactoryGirl.define do
  sequence :entity_text do |n|
    "http://host/ontology/#{n}"
  end
  
  sequence :entity_kind do |n|
    "Kind#{n}"
  end
  
  factory :entity do
    association :ontology
    text { FactoryGirl.generate :entity_text }
    kind { FactoryGirl.generate :entity_kind }
    name { Faker::Name.name }
    factory :entity_with_ontology_version do
      after(:create) do |e|
        e.ontology.versions << FactoryGirl.create(:ontology_version, ontology: e.ontology)
        e.ontology.save
      end
    end
  end
end
