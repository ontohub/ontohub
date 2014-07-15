require 'test_helper'

class LogicAdjointsControllerTest < ActionController::TestCase

  should_map_resources :logic_adjoints,
    :except => [:index]

  context 'Logic Adjoint:' do
    setup do
      @user     = FactoryGirl.create :user
      @target_logic = FactoryGirl.create :logic, :user => @user
      @source_logic = FactoryGirl.create :logic, :user => @user
      @mapping = FactoryGirl.create :logic_mapping, :source => @source_logic, :target => @target_logic, :user => @user
      @target_logic2 = FactoryGirl.create :logic, :user => @user
      @source_logic2 = FactoryGirl.create :logic, :user => @user
      @mapping2 = FactoryGirl.create :logic_mapping, :source => @source_logic2, :target => @target_logic2, :user => @user
      @adjoint = FactoryGirl.create :logic_adjoint, :translation => @mapping, :projection => @mapping2, :user => @user
    end

    context 'signed in as owner' do
      setup do
        sign_in @user
      end

      context 'on get to show' do
        setup do
          get :show, :id => @adjoint.id, :mapping_id => @mapping.id
        end
        should respond_with :success
        should render_template :show
        should_not set_the_flash
      end

      context 'on get to new' do
        setup do
          get :new, :mapping_id => @mapping.id
        end

        should respond_with :success
        should render_template :new
      end

      context 'on POST to CREATE' do
        setup do
          post :create, :logic_mapping_id => @mapping.id,
            :logic_adjoint => {:translation_id => @mapping.id,
              :projection_id => @mapping2.id,
              :iri => 'http://test.de'
            }
        end

        should 'create the record' do
          adjoint = LogicAdjoint.find_by_iri('http://test.de')
          assert !adjoint.nil?
          assert_equal  @mapping, adjoint.translation unless adjoint.nil?
          assert_equal  @mapping2, adjoint.projection unless adjoint.nil?
        end
      end

      context 'on PUT to Update' do
        setup do
          put :update, :id => @adjoint.id,
              :logic_adjoint => {:translation_id => @mapping.id,
                                 :projection_id => @mapping2.id,
                                 :iri => "http://test2.de"
              }
        end

        should 'change the record' do
          adjoint = LogicAdjoint.find_by_iri('http://test2.de')
          assert !adjoint.nil?
          assert_equal @mapping, adjoint.translation unless adjoint.nil?
          assert_equal @mapping2, adjoint.projection unless adjoint.nil?
        end
      end

      context 'on POST to DELETE' do
        setup do
          delete :destroy, :id => @adjoint.id, :mapping_id => @mapping.id
        end

        should 'remove the record' do
          assert_equal nil, LogicAdjoint.find_by_id(@adjoint.id)
        end


      end

      context 'on GET to EDIT' do
        setup do
          get :edit, :id => @adjoint.id, :mapping_id => @mapping.id
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
          get :show, :id => @adjoint.id, :mapping_id => @mapping.id
        end
        should respond_with :success
        should render_template :show
        should_not set_the_flash
      end

      context 'on get to new' do
        setup do
          get :new, :mapping_id => @mapping.id
        end

        should respond_with :success
        should render_template :new
      end

      context 'on POST to CREATE' do
        setup do
          post :create, :logic_mapping_id => @mapping.id,
               :logic_adjoint => {:translation_id => @mapping.id,
                                  :projection_id => @mapping2.id,
                                  :iri => 'http://test.de'
               }
        end

        should "create the record" do
          adjoint = LogicAdjoint.find_by_iri("http://test.de")
          assert !adjoint.nil?
          assert_equal @mapping, adjoint.translation unless adjoint.nil?
          assert_equal @mapping2, adjoint.projection unless adjoint.nil?
        end
      end

      context 'on PUT to Update' do
        setup do
          put :update, :id => @adjoint.id,
              :logic_adjoint => {:translation_id => @mapping.id,
                                 :projection_id => @mapping2.id,
                                 :iri => "http://test2.de"
              }
        end

        should "not change the record" do
          adjoint = LogicAdjoint.find_by_iri("http://test2.de")
          assert_equal nil, adjoint
        end
      end

      context "on POST to DELETE" do
        setup do
          delete :destroy, :id => @adjoint.id, :translation_id => @mapping.id
        end

        should "not remove the record" do
          adjoint = LogicAdjoint.find_by_id(@adjoint.id)
          assert_equal @adjoint, adjoint
        end
      end

      context "on GET to EDIT" do
        setup do
          get :edit, :id => @adjoint.id, :translation_id => @mapping.id
        end
        should respond_with :redirect
        should set_the_flash.to(/not authorized/i)
      end
    end



    context 'not signed in' do
      context 'on get to show' do
        setup do
          get :show, :id => @adjoint.id, :translation_id => @mapping.id
        end
        should respond_with :success
        should render_template :show
        should_not set_the_flash
      end

      context 'on get to new' do
        setup do
          get :new, :translation_id => @mapping.id
        end

        should respond_with :redirect
        should set_the_flash
      end

      context 'on POST to CREATE' do
        setup do
          post :create, :logic_mapping_id => @mapping.id,
               :logic_adjoint => {:translation_id => @mapping.id,
                                  :projection_id => @mapping2.id,
                                  :iri => 'http://test.de'
               }
        end

        should "not create the record" do
          adjoint = LogicAdjoint.find_by_iri("http://test.de")
          assert_equal nil, adjoint
        end
      end
      context 'on PUT to Update' do
        setup do
          put :update, :id => @adjoint.id,
              :logic_adjoint => {:translation_id => @mapping.id,
                                 :projection_id => @mapping2.id,
                                 :iri => "http://test2.de"
              }
        end

        should 'not change the record' do
          adjoint = LogicAdjoint.find_by_iri('http://test2.de')
          assert_equal nil, adjoint
        end
      end
      context 'on POST to DELETE' do
        setup do
          delete :destroy, :id => @adjoint.id, :translation_id => @mapping.id
        end

        should "not remove the record" do
          assert_equal @adjoint, LogicAdjoint.find_by_id(@adjoint.id)
        end
      end
    end
  end

end
