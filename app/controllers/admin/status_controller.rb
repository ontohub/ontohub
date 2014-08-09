class Admin::StatusController < InheritedResources::Base

  before_filter :authenticate_admin!

  def index
    @tab = params[:tab].try(:to_sym) || StatusViewhelper::DEFAULT_TAB
  end

end
