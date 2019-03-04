class ProefsController < ApplicationController
 
  # GET /proefs/1
  # GET /proefs/1.json
  def show
    @proef = Proef.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @proef }
    end
  end

  # GET /proefs/new
  # GET /proefs/new.json
  def new
    @proef = Proef.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @proef }
    end
  end

  # GET /proefs/1/edit
  def edit
    @proef = Proef.find(params[:id])
  end

  # POST /proefs
  # POST /proefs.json
  def create
    @proef = Proef.new(params[:proef])

    respond_to do |format|
      if @proef.save
        format.html { redirect_to @proef.niveau, notice: 'Test werd succesvol aangemaakt.' }
        format.json { render json: @proef, status: :created, location: @proef }
      else
        format.html { render action: "new" }
        format.json { render json: @proef.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /proef/1
  # PUT /proef/1.json
  def update
    @proef = Proef.find(params[:id])

    respond_to do |format|
      if @proef.update_attributes(params[:proef])
        format.html { redirect_to @proef, notice: 'Test werd succesvol gewijzigd.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @proef.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /proefs/1
  # DELETE /proefs/1.json
  def destroy
    @proef = Proef.find(params[:id])
    @proef.destroy

    respond_to do |format|
      format.html { redirect_to niveau_path(@proef.niveau), notice: 'Test werd succesvol verwijderd.' }
      format.json { head :no_content }
    end
  end

  def sorteren
    params[:fout].each_with_index do |id, index|
      Fout.update_all({position: index+1}, {id: id})
    end
    render nothing: true
  end
end
