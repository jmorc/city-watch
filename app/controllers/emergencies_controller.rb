class EmergenciesController < ApplicationController
  before_action :set_default_response_format
  before_action :set_emergency, only: [:show, :edit, :update, :destroy]

  def index
    @emergencies = Emergency.all
  end

  def show
    render 'emergencies/show'
  end

  def new
    @emergency = Emergency.new
  end

  def edit
  end

  def create
    @emergency = Emergency.new(emergency_params)
    
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
      return
    end

    if @emergency.save
      render 'emergencies/show', status: :created
    else
      render json: { message: @emergency.errors }, status: :unprocessable_entity
    end
  end

  def update
    respond_to do |format|
      if @emergency.update(emergency_params)
        format.html { redirect_to @emergency, notice: 'Emergency was successfully updated.' }
        format.json { render :show, status: :ok, location: @emergency }
      else
        format.html { render :edit }
        format.json { render json: @emergency.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @emergency.destroy
    respond_to do |format|
      format.html { redirect_to emergencies_url, notice: 'Emergency was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def render_unpermitted_param_error
    
  end

  def set_emergency
    @emergency = Emergency.find(params[:id])
  end

  def emergency_params
    params.require(:emergency).permit(:code, :fire_severity, :police_severity, :medical_severity, :full_response)
  end
end
