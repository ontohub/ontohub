# require 'test_helper'

# class OntologyParser::ComplexTest < ActiveSupport::TestCase

#   context "OntologyParser" do

#     context 'parsing distributed XML' do
#       setup do
#         @ontologies = []
#         @symbols    = []
#         @axioms     = []
#         @links      = []
#         OntologyParser.parse open_fixture('test2.xml'),
#           ontology: Proc.new{ |h| @ontologies << h },
#           symbol:   Proc.new{ |h| @symbols << h },
#           axiom:    Proc.new{ |h| @axioms << h },
#           link:     Proc.new{ |h| @links << h }
#       end

#       should 'find all ontologies' do
#         assert_equal 4, @ontologies.count
#       end

#       should 'found all symbols' do
#         assert_equal 2, @symbols.count
#       end

#       should 'found all axioms' do
#         assert_equal 2, @axioms.count
#       end

#       should 'found all links' do
#         assert_equal 3, @links.count
#       end

#       context 'first link' do
#         setup do
#           @link = @links.first
#         end

#         should 'have correct linkid' do
#           assert_equal "0", @link['linkid']
#         end

#         should 'have correct source' do
#           assert_equal "sp__E1", @link['source']
#         end

#         should 'have correct target' do
#           assert_equal "sp__T", @link['target']
#         end

#         should 'have correct type' do
#           assert_equal "GlobalDefInc", @link['type']
#         end

#         should 'have correct morphism' do
#           assert_equal "id_CASL.SubPCSOL=E", @link['morphism']
#         end
#       end

#     end

#   end

#   context "Bulding Links with Link version" do
#     setup do
#       @user = FactoryGirl.create :user
#       @ontology = FactoryGirl.create :distributed_ontology
#       evaluator = Hets::Evaluator.new(@user, @ontology,
#                                       path: fixture_file('links.xml'),
#                                       code_path: nil)
#       evaluator.import
#     end


#     should "have LinkVersion" do
#       links = Link.all
#       assert_not_empty links
#       links.each do |link|
#         assert_not_nil link.versions.first
#       end
#     end
#   end

#   context "Building Links with entity Mapping" do
#     setup do
#       @ontologies = []
#       @symbols    = []
#       @axioms     = []
#       @links      = []
#       OntologyParser.parse open_fixture('links.xml'),
#         ontology: Proc.new{ |h| @ontologies << h },
#         symbol:   Proc.new{ |h| @symbols << h },
#         axiom:    Proc.new{ |h| @axioms << h },
#         link:     Proc.new{ |h| @links << h }
#     end
#     should "have entity mapping" do
#       link = @links[1]
#       assert_equal link["map"].first["text"], "sort s"
#     end
#   end

# end
