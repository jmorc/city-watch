class EmergenciesController < ApplicationController
  before_action :set_default_response_format

  def index
    @emergencies = Emergency.all
    @full_responses = Emergency.count_full_responses
    render 'emergencies/index'
  end

  def show
    @emergency = Emergency.find_by_code(params[:id])
    if !@emergency
      render_404_error
    else
      @responder_names = @emergency.responder_names
      render 'emergencies/show'
    end
  end

  def new
    render_404_error
  end

  def edit
    render_404_error
  end

  def create
    return if unpermitted_params?
    @emergency = Emergency.new(emergency_params)


    if @emergency.save
      @emergency.dispatch_responders
      @responder_names = @emergency.responder_names
      render 'emergencies/show', status: :created
    else
      render json: { message: @emergency.errors }, status: :unprocessable_entity
    end
  end

  def update
    if params[:emergency].key?(:code)
      render json: { message: 'found unpermitted parameter: code' },
             status: :unprocessable_entity
      return
    end
    @emergency = Emergency.find_by_code(params[:id])
    @emergency.update(emergency_params)
    @responder_names = @emergency.responder_names
    render 'emergencies/show'
  end

  def destroy
    render_404_error
  end

  private

  def unpermitted_params?
    if params[:emergency].key?(:id)
      parameter_error = true
      unpermitted_parameter = 'id'
    elsif params[:emergency].key?(:resolved_at)
      parameter_error = true
      unpermitted_parameter = 'resolved_at'
    else
      parameter_error = false
    end

    if parameter_error
      message = 'found unpermitted parameter: ' + unpermitted_parameter
      render json: { message: message }, status: :unprocessable_entity
    end

    parameter_error
  end

  def render_404_error
    render json: { message: 'page not found' }, status: 404
  end

  def set_emergency
    @emergency = Emergency.find(params[:id])
  end

  def emergency_params
    params.require(:emergency).permit(:code, :fire_severity,
                                      :police_severity, :medical_severity,
                                      :full_response, :full_response, :resolved_at)
  end
end
