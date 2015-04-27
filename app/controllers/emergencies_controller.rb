class EmergenciesController < ApplicationController
  def index
    @emergencies = Emergency.all
    @full_responses = Emergency.count_full_responses
    render 'emergencies/index'
  end

  def show
    @emergency = Emergency.find_by_code(params[:id])
    if !@emergency
      not_found
    else
      @responder_names = @emergency.responder_names
      render 'emergencies/show'
    end
  end

  def new
    not_found
  end

  def edit
    not_found
  end

  def create
    @emergency = Emergency.new(emergency_create_params)

    if @emergency.save
      @emergency.dispatch_responders
      @responder_names = @emergency.responder_names
      render 'emergencies/show', status: :created
    else
      render json: { message: @emergency.errors }, status: :unprocessable_entity
    end
  end

  def update
    @emergency = Emergency.find_by_code(params[:id])
    if @emergency.update(emergency_update_params)
      @emergency.responders.clear if @emergency.resolved?
      @responder_names = @emergency.responder_names
      render 'emergencies/show'
    else
      render json: { message: @emergency.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    not_found
  end

  private

  def emergency_create_params
    params.require(:emergency).permit(:fire_severity,
                                      :police_severity,
                                      :medical_severity, :code)
  end

  def emergency_update_params
    params.require(:emergency).permit(:fire_severity,
                                      :police_severity,
                                      :medical_severity, :resolved_at)
  end
end
