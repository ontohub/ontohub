class Api::V1::CombinationsController < Api::V1::Base
  inherit_resources
  belongs_to :repository, finder: :find_by_path!
  belongs_to :ontology, optional: true

  actions :create, :update

  before_filter :check_write_permission

  def create
    if combination.valid?
      response.status = 202
      response.location = action_iri_path(action)
      render json: {status: response.message, location: response.location}
    else
      response.status = 400
      render json: {status: response.message,
                    error: errors_str}
    end
  end

  private
  def combination
    @combination ||= Combination.
      build(current_user, repository, params[:combination])
  end

  def action
    args = [current_user.id, repository.id, params[:combination]]
    @action ||= Action.
      enclose!(3.minutes, Combination, :combined_ontology!, *args)
  end

  def errors_str
    combination.errors.messages.to_a.
      map { |(f, m)| "#{f}: #{m.join(', ')}" }.join(';')
  end

  def repository
    association_chain.first
  end

  def check_write_permission
    authorize! :write, repository
  end
end
