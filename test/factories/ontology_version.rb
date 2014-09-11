FactoryGirl.define do
  factory :ontology_version do
    association :ontology
    association :user
    basepath { SecureRandom.hex(10) }
    file_extension { '.owl' }
    commit_oid { SecureRandom.hex(20) }
    state_updated_at { Time.now }

    after(:create) do |version|
      version.ontology.reload
    end

    after(:build) do |version|
      version.do_not_parse!
    end

  end

  factory :ontology_version_with_file, :parent => :ontology_version do
    raw_file { File.open "test/fixtures/ontologies/owl/pizza.owl" }
  end
end
