#
# Controller for LanguageAdjoints
#
class LanguageAdjointsController < AdjointsController

  #after_action :verify_authorized, :except => [:index, :show]

  def create
    @language_adjoint.user = current_user
    super
  end

end
