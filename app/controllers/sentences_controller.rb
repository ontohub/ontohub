#
# Lists sentences of an ontology
#
class SentencesController < InheritedResources::Base

  belongs_to :ontology

  actions :index
  has_pagination

  respond_to :html, only: %i(index)

  before_filter :check_read_permissions

  protected

  def check_read_permissions
    authorize! :show, parent.repository
  end

  def collection
    @collection ||=
      if display_all?
        sentences =
          if logically_translated?
            parent.all_sentences
          else
            parent.translated_sentences
          end
        Kaminari.paginate_array(sentences).page(params[:page])
      else
        super
      end
  end

  def logically_translated?
    parent.contains_logic_translations?
  end

  helper_method :logically_translated?
end
