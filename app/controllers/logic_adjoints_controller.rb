#
# Controller for LogicAdjoints
#
class LogicAdjointsController < AdjointsController

  load_and_authorize_resource :except => [:index, :show]

  def create
    @logic_adjoint.user = current_user
    super
  end

end
