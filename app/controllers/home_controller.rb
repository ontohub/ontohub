class HomeController < ApplicationController
  
  def show
    @versions = OntologyVersion.limit(10).order('id DESC').all
  end
  
end
