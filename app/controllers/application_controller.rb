class ApplicationController < ActionController::Base

  def set_default_response_format
    request.format = :json unless params[:format]
  end
end
