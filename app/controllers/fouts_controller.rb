class FoutsController < ApplicationController

  # GET /fouts/new
  # GET /fouts/new.json
  def new
    # http://stackoverflow.com/questions/11817496/how-to-use-selected-with-grouped-collection-select
    @fout = Fout.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @fout }
    end
  end

  # GET /fouts/1/edit
  def edit
    @fout = Fout.find(params[:id])
  end

  # POST /fouts
  # POST /fouts.json
  def create
    # https://groups.google.com/forum/?fromgroups=#!topic/plataformatec-simpleform/Ii2qSmviLJ0  input als block voor grouped_collection_select
    @fout = Fout.new(params[:fout])

    respond_to do |format|
      if @fout.save
        format.html { redirect_to @fout.proef, notice: 'Fout werd succesvol aangemaakt.' }
        format.json { render json: @fout, status: :created, location: @fout }
      else
        format.html { render action: "new" }
        format.json { render json: @fout.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /fouts/1
  # PUT /fouts/1.json
  def update
    @fout = Fout.find(params[:id])

    respond_to do |format|
      if @fout.update_attributes(params[:fout])
        format.html { redirect_to @fout.proef, notice: 'Fout werd succesvol gewijzigd.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @fout.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fouts/1
  # DELETE /fouts/1.json
  def destroy
    @fout = Fout.find(params[:id])
    @fout.destroy

    respond_to do |format|
      format.html { redirect_to proef_path(@fout.proef), notice: 'Fout werd succesvol verwijderd.' }
      format.json { head :no_content }
    end
  end
end
