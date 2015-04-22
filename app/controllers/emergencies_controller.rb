class EmergenciesController < ApplicationController
  before_action :set_emergency, only: [:show, :edit, :update, :destroy]

  def index
    @emergencies = Emergency.all
  end

  def show
  end

  def new
    @emergency = Emergency.new
  end

  def edit
  end

  def create
    @emergency = Emergency.new(emergency_params)

    respond_to do |format|
      if @emergency.save
        format.html { redirect_to @emergency, notice: 'Emergency was successfully created.' }
        format.json { render :show, status: :created, location: @emergency }
      else
        format.html { render :new }
        format.json { render json: @emergency.errors, status: :unprocessable_entity }
      end
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

  def set_emergency
    @emergency = Emergency.find(params[:id])
  end

  def emergency_params
    params[:emergency]
  end
end
