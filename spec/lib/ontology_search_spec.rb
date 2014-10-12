require 'spec_helper'

describe OntologySearch do
  WebMock.allow_net_connect!(net_http_connect_on_start: true)
  context 'OntologySearch' do
    let!(:os) { OntologySearch.new }

    let!(:l1) { FactoryGirl.create :logic }
    let!(:l2) { FactoryGirl.create :logic }
    let!(:l3) { FactoryGirl.create :logic, name: o1.name }

    let!(:o1) { FactoryGirl.create :ontology, logic: l1 }
    let!(:o2) { FactoryGirl.create :ontology, logic: l2 }
    let!(:o3) { FactoryGirl.create :ontology, logic: l3 }

    let(:e1) { FactoryGirl.create :entity }
    let(:e2) { FactoryGirl.create :entity, name: o1.name }
    let(:e3) { FactoryGirl.create :entity }

    let(:ontologies) { [o1, o2, o3] }
    let(:entities) { [e1, e2, e3] }
    let(:logics) { [l1, l2, l3] }

    let(:keywords) do
      [
        {'item' => nil, 'type' => 'OntologyType'},
        {'item' => nil, 'type' => 'Project'},
        {'item' => nil, 'type' => 'FormalityLevel'},
        {'item' => nil, 'type' => 'LicenseModel'},
        {'item' => nil, 'type' => 'Task'}
      ]
    end

    before do
      o1.entities.push e1
      o2.entities.push e2
      o3.entities.push e3

      ontologies.map(&:save)

      ::Sunspot.session = ::Sunspot.session.original_session
      Ontology.reindex
    end

    after do
      ::Sunspot.session = ::Sunspot::Rails::StubSessionProxy.new(::Sunspot.session)
    end

    context 'bean list' do
      context 'with one keyword' do
        context 'be generated correctly' do
          let(:keywords_search) do
            keywords + [{'type' => 'Mixed', 'item' => o1.name}]
          end
          let(:results) do
            os.make_bean_list_response(nil, keywords_search, 1).ontologies.
              map { |x| x[:name] }
          end

          it 'have enough results' do
            expect(results.size).to eq(ontologies.size)
          end

          it 'have all ontologies' do
            ontologies.each do |o|
              expect(results).to include(o.name)
            end
          end
        end
      end

      context 'with two keywords' do
        context 'be generated correctly' do
          let(:keywords_search) do
            keywords + [
              {'type' => 'Mixed', 'item' => o1.name},
              {'type' => 'Mixed', 'item' => e1.name}
            ]
          end
          let(:results) do
            os.make_bean_list_response(nil, keywords_search, 1).ontologies.
              map { |x| x[:name] }
          end

          it 'have one result' do
            expect(results.size).to eq(1)
          end

          it "have the correct ontology in the results" do
            expect(results).to include(o1.name)
          end
        end

        context 'return an empty set' do
          let(:keywords_search) do
            keywords + [
              {'type' => 'Mixed', 'item' => o2.name},
              {'type' => 'Mixed', 'item' => e1.name}
            ]
          end
          let(:results) do
            os.make_bean_list_response(nil, keywords_search, 1).ontologies.
              map { |x| x[:name] }
          end

          it 'have an empty result' do
            expect(results).to be_empty
          end
        end
      end
    end
  end
end
