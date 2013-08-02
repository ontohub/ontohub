require 'test_helper'

class LogicgraphParser::StubTest < ActiveSupport::TestCase

  def save_language(language)
    language.user_id = @user.id
    language.save!
  end

  def save_logic(logic)
    logic.user_id = @user.id
    logic.save!
  end

  def save_support(support)
    support.save!
  end

  def save_logic_mapping(comorphism)
  end

  context "LogicgraphParser" do

    context 'parsing stub' do
      setup do
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
    end

  end
  
  def open_fixture(name)
    File.open("#{Rails.root}/registry/#{name}")
  end
  
end
