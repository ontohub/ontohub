#
# Controller for LogicMappings
#
class LogicMappingsController < GeneralMappingsController
#  belongs_to :source, :class_name => "Logic"
#  belongs_to :target, :class_name => "Logic"
  defaults finder: :find_by_slug!

  load_and_authorize_resource :except => [:index, :show]

  def create
    @logic_mapping.user = current_user
    super
  end

  def show
    @adjoints = resource.adjoints
  end

end
