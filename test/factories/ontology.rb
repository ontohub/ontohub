FactoryGirl.define do

  sequence :iri do |n|
    "gopher://host/ontology/#{n}"
  end

  sequence :name do |n|
    "#{Faker::Lorem.word}_#{n}"
  end

  factory :ontology do
    association :repository
    iri { FactoryGirl.generate :iri }
    name { FactoryGirl.generate :name }
    basepath { SecureRandom.hex(10) }
    file_extension { '.owl' }
    description { Faker::Lorem.paragraph }
    logic { FactoryGirl.create :logic }

    factory :single_unparsed_ontology do |ontology|
      ontology.after(:build) do |ontology|
        version = ontology.versions.build({
            commit_oid: '0'*40,
            user: nil,
          }, without_protection: true)

        version.fast_parse = true
        version.do_not_parse!
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

          FactoryGirl.create(:link,
                            source: child_one,
                            target: child_two,
                            ontology: ontology)

          ontology.children.push(child_one, child_two)
        end
      end

      factory :heterogeneous_ontology do |ontology|
        ontology.after(:build) do |ontology|
          logic_one = FactoryGirl.create(:logic)
          logic_two = FactoryGirl.create(:logic)
          ontology.children << FactoryGirl.create(:ontology,
            logic: logic_one,
            repository: ontology.repository)
          ontology.children << FactoryGirl.create(:ontology,
            logic: logic_two,
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
