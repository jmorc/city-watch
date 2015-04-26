class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  before_action :set_default_response_format

  ActionController::Parameters.action_on_unpermitted_parameters = :raise

  rescue_from ActionController::RoutingError, with: :render_404
  rescue_from ActionController::UnpermittedParameters, with: :unpermitted_params

  def set_default_response_format
    request.format = :json unless params[:format]
  end

  def render_404
    render json: { message: 'page not found' }, status: 404
  end

  def not_found
    fail ActionController::RoutingError, 'Not Found'
  end

  def unpermitted_params(error)
    render json: { message: error.to_s }, status: :unprocessable_entity
  end
end
