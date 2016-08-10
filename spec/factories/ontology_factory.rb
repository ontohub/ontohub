FactoryGirl.define do

  sequence :iri do |n|
    "gopher://host/object/#{n}"
  end

  sequence :name do |n|
    "#{Faker::Lorem.word}_#{n}"
  end

  factory :ontology do |ontology|
    association :repository
    name { FactoryGirl.generate :name }
    basepath { SecureRandom.hex(10) }
    file_extension { '.owl' }
    description { Faker::Lorem.paragraph }
    logic { FactoryGirl.create :logic }
    state { 'pending' }
    present { true }

    factory :done_ontology do
      state { 'done' }

      ontology.after(:build) do |ontology|
        version = build :ontology_version,
                        ontology: ontology,
                        basepath: ontology.basepath,
                        file_extension: ontology.file_extension,
                        state: 'done'
        ontology.versions << version
      end

      ontology.after(:create) do |ontology|
        ontology.ontology_version = ontology.versions.last
        ontology.save!
      end
    end

    ontology.after(:build) do |ontology|
      version = build :ontology_version,
                      ontology: ontology,
                      basepath: ontology.basepath,
                      file_extension: ontology.file_extension
      ontology.versions << version
    end

    trait :with_version do
      after(:build) do |ontology|
        version = build :ontology_version,
                        ontology: ontology,
                        basepath: ontology.basepath,
                        file_extension: ontology.file_extension,
                        state: 'pending'
        ontology.versions << version
      end
    end

    factory :single_unparsed_ontology do |ontology|
      ontology.after(:build) do |ontology|
        version = build :ontology_version,
                        ontology: ontology,
                        basepath: ontology.basepath,
                        file_extension: ontology.file_extension
        version.fast_parse = true
        ontology.versions << version
      end
    end

    factory :single_ontology, class: SingleOntology do
    end

    factory :distributed_ontology, class: DistributedOntology do
      logic { nil }

      # Should always be fully linked, so every child should
      # have a linked (defined by the DO) pointing or sourcing
      # to/from it.
      factory :linked_distributed_ontology do |ontology|
        ontology.after(:build) do |ontology|
          logic = FactoryGirl.create(:logic)
          child_one = FactoryGirl.create(:ontology,
            logic: logic,
            repository: ontology.repository)
          child_two = FactoryGirl.create(:ontology,
            logic: logic,
            repository: ontology.repository)

          FactoryGirl.create(:mapping,
                            source: child_one,
                            target: child_two,
                            ontology: ontology)

          ontology.children.push(child_one, child_two)
        end
      end

      trait :with_children do
        after(:build) do |built_ontology|
          built_ontology.children << FactoryGirl.build(:ontology,
            parent: built_ontology,
            repository: built_ontology.repository,
            basepath: built_ontology.basepath,
            file_extension: built_ontology.file_extension)
          built_ontology.children << FactoryGirl.build(:ontology,
            parent: built_ontology,
            repository: built_ontology.repository,
            basepath: built_ontology.basepath,
            file_extension: built_ontology.file_extension)
        end
      end

      trait :with_versioned_children do
        after(:build) do |ontology|
          version = build :ontology_version,
                          ontology: ontology,
                          basepath: ontology.basepath,
                          file_extension: ontology.file_extension
          version.fast_parse = true
          ontology.versions << version

          logic = FactoryGirl.create(:logic)
          child_one = FactoryGirl.build(:ontology, :with_version,
            parent: ontology,
            basepath: ontology.basepath,
            file_extension: ontology.file_extension,
            logic: logic,
            repository: ontology.repository)
          child_one.versions.first.parent = version

          child_two = FactoryGirl.build(:ontology, :with_version,
            parent: ontology,
            basepath: ontology.basepath,
            file_extension: ontology.file_extension,
            logic: logic,
            repository: ontology.repository)
          child_two.versions.first.parent = version

          FactoryGirl.create(:mapping,
                            source: child_one,
                            target: child_two,
                            ontology: ontology)
        end
      end

      factory :heterogeneous_ontology do |ontology|
        ontology.after(:build) do |ontology|
          logic_one = FactoryGirl.create(:logic)
          logic_two = FactoryGirl.create(:logic)
          ontology.children << FactoryGirl.build(:ontology,
            logic: logic_one,
            parent: ontology,
            repository: ontology.repository)
          ontology.children << FactoryGirl.build(:ontology,
            logic: logic_two,
            parent: ontology,
            repository: ontology.repository)
        end
      end

      factory :homogeneous_ontology do |ontology|
        ontology.after(:build) do |ontology|
          logic_one = FactoryGirl.create(:logic)
          ontology.children << FactoryGirl.create(:ontology,
            logic: logic_one,
            repository: ontology.repository)
          ontology.children << FactoryGirl.create(:ontology,
            logic: logic_one,
            repository: ontology.repository)
        end
      end
    end
  end
end
