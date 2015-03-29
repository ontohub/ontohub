class Api::V1::CombinationsController < Api::V1::Base
  inherit_resources
  belongs_to :repository, finder: :find_by_path!
  belongs_to :ontology, optional: true

  actions :create, :update

  before_filter :check_write_permission

  def create
    if combination.save
      response.status = 201
      response.location = combination.ontology.locid
      render json: {status: response.message, location: response.location}
    else
      response.status = 400
      render json: {status: response.message,
                    error: combination.error.message}
    end
  end

  private
  def combination
    @combination ||= Combination.build(repository, json_body)
  end

  def json_body
    ActiveSupport::JSON.decode(request.raw_post)
  rescue ActiveSupport::JSON.parse_error
  end

  def repository
    association_chain.first
  end

  def check_write_permission
    authorize! :write, repository
  end
end
