module HistoryHelper
  def repository
    @repository ||= Repository.find_by_path!(params[:repository_id])
  end

  def ontology
    @ontology ||= repository.primary_ontology(path)
  end

  def ref
    params[:ref] || 'master'
  end

  def commit_id
    @commit_id ||= repository.commit_id(params[:ref])
  end

  def oid
    @oid ||= commit_id[:oid] unless commit_id.nil?
  end

  def path
    params[:path]
  end
end
