class RespondersController < ApplicationController
  before_action :set_responder, only: [:show, :edit, :update, :destroy]
  before_action :set_default_response_format
  
  def index
    @responders = Responder.all
  end

  def show
    render 'responders/show'
  end

  def new
    @responder = Responder.new
  end

  def edit
  end

  def create
    @responder = Responder.new(responder_params)
      if @responder.save
        render 'responders/show', status: :created
      else

        if @responder.errors[:on_duty][0] == "on_duty present"
          unpermitted_parameter = [true, "on_duty"]
        elsif @responder.errors[:emergency_code][0] == "emergency_code present"
          unpermitted_parameter = [true, "emergency_code"]
        elsif @responder.errors[:id][0] == "id present"
          unpermitted_parameter = [true, "id"]
        else
          unpermitted_parameter = [false]
        end

        if unpermitted_parameter[0]
          message = "found unpermitted parameter: " + unpermitted_parameter[1]
          render json: {message: message}, status: :unprocessable_entity
        else
          @responder.errors.delete(:on_duty)
          @responder.errors.delete(:id)
          @responder.errors.delete(:emergency_code)
          render json: { message: @responder.errors }, status: :unprocessable_entity
        end
      end
  end

  def update
      if @responder.update(responder_params)
        render 'responders/show', notice: 'Responder was successfully updated.'
      else
        format.json { render json: @responder.errors, status: :unprocessable_entity }
      end
  end

  def destroy
    @responder.destroy
    respond_to do |format|
      format.html { redirect_to responders_url, notice: 'Responder was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_responder
      @responder = Responder.find(params[:id])
    end

    def set_default_response_format
      request.format = :json unless params[:format]
    end

    def responder_params
      params.require(:responder).permit(:type, :name, :capacity, :id, :on_duty, :emergency_code)
    end
end
