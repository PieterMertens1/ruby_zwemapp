class OpmerkingsController < ApplicationController
  def index
    @opmerkings = Opmerking.order(:name)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @opmerkings }
    end
  end

  def new
    @opmerking = Opmerking.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @opmerking }
    end
  end

  def create
    @opmerking = Opmerking.new(params[:opmerking])

    respond_to do |format|
      if @opmerking.save
        format.html { redirect_to opmerkings_path, notice: 'Opmerking werd succesvol aangemaakt.' }
        format.json { render json: @opmerking, status: :created, location: @opmerking }
      else
        format.html { render action: "new" }
        format.json { render json: @opmerking.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @opmerking = Opmerking.find(params[:id])
  end

  def update
    @opmerking = Opmerking.find(params[:id])

    respond_to do |format|
      if @opmerking.update_attributes(params[:opmerking])
        format.html { redirect_to opmerkings_path, notice: 'Opmerking werd succesvol gewijzigd.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @opmerking.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @opmerking = Opmerking.find(params[:id])
    @opmerking.destroy

    respond_to do |format|
      format.html { redirect_to opmerkings_url, notice: 'Opmerking werd succesvol verwijderd.' }
      format.json { head :no_content }
    end
  end
end
