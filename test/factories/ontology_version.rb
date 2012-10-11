FactoryGirl.define do
  factory :ontology_version do
    association :ontology
    association :user
    source_url "file://test/fixtures/ontologies/owl/pizza.owl"
  end
  
  factory :ontology_version_with_file, :parent => :ontology_version do
    raw_file { File.open "test/fixtures/ontologies/owl/pizza.owl" }
    source_url nil
  end
end
