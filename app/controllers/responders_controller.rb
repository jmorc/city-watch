class RespondersController < ApplicationController
  def index
    @responders = Responder.all

    if params.key?(:show)
      capacity = Responder.report_capacity
      render json: { capacity: capacity }
      return
    end
    render 'responders/index'
  end

  def show
    @responder = Responder.find_by_name(params[:id])
    unless @responder
      not_found
      return
    end
    render 'responders/show'
  end

  def new
    not_found
  end

  def edit
    @responder = Responder.find_by_name(params[:name])
    not_found unless @responder
  end

  def create
    @responder = Responder.new(responder_params)
    if @responder.save
      render 'responders/show', status: :created
    else
      render_create_errors(@responder)
    end
  end

  def update
    if responder_params.key?(:on_duty)
      @responder = Responder.find_by_name(params[:id])
      @responder.update_attribute(:on_duty, responder_params[:on_duty])
      render 'responders/show'
    else
      message = 'found unpermitted parameter: ' + responder_params.keys[0]
      render json: { message: message }, status: :unprocessable_entity
    end
  end

  def destroy
    @responder = Responder.find_by_name(params[:name])
    if @responder.nil?
      not_found
    else
      @responder.destroy unless @responder.nil?
    end
  end

  private

  def render_create_errors(responder)
    unpermitted_parameter = check_unpermitted_params(responder)
    if unpermitted_parameter[0]
      message = 'found unpermitted parameter: ' + unpermitted_parameter[1]
      render json: { message: message }, status: :unprocessable_entity
    else
      responder.errors.delete(:on_duty)
      responder.errors.delete(:id)
      responder.errors.delete(:emergency_code)
      render json: { message: @responder.errors }, status: :unprocessable_entity
    end
  end

  def check_unpermitted_params(responder)
    if responder.errors[:on_duty][0] == 'on_duty present'
      unpermitted_parameter = [true, 'on_duty']
    elsif responder.errors[:emergency_code][0] == 'emergency_code present'
      unpermitted_parameter = [true, 'emergency_code']
    elsif responder.errors[:id][0] == 'id present'
      unpermitted_parameter = [true, 'id']
    else
      unpermitted_parameter = [false]
    end
    unpermitted_parameter
  end

  def responder_params
    params.require(:responder).permit(:type, :name, :capacity, :id, :on_duty, :emergency_code)
  end
end
