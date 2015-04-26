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
    return not_found unless @responder
    render 'responders/show'
  end

  def new
    not_found
  end

  def edit
    not_found
  end

  def create
    @responder = Responder.new(create_params)
    if @responder.save
      render 'responders/show', status: :created
    else
      render json: { message: @responder.errors }, status: :unprocessable_entity
    end
  end

  def update
    @responder = Responder.find_by_name(params[:id])
    if @responder.update(update_params)
      render 'responders/show'
    else
      render json: { message: @responder.errors }, status: :unprocessable_entity
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

  def create_params
    params.require(:responder).permit(:type, :name, :capacity)
  end

  def update_params
    params.require(:responder).permit(:on_duty)
  end
end
