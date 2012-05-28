FactoryGirl.define do
  factory :ontology_version do
    association :ontology
    association :user
  end
  
  factory :ontology_version_with_file, :parent => :ontology_version do
    raw_file { File.open "test/fixtures/ontologies/owl/pizza.owl" }
  end
end
