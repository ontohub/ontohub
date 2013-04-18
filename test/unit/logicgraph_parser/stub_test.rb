require 'test_helper'

class LogicgraphParser::StubTest < ActiveSupport::TestCase

  def save_language(language)
    language.user_id = @user.id
    language.save!
    print language.inspect
    print "\n"
    print language.serializations
    print "\n"
  end

  def save_logic(logic)
    logic.user_id = @user.id
    logic.save!
    print logic.inspect
    print "\n"
  end

  def save_support(support)
    support.save!
    print "\n"
  end

  def save_logic_mapping(comorphism)
    print "LOGIC MAPPING\n"
  end

  context "LogicgraphParser" do

    context 'parsing stub' do
      setup do
        print "\nPARSING "
        @user = User.new
        @user.email = 'admin@example.com'
        @user.name = 'Admin'
        @user.password = 'foobar'
        @user.save!
        LogicgraphParser.parse open_fixture('LogicGraph.xml'),
          logic:           Proc.new{ |h| save_logic(h) },
          language:        Proc.new{ |h| save_language(h) },
          support:         Proc.new{ |h| save_support(h) },
          logic_mapping:   Proc.new{ |h| save_logic_mapping(h) }
      end

      should 'set up correctly' do
      end

      #should 'find logic' do
      #  print "LOGICS:\n"
      #  print @logic
      #  print "\n"
        #assert_equal 'CASL', @ontologies.first['logic']
      #end

      #should 'find comorphism' do
      #  print "COMORPHISM:\n"
      #  print @comorphism
      #  print "\n"
        #assert_equal 2, @symbols.count
      #end

      #should 'find source sublogic' do
      #  print "SOURCE SUBLOGIC:\n"
      #  print @source_sublogic
      #  print "\n"
        #assert_equal 1, @axioms.count
      #end
 
      #should 'find target sublogic' do
      #  print "TARGET SUBLOGIC:\n"
      #  print @target_sublogic
      #  print "\n"
        #assert_equal [
        #  {"name"=>"s", "range"=>"/home/till/CASL/Hets-lib/test/test1.casl:2.8", "kind"=>"sort", "text"=>"sort s"},
        #  {"name"=>"f", "range"=>"/home/till/CASL/Hets-lib/test/test1.casl:3.6", "kind"=>"op", "text"=>"op f : s -> s"}
        #], @symbols
      #end
      
      #should 'have correct comorphism' do
        #assert_equal [{
        #  "name"    => "Ax1",
        #  "range"   => "/home/till/CASL/Hets-lib/test/test1.casl:3.8-4.25",
        #  "symbols" => ["op f : s -> s", "sort s"],
        #  "text"    => "forall x : <s . >f(x) = x %(Ax1)%>"
        #}], @axioms
      #end
    end

  end
  
  def open_fixture(name)
    File.open("#{Rails.root}/registry/#{name}")
  end
  
end
