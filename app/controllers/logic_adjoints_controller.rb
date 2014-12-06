#
# Controller for LogicAdjoints
#
class LogicAdjointsController < AdjointsController

  #after_action :verify_authorized, :except => [:index, :show]

  def create
    @logic_adjoint.user = current_user
    super
  end

end
