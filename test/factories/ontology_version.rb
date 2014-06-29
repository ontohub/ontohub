FactoryGirl.define do
  factory :ontology_version do
    association :ontology
    association :user
    commit_oid { SecureRandom.hex(20) }

    after(:build) do |version|
      version.do_not_parse!
    end

  end

  factory :ontology_version_with_file, :parent => :ontology_version do
    raw_file { File.open "test/fixtures/ontologies/owl/pizza.owl" }
  end
end
