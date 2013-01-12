# 
# Controller for Logics
# 
class LogicsController < InheritedResources::Base

  respond_to :json, :xml
  has_pagination
  has_scope :search

  load_and_authorize_resource :except => [:index, :show]
  
  def search
    respond_to do |format|
      format.json do
        @logics = Logic.all.map(&:name)
      end
    end
  end
  
  def index
    super do |format|
      format.html do
        @search = params[:search]
        @search = nil if @search.blank?
      end
    end
  end

  def create
    @logic.user = current_user
    super
  end
  
  def show
    super do |format|
      format.html do
        @supports = resource.supports.all
      end
    end
  end

end
