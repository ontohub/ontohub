FactoryGirl.define do
  factory :ontology_version do
    association :ontology, factory: :done_ontology
    basepath { SecureRandom.hex(10) }
    file_extension { '.owl' }
    commit_oid { SecureRandom.hex(20) }
    state_updated_at { Time.now }

    after(:create) do |version|
      version.commit.save!
      version.ontology.ontology_version = version
      version.ontology.save!
      version.ontology.reload
    end

    after(:build) do |version|
      version.commit ||= build :commit,
                               repository: version.ontology.repository,
                               commit_oid: version.commit_oid
      version.do_not_parse!
    end

  end

  factory :ontology_version_with_file, :parent => :ontology_version do
    raw_file { File.open 'spec/fixtures/ontologies/owl/pizza.owl' }
  end
end
