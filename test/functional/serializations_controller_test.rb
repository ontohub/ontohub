require 'test_helper'

class SerializationsControllerTest < ActionController::TestCase

  should_map_resources :serializations

  context 'Serialization:' do
    setup do
      @user     = FactoryGirl.create :user
      @language = FactoryGirl.create :language, :user => @user
      @serial   = FactoryGirl.create :serialization, :language => @language
end

    context 'signed in as owner' do
      setup do
        sign_in @user
      end

      context 'on get to show' do
        setup do
          get :show, :id => @serial.id
        end
        should respond_with :success
        should render_template :show
        should_not set_the_flash
      end

      context 'on get to new' do
        setup do
          get :new
        end

        should respond_with :success
        should render_template :new
      end

      context 'on POST to CREATE' do
        setup do
          post :create, :serialization => {:name => 'test132',
              :mimetype => 'text', :language_id => @language.id }
        end

        should 'create the record' do
          serial = Serialization.find_by_name('test132')
          assert !serial.nil?
          assert_equal  'text', serial.mimetype unless serial.nil?
          assert_equal  'test132', serial.name unless serial.nil?
        end
      end

      context 'on PUT to Update' do
        setup do
          put :update, :id => @serial.id,
              :serialization => {:name => 'test4325',
                                 :mimetype => 'texttext'
              }
        end

        should 'change the record' do
          serial = Serialization.find_by_name('test4325')
          assert !serial.nil?
          assert_equal 'test4325', serial.name unless serial.nil?
          assert_equal 'texttext', serial.mimetype unless serial.nil?
        end
      end

      context 'on POST to DELETE' do
        setup do
          delete :destroy, :id => @serial.id
        end

        should 'remove the record' do
          assert_equal nil, Serialization.find_by_id(@serial.id)
        end


      end

      context 'on GET to EDIT' do
        setup do
          get :edit, :id => @serial.id
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
          get :show, :id => @serial.id
        end
        should respond_with :success
        should render_template :show
        should_not set_the_flash
      end

      context 'on get to new' do
        setup do
          get :new
        end

        should respond_with :success
        should render_template :new
      end

      context 'on POST to CREATE' do
        setup do
          post :create, :serialization => {:name => 'test132',
                                           :mimetype => 'text', :language_id => @language.id }
        end

        should 'create the record' do
          serial = Serialization.find_by_name('test132')
          assert !serial.nil?
          assert_equal  'text', serial.mimetype unless serial.nil?
          assert_equal  'test132', serial.name unless serial.nil?
        end
      end

      context 'on PUT to Update' do
        setup do
          put :update, :id => @serial.id,
              :serialization => {:name => 'test4325',
                                 :mimetype => 'texttext'
              }
        end

        should 'change the record' do
          serial = Serialization.find_by_name('test4325')
          assert !serial.nil?
          assert_equal 'test4325', serial.name unless serial.nil?
          assert_equal 'texttext', serial.mimetype unless serial.nil?
        end
      end

      context 'on POST to DELETE' do
        setup do
          delete :destroy, :id => @serial.id
        end

        should 'remove the record' do
          assert_equal nil, Serialization.find_by_id(@serial.id)
        end


      end

      context 'on GET to EDIT' do
        setup do
          get :edit, :id => @serial.id
        end
        should respond_with :success
        should render_template :edit
        should_not set_the_flash
      end
    end



    context 'not signed in' do
      context 'on get to show' do
        setup do
          get :show, :id => @serial.id, :language_id => @language.id
        end
        should respond_with :success
        should render_template :show
        should_not set_the_flash
      end

      context 'on get to new' do
        setup do
          get :new, :language_id => @language.id
        end

        should respond_with :redirect
        should set_the_flash
      end

      context 'on POST to CREATE' do
        setup do
          put :update, :id => @serial.id,
              :serialization => {:name => 'test2',
                                 :mimetype => 'text',
                                 :language_id => @language.id
              }
        end

        should 'not create the record' do
          serial = Serialization.find_by_name('test2')
          assert_equal nil, serial
        end
      end
      context 'on PUT to Update' do
        setup do
          put :update, :id => @serial.id,
              :serialization => {:name => 'test2',
                                 :mimetype => 'text',
                                 :language_id => @language.id
              }
        end

        should 'not change the record' do
          serial = Serialization.find_by_name('test2')
          assert_equal nil, serial
        end
      end
      context 'on POST to DELETE' do
        setup do
          delete :destroy, :id => @serial.id
        end

        should 'not remove the record' do
          assert_equal @serial, Serialization.find_by_id(@serial.id)
        end
      end
    end
  end

end
