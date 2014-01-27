require 'test_helper'

class OntologySearchTest < ActiveSupport::TestCase 

  context 'OntologySearch' do
    setup do
      @os = OntologySearch.new

      @o1 = FactoryGirl.create(:ontology)
      @o2 = FactoryGirl.create(:ontology)
      @o3 = FactoryGirl.create(:ontology)

      @ontologies = [@o1, @o2, @o3]

      @e1 = FactoryGirl.create(:entity)
      @e2 = FactoryGirl.create(:entity)
      @e3 = FactoryGirl.create(:entity)

      @entities = [@e1, @e2, @e3]

      @l1 = FactoryGirl.create(:logic)
      @l2 = FactoryGirl.create(:logic)
      @l3 = FactoryGirl.create(:logic)

      @logics = [@l1, @l2, @l3]

      @o1.entities.push @e1
      @o2.entities.push @e2
      @o3.entities.push @e3

      @o1.logic = @l1
      @o2.logic = @l2
      @o3.logic = @l3

      @e2.name = @o1.name
      @l3.name = @o1.name

      @ontologies.map(&:save)
      @entities.map(&:save)
      @logics.map(&:save)
      ::Sunspot.session = ::Sunspot.session.original_session
      Ontology.reindex

      @keywords = []
      @keywords.push({'item' => nil, 'type' => 'OntologyType'})
      @keywords.push({'item' => nil, 'type' => 'Project'})
      @keywords.push({'item' => nil, 'type' => 'FormalityLevel'})
      @keywords.push({'item' => nil, 'type' => 'LicenseModel'})
      @keywords.push({'item' => nil, 'type' => 'Task'})
    end

    teardown do
      ::Sunspot.session = ::Sunspot::Rails::StubSessionProxy.new(::Sunspot.session)     
    end

    #context 'keyword list' do
    #  should 'be generated correctly for ontologies' do
    #    @ontologies.each do |o|
    #      (0..(o.name.size-1)).each do |i|
    #        prefix = o.name[0..i]
    #        results = @os.make_global_keyword_list prefix
    #
    #        assert results.size != 0
    #
    #        results.each do |result|
    #          assert result[:text].downcase.starts_with? prefix.downcase
    #        end
    #
    #        assert results.map { |x| x[:text] }.include? o.name
    #      end
    #    end
    #  end

    #  should 'be generated correctly for entities' do
    #    @entities.each do |e|
    #      (0..(e.name.size-1)).each do |i|
    #        prefix = e.name[0..i]
    #        results = @os.make_global_keyword_list prefix
    #
    #        assert results.size != 0
    #
    #        results.each do |result|
    #          assert result[:text].downcase.starts_with? prefix.downcase
    #        end
    #
    #        assert results.map { |x| x[:text] }.include? e.name
    #      end
    #    end
    #  end
    #
    #  should 'be generated correctly for logics' do
    #    @logics.each do |l|
    #      (0..(l.name.size-1)).each do |i|
    #        prefix = l.name[0..i]
    #        results = @os.make_global_keyword_list prefix
    #
    #        assert results.size != 0
    #
    #        results.each do |result|
    #          assert result[:text].downcase.starts_with? prefix.downcase
    #        end
    #
    #        assert results.map { |x| x[:text] }.include? l.name
    #      end
    #    end
    #  end
    #end

    context 'bean list' do
      context 'with one keyword' do
        should 'be generated correctly' do
          @keywords.push({'type' => 'Mixed', 'item' => @o1.name})
          results = @os.make_bean_list_response(nil, @keywords, 1).ontologies
          results = results.map { |x| x[:name] }

          assert_equal @ontologies.size, results.size

          @ontologies.each do |o|
            assert results.include? o.name
          end
        end
      end

      context 'with two keywords' do
        should 'be generated correctly' do
          @keywords.push({'type' => 'Mixed', 'item' => @o1.name})
          @keywords.push({'type' => 'Mixed', 'item' => @e1.name})

          results = @os.make_bean_list_response(nil, @keywords, 1).ontologies
          results = results.map { |x| x[:name] }

          assert_equal 1, results.size

          assert  results.include?(@o1.name)
          assert !results.include?(@o2.name)
          assert !results.include?(@o3.name)
        end

        should 'return an empty set' do
          @keywords.push({'type' => 'Mixed', 'item' => @o2.name})
          @keywords.push({'type' => 'Mixed', 'item' => @e1.name})

          results = @os.make_bean_list_response(nil, @keywords, 1).ontologies
          results = results.map { |x| x[:name] }

          assert_equal 0, results.size

          assert !results.include?(@o1.name)
          assert !results.include?(@o2.name)
          assert !results.include?(@o3.name)
        end
      end
    end
  end
  
end
