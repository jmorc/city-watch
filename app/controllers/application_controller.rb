class ApplicationController < ActionController::Base
  before_action :set_default_response_format

  ActionController::Parameters.action_on_unpermitted_parameters = :raise

  rescue_from ActionController::RoutingError, with: :render_404
  rescue_from ActionController::ParameterMissing, with: :missing_params
  rescue_from ActionController::UnpermittedParameters, with: :unpermitted_params


  def set_default_response_format
    request.format = :json unless params[:format]
  end

  def render_404
    render json: { message: 'page not found' }, status: 404
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def missing_params
  end

  def unpermitted_params
  end


end
