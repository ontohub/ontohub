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

    ontology.after(:create) do |ontology|
      if ontology.parent
        locid = "#{ontology.parent.locid}//#{ontology.name}"
      else
        locid = "/#{ontology.repository.path}/#{ontology.name}"
      end
      LocId.where(
                    locid: locid,
                    assorted_object_id: ontology.id,
                    assorted_object_type: ontology.class,
                  ).first_or_create
    end

    factory :done_ontology do
      state { 'done' }

      ontology.after(:build) do |ontology|
        version = ontology.versions.build({
            commit_oid: '0'*40,
            user: nil,
            state: 'done',
            basepath: ontology.basepath,
            file_extension: ontology.file_extension
          }, without_protection: true)

        version.do_not_parse!
      end

      ontology.after(:create) do |ontology|
        ontology.ontology_version = ontology.versions.last
        ontology.save!
        if ontology.parent
          locid = "#{ontology.parent.locid}//#{ontology.name}"
        else
          locid = "/#{ontology.repository.path}/#{ontology.name}"
        end
        LocId.where(
                      locid: locid,
                      assorted_object_id: ontology.id,
                      assorted_object_type: ontology.class,
                    ).first_or_create
      end
    end

    ontology.after(:build) do |ontology|
      version = ontology.versions.build({
          commit_oid: '0'*40,
          user: nil,
          basepath: ontology.basepath,
          file_extension: ontology.file_extension
        }, without_protection: true)

      version.do_not_parse!
    end

    trait :with_version do
      after(:build) do |ontology|
        version = ontology.versions.build({
          commit_oid: '0'*40,
          user: nil,
          basepath: ontology.basepath,
          file_extension: ontology.file_extension,
          state: 'pending'
        }, without_protection: true)

        version.do_not_parse!
      end
      after(:create) do |ontology|
        if ontology.parent
          locid = "#{ontology.parent.locid}//#{ontology.name}"
        else
          locid = "/#{ontology.repository.path}/#{ontology.name}"
        end
        LocId.where(
                      locid: locid,
                      assorted_object_id: ontology.id,
                      assorted_object_type: ontology.class,
                    ).first_or_create
      end
    end

    factory :single_unparsed_ontology do |ontology|
      ontology.after(:build) do |ontology|
        version = ontology.versions.build({
            commit_oid: '0'*40,
            user: nil,
            basepath: ontology.basepath,
            file_extension: ontology.file_extension
          }, without_protection: true)

        version.fast_parse = true
        version.do_not_parse!
      end
      ontology.after(:create) do |ontology|
        if ontology.parent
          locid = "#{ontology.parent.locid}//#{ontology.name}"
        else
          locid = "/#{ontology.repository.path}/#{ontology.name}"
        end
        LocId.where(
                      locid: locid,
                      assorted_object_id: ontology.id,
                      assorted_object_type: ontology.class,
                    ).first_or_create
      end
    end

    factory :single_ontology, class: SingleOntology do
    end

    factory :distributed_ontology, class: DistributedOntology do
      logic { nil }

      after(:create) do |ontology|
        LocId.where(
                      locid: "/#{ontology.repository.path}/#{ontology.name}",
                      assorted_object_id: ontology.id,
                      assorted_object_type: ontology.class,
                    ).first_or_create
      end

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
          version = ontology.versions.build({
              commit_oid: '0'*40,
              user: nil,
              basepath: ontology.basepath,
              file_extension: ontology.file_extension
            }, without_protection: true)

          version.fast_parse = true
          version.do_not_parse!

          logic = FactoryGirl.create(:logic)
          child_one = FactoryGirl.build(:ontology, :with_version,
            logic: logic,
            repository: ontology.repository)
          child_one.versions.first.parent = version

          child_two = FactoryGirl.build(:ontology, :with_version,
            logic: logic,
            repository: ontology.repository)
          child_two.versions.first.parent = version

          FactoryGirl.create(:mapping,
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
