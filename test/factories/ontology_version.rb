FactoryGirl.define do
  factory :ontology_version do
    raw_file { File.open "test/fixtures/ontologies/owl/pizza.owl" }
    association :ontology
    association :user
  end
end
