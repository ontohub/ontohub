require 'test_helper'

class Admin::CategoriesControllerTest < ActionController::TestCase
  
  should route(:get, "admin/categories").to(:controller => 'admin/categories', :action => :index)

# should route(:post, "/categories").to(:controller => 'admin/categories', :action => :create)

# should route(:post, "/categories/new").to(:controller => 'admin/categories', :action => :new)
# 
# should route(:edit, "/categories/id/edit").to(:controller => 'admin/categories', :action => :edit)
# 
# should route(:put, "/categories/id").to(:controller => 'admin/categories', :action => :update)

# should route(:delete, "/categories/id").to(:controller => 'admin/categories', :action => :destroy)

# context 'Ontology Instance' do
#   setup do
#     @ontology = FactoryGirl.create :ontology
#   end
#   
#   context 'on GET to index' do
#     setup do
#       get :index, :ontology_id => @ontology.to_param
#     end
#     
#     should respond_with :success
#   end
#   
# end
  
end
