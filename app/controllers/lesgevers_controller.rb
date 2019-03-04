class LesgeversController < ApplicationController
  before_filter :authenticate_lesgever!

  def index
    @lesgevers = Lesgever.order("name").all
    authorize! :index, Lesgever

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @lesgevers }
    end
  end
  def show
    @lesgever = Lesgever.find(params[:id])
    authorize! :show, @lesgever
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @lesgever }
    end
  end

  
  def new
    @lesgever = Lesgever.new
    authorize! :new, @lesgever
    @current_method = "new"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @lesgever }
    end
  end

  
  def edit
    @lesgever = Lesgever.find(params[:id])
    authorize! :edit, @lesgever
  end

  
  def create
    @lesgever = Lesgever.new(params[:lesgever])
    authorize! :create, @lesgever
    respond_to do |format|
      if @lesgever.save
        format.html { redirect_to(@lesgever, :notice => 'Lesgever werd succesvol aangemaakt.') }
        format.xml  { render :xml => @lesgever, :status => :created, :location => @lesgever }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @lesgever.errors, :status => :unprocessable_entity }
      end
    end
  end

  
  def update
    
    @lesgever = Lesgever.find(params[:id])
    authorize! :update, @lesgever
    respond_to do |format|
      if @lesgever.update_attributes(params[:lesgever])
        format.html { redirect_to(root_path, :notice => 'Lesgever werd succesvol gewijzigd.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @lesgever.errors, :status => :unprocessable_entity }
      end
    end
  end

  
  def destroy
    @lesgever = Lesgever.find(params[:id])
    authorize! :destroy, @lesgever
    @lesgever.destroy

    respond_to do |format|
      format.html { redirect_to(lesgevers_url) }
      format.xml  { head :ok }
    end
 
end
end
