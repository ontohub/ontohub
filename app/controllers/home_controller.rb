class HomeController < ApplicationController
  
  def show
    @comments = Comment.latest.limit(10).all
    @versions = OntologyVersion.latest.limit(10).all
  end
  
end
