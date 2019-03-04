class SchoolsController < ApplicationController
  before_filter :authenticate_lesgever!
  # GET /schools
  # GET /schools.json
  def index
    #@schools = School.order('name')
    nt_dilbkse_scholen =  []
    dilbkse_scholen = []
    School.all.each do |s|
      s.klas.any? {|k| k.nietdilbeeks} ? nt_dilbkse_scholen.push(s.id) : dilbkse_scholen.push(s.id)
    end 
    @dilbeekse_scholen = School.where(id: dilbkse_scholen).order(:name)
    @niet_dilbeekse_scholen = School.where(id: nt_dilbkse_scholen).order(:name)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @schools }
    end
  end

  # GET /schools/1
  # GET /schools/1.json
  def show
    @school = School.find(params[:id])
    @totaal = 0
    @klassen = @school.klas.sort_by(&:sort_name)
    @klassen.each {|k| @totaal += k.zwemmers.count}

    respond_to do |format|
      format.html # show.html.erb
      format.pdf do 
        pdf = SchoollijstPdf.new(@school, params[:tweeweek])
        send_data pdf.render, filename: "",
                              type: "application/pdf",
                              disposition: "inline"
      end
      format.json { render json: @school }
      format.xls do
        send_data( @school.to_xls, :filename => "#{@school.name}_niveaus_(#{Time.now.strftime("%m-%y")}).xls" )
      end
    end
  end

  # GET /schools/new
  # GET /schools/new.json
  def new
    @school = School.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @school }
    end
  end

  # GET /schools/1/edit
  def edit
    @school = School.find(params[:id])
  end

  # POST /schools
  # POST /schools.json
  def create
    @school = School.new(params[:school])

    respond_to do |format|
      if @school.save
        format.html { redirect_to @school, notice: 'School werd succesvol aangemaakt.' }
        format.json { render json: @school, status: :created, location: @school }
      else
        format.html { render action: "new" }
        format.json { render json: @school.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /schools/1
  # PUT /schools/1.json
  def update
    @school = School.find(params[:id])

    respond_to do |format|
      if @school.update_attributes(params[:school])
        format.html { redirect_to @school, notice: 'School werd succesvol gewijzigd.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @school.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /schools/1
  # DELETE /schools/1.json
  def destroy
    @school = School.find(params[:id])
    @school.destroy

    respond_to do |format|
      format.html { redirect_to schools_url }
      format.json { head :no_content }
    end
  end
end
