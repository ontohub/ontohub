#
# Lists sentences of an ontology
#
class SentencesController < InheritedResources::Base

  belongs_to :ontology

  actions :index
  respond_to :json, :xml
  has_pagination

  before_filter :check_read_permissions

  protected

  def check_read_permissions
    authorize! :show, parent.repository
  end

  def collection
    if display_all?
      if logically_translated?
        Kaminari.paginate_array(parent.all_sentences).page(params[:page])
      else
        Kaminari.paginate_array(parent.translated_sentences).page(params[:page])
      end
    else
      super
    end
  end

  def logically_translated?
    parent.contains_logic_translations?
  end

  helper_method :logically_translated?
end
