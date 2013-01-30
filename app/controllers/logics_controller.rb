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
        #language = Language.find(params[:id])
        @logics = Logic.where("name LIKE ?", "%" << params[:term] << "%").map(&:name)
        #language.supports.each do |support|
        #  @logics.delete support
        #end
      end
    end
  end
  
  def addLanguage
    resource.addLanguage(Language.find_by_name(params[:name]))
    respond_to do |format|
      format.html {redirect_to :action => 'show'}
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
