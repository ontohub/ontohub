#
# Controller for LanguageAdjoints
#
class LanguageAdjointsController < AdjointsController

  load_and_authorize_resource :except => [:index, :show]

  def create
    @language_adjoint.user = current_user
    super
  end

end
