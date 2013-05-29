require 'test_helper'

class Admin::CategoriesControllerTest < ActionController::TestCase
  
  should route(:get, "admin/categories").to(:controller => 'admin/categories', :action => :index)

  should route(:post, "admin/categories").to(:controller => 'admin/categories', :action => :create)

  should route(:get, "admin/categories/new").to(:controller => 'admin/categories', :action => :new)
  
  should route(:get, "admin/categories/id/edit").to(:controller => 'admin/categories', :action => :edit, :id => 'id')
  
  should route(:put, "admin/categories/id").to(:controller => 'admin/categories', :action => :update, :id => 'id')

  should route(:delete, "admin/categories/id").to(:controller => 'admin/categories', :action => :destroy, :id => 'id')

  context 'Category controller' do
    setup do
      sign_in FactoryGirl.create :admin
      @category = FactoryGirl.create :category
    end
    
    context 'on GET to index' do
      setup do
        get :index
      end
      should respond_with :success
    end
    
    context 'on new action' do
      setup do
        get :new
      end
      should render_template(:partial => '_form')
      should respond_with :success
    end

    context 'on create action' do
      setup do
        post :create, :category => FactoryGirl.attributes_for(:category)
      end
      should redirect_to("admin::category#index"){ admin_categories_path } 
    end
    
    context 'on edit' do
      setup do
        put :edit, :id => @category.id
      end
      should render_template(:partial => '_form')
      should respond_with :success
    end
    
    context 'on update' do
      setup do
        put :update, :id => @category.id, :category => FactoryGirl.attributes_for(:category) 
      end
      should respond_with :redirect
    end

    context 'on destroy' do
      setup do
        delete :destroy, :id => @category.id
      end
      should respond_with :redirect
    end

  end
    
end
