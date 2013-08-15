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
        version = FactoryGirl.build(:ontology_version, ontology: e.ontology)
        version.stubs(:parse_async)
        e.ontology.versions << version
        e.ontology.save
      end
    end
  end
end
