class DagsController < ApplicationController
  before_filter :authenticate_lesgever!
  # GET /dags
  # GET /dags.json
  def index
    @dags = Dag.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @dags }
    end
  end

  # GET /dags/1
  # GET /dags/1.json
  def show
    @dag = Dag.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @dag }
    end
  end

  # GET /dags/new
  # GET /dags/new.json
  def new
    @dag = Dag.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @dag }
    end
  end

  # GET /dags/1/edit
  def edit
    @dag = Dag.find(params[:id])
  end

  # POST /dags
  # POST /dags.json
  def create
    @dag = Dag.new(params[:dag])

    respond_to do |format|
      if @dag.save
        format.html { redirect_to @dag, notice: 'Dag was successfully created.' }
        format.json { render json: @dag, status: :created, location: @dag }
      else
        format.html { render action: "new" }
        format.json { render json: @dag.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /dags/1
  # PUT /dags/1.json
  def update
    @dag = Dag.find(params[:id])

    respond_to do |format|
      if @dag.update_attributes(params[:dag])
        format.html { redirect_to @dag, notice: 'Dag was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @dag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dags/1
  # DELETE /dags/1.json
  def destroy
    @dag = Dag.find(params[:id])
    @dag.destroy

    respond_to do |format|
      format.html { redirect_to dags_url }
      format.json { head :no_content }
    end
  end
end
