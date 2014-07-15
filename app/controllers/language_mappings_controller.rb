#
# Controller for LanguageMappings
#
class LanguageMappingsController < MappingsController
#  belongs_to :source, :class_name => "Language"
#  belongs_to :target, :class_name => "Language"

  load_and_authorize_resource :except => [:index, :show]

  def create
    @language_mapping.user = current_user
    super
  end

  def show
    @adjoints = resource.adjoints
  end

end
