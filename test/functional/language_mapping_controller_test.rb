require 'test_helper'

class LanguageMappingsControllerTest < ActionController::TestCase

  should_map_resources :language_mappings,
    :except => [:index]

  context 'language Mappings:' do
    setup do
      @user     = FactoryGirl.create :user
      @target_language = FactoryGirl.create :language, :user => @user
      @source_language = FactoryGirl.create :language, :user => @user
      @mapping = FactoryGirl.create :language_mapping, :source => @source_language, :target => @target_language, :user => @user
    end

    context 'signed in as owner' do
      setup do
        sign_in @user
      end

      context 'on get to show' do
        setup do
          get :show, :id => @mapping.id, :language_id => @source_language.id
        end
        should respond_with :success
        should render_template :show
        should_not set_the_flash
      end

      context 'on get to new' do
        setup do
          get :new, :language_id => @source_language.id
        end

        should respond_with :success
        should render_template :new
      end

      context 'on POST to CREATE' do
        setup do
          post :create, :language_id => @source_language.id,
            :language_mapping => {:source_id => @source_language.id,
              :target_id => @target_language.id,
              :iri => "http://test.de"
            }
        end

        should "create the record" do
          mapping = LanguageMapping.find_by_iri("http://test.de")
          assert !mapping.nil?
          assert_equal @source_language, mapping.source unless mapping.nil?
          assert_equal @target_language, mapping.target unless mapping.nil?
        end
      end

      context 'on PUT to Update' do
        setup do
          put :update, :language_id => @source_language.id, :id => @mapping.id,
            :language_mapping => {:source_id => @source_language.id,
              :target_id => @target_language.id,
              :iri => "http://test2.de"
            }
        end

        should "change the record" do
          mapping = LanguageMapping.find_by_iri("http://test2.de")
          assert !mapping.nil?
          assert_equal @source_language, mapping.source unless mapping.nil?
          assert_equal @target_language, mapping.target unless mapping.nil?
        end
      end

      context "on POST to DELETE" do
        setup do
          delete :destroy, :id => @mapping.id, :language_id => @source_language.id
        end

        should "remove the record" do
          assert_equal nil, LanguageMapping.find_by_id(@mapping.id)
        end
      end

      context "on GET to EDIT" do
        setup do
          get :edit, :id => @mapping.id, :language_id => @source_language.id
        end
        should respond_with :success
        should render_template :edit
        should_not set_the_flash
      end
    end



    context 'signed in as not-owner' do
      setup do
        @user2     = FactoryGirl.create :user
        sign_in @user2
      end

      context 'on get to show' do
        setup do
          get :show, :id => @mapping.id, :language_id => @source_language.id
        end
        should respond_with :success
        should render_template :show
        should_not set_the_flash
      end

      context 'on get to new' do
        setup do
          get :new, :language_id => @source_language.id
        end

        should respond_with :success
        should render_template :new
      end

      context 'on POST to CREATE' do
        setup do
          post :create, :language_id => @source_language.id,
            :language_mapping => {:source_id => @source_language.id,
              :target_id => @target_language.id,
              :iri => "http://test.de"
            }
        end

        should "create the record" do
          mapping = LanguageMapping.find_by_iri("http://test.de")
          assert !mapping.nil?
          assert_equal @source_language, mapping.source unless mapping.nil?
          assert_equal @target_language, mapping.target unless mapping.nil?
        end
      end

      context 'on PUT to Update' do
        setup do
          put :update, :language_id => @source_language.id, :id => @mapping.id,
            :language_mapping => {:source_id => @source_language.id,
              :target_id => @target_language.id,
              :iri => "http://test2.de"
            }
        end

        should "not change the record" do
          mapping = LanguageMapping.find_by_iri("http://test2.de")
          assert_equal nil, mapping
        end
      end

      context "on POST to DELETE" do
        setup do
          delete :destroy, :id => @mapping.id, :language_id => @source_language.id
        end

        should "not remove the record" do
          mapping = LanguageMapping.find_by_id(@mapping.id)
          assert_equal @mapping, mapping
        end
      end

      context "on GET to EDIT" do
        setup do
          get :edit, :id => @mapping.id, :language_id => @source_language.id
        end
        should respond_with :redirect
        should set_the_flash.to(/not authorized/i)
      end
    end



    context 'not signed in' do
      context 'on get to show' do
        setup do
          get :show, :id => @mapping.id, :language_id => @source_language.id
        end
        should respond_with :success
        should render_template :show
        should_not set_the_flash
      end

      context 'on get to new' do
        setup do
          get :new, :language_id => @source_language.id
        end

        should respond_with :redirect
        should set_the_flash
      end
    end

      context 'on POST to CREATE' do
        setup do
          post :create, :language_id => @source_language.id,
            :language_mapping => {:source_id => @source_language.id,
              :target_id => @target_language.id,
              :iri => "http://test.de"
            }
        end

        should "not create the record" do
          mapping = LanguageMapping.find_by_iri("http://test.de")
          assert_equal nil, mapping
        end
      end
      context 'on PUT to Update' do
        setup do
          put :update, :language_id => @source_language.id, :id => @mapping.id,
            :language_mapping => {:source_id => @source_language.id,
              :target_id => @target_language.id,
              :iri => "http://test2.de"
            }
        end

        should "not change the record" do
          mapping = LanguageMapping.find_by_iri("http://test2.de")
          assert_equal nil, mapping
        end
      end
    context "on POST to DELETE" do
        setup do
          delete :destroy, :id => @mapping.id, :language_id => @source_language.id
        end

        should "not remove the record" do
          assert_equal @mapping, LanguageMapping.find_by_id(@mapping.id)
        end
      end
  end

end
