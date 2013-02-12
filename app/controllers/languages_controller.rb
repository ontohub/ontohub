# 
# Controller for Languages
# 
class LanguagesController < InheritedResources::Base

  respond_to :json, :xml
  has_pagination
  has_scope :search

  load_and_authorize_resource :except => [:index, :show]

  def search
    respond_to do |format|
      format.json do
        @languages = Language.where("name LIKE ?", "%" << params[:term] << "%").map(&:name)
      end
    end
  end
  
  def add_logic
    resource.add_logic(Logic.find_by_name(params[:name]))
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
    @language.user = current_user
    super
  end
  
  def show
    super do |format|
      format.html do
        @supports = resource.supports.all
        @mappings_from = resource.mappings_from
        @mappings_to = resource.mappings_to
      end
    end
  end

end
