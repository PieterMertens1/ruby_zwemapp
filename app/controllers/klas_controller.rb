class KlasController < ApplicationController
  before_filter :authenticate_lesgever!
  # GET /klas/1
  # GET /klas/1.json
  def show
    @kla = Kla.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.pdf do 
        if params[:type] == "klaslijst"
          pdf = KlaslijstPdf.new(@kla)
        else
          pdf = RapportenPdf2.new(@kla)
        end
        if params[:naar] == "opslag"
          send_data pdf.render, filename: "#{@kla.school.name}_#{@kla.name}_(#{Time.now.strftime("%d-%m-%y")}).pdf",
                              type: "application/pdf"
        else
          send_data pdf.render, filename: "",
                              type: "application/pdf",
                              disposition: "inline"
        end
      end
      format.json { render json: @kla }
    end
  end

  # GET /klas/new
  # GET /klas/new.json
  def new
    @kla = Kla.new
    @schools = School.all
    @dags = Dag.all
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @kla }
    end
  end

  # GET /klas/1/edit
  def edit
    @kla = Kla.find(params[:id])
    @schools = School.all
    @dags = Dag.all
  end

  # POST /klas
  # POST /klas.json
  def create
    @kla = Kla.new(params[:kla])
    @schools = School.all
    @dags = Dag.all
    respond_to do |format|
      if @kla.save
        format.html { redirect_to @kla, notice: 'Klas werd succesvol gemaakt.' }
        format.json { render json: @kla, status: :created, location: @kla }
      else
        format.html { render action: "new" }
        format.json { render json: @kla.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /klas/1
  # PUT /klas/1.json
  def update
    @kla = Kla.find(params[:id])
    @schools = School.all
    @dags = Dag.all
    if @kla.lesuur.id != params[:kla][:lesuur_id].to_i
      @kla.zwemmers.each do |z|
        doelgroeps = Groep.where("niveau_id = ? AND lesuur_id= ?", z.groep.niveau.id, params[:kla][:lesuur_id])
        if not doelgroeps.size==0
          dlgroep = doelgroeps.first
        else
          dlgroep = Groep.create(niveau_id: z.groep.niveau.id, lesuur_id: params[:kla][:lesuur_id])
        end
        z.update_attributes(groep_id: dlgroep.id)
      end
    end
    respond_to do |format|
      if @kla.update_attributes(params[:kla])
        format.html { redirect_to @kla, notice: 'Klas werd succesvol gewijzigd.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @kla.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /klas/1
  # DELETE /klas/1.json
  def destroy
    @kla = Kla.find(params[:id])
    @kla.destroy

    respond_to do |format|
      format.html { redirect_to school_path(@kla.school) }
      format.json { head :no_content }
    end
  end
end
