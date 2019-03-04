class ZwemmersController < ApplicationController
  before_filter :authenticate_lesgever!
  # GET /zwemmers
  # GET /zwemmers.json
  def index
    if params[:import]
      @zwemmers = Zwemmer.where("importvlag = ?", false).sort_by{ |zw| [zw.kla.school.name, zw.kla.name, zw.name]}
    else
      @zwemmers = Zwemmer.search(params[:search])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.pdf do 
        if params[:import] == true
          pdf = ImportlijstPdf.new(@zwemmers)
          send_data pdf.render, filename: "",
                                type: "application/pdf",
                                disposition: "inline"
        else
          pdf = ZwemmersExtraLijstPdf.new()
          send_data pdf.render, filename: "",
                                type: "application/pdf",
                                disposition: "inline"
        end
      end
      format.json { render json: @zwemmers }
    end
  end

  # GET /zwemmers/1
  # GET /zwemmers/1.json
  def show
    # http://stackoverflow.com/questions/2627750/background-colour-for-h3-extendind-more-than-the-content
    @zwemmer = Zwemmer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @zwemmer }
    end
  end

  # GET /zwemmers/new
  # GET /zwemmers/new.json
  def new
    @zwemmer = Zwemmer.new
    @klas = Kla.order("school_id, name").all
    @niveaus = Niveau.all
    flash[:notice] = "Gelieve de naam (+ eventueel alternatieve schrijfwijzen) op te zoeken alvorens een nieuwe zwemmer toe te voegen"
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @zwemmer }
    end
  end

  # GET /zwemmers/1/edit
  def edit
    @zwemmer = Zwemmer.find(params[:id])
    @klas = Kla.order("school_id, name").all
  end

  # POST /zwemmers
  # POST /zwemmers.json
  def create
    #zwemmers.js.coffee voor documentatie
    @zwemmer = Zwemmer.new(params[:zwemmer])

    respond_to do |format|
      if @zwemmer.save
        format.html { redirect_to @zwemmer.groep, notice: 'Zwemmer werd succesvol aangemaakt.' }
        format.json { render json: @zwemmer, status: :created, location: @zwemmer }
      else
        format.html { render action: "new" }
        format.json { render json: @zwemmer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /zwemmers/1
  # PUT /zwemmers/1.json
  def update
    @zwemmer = Zwemmer.find(params[:id])
    if params[:zwemmer][:groep_id] && (@zwemmer.groep.id != params[:zwemmer][:groep_id]) 
      if @zwemmer.groep.niveau.name != Groep.find(params[:zwemmer][:groep_id]).niveau.name
        Overgang.create(zwemmer_id: @zwemmer.id, van: @zwemmer.groep.niveau.name, naar: Groep.find(params[:zwemmer][:groep_id]).niveau.name, kleurcode_van: @zwemmer.groep.niveau.kleurcode, kleurcode_naar: Groep.find(params[:zwemmer][:groep_id]).niveau.kleurcode, lesgever: @zwemmer.groep.lesgever.name)
      end
    end
=begin if @zwemmer.kla.id != params[:zwemmer][:kla_id]
      klas = Kla.find(params[:zwemmer][:kla_id])
      doelgroeps = Groep.where("niveau_id = ? AND lesuur_id= ?", @zwemmer.groep.niveau.id, klas.lesuur.id)
      if not doelgroeps.size==0
        dlgroep = doelgroeps.first
      else
        dlgroep = Groep.create(niveau_id: @zwemmer.groep.niveau.id, lesuur_id: klas.lesuur.id)
      end
      @zwemmer.update_attributes(groep_id: dlgroep.id)
=end
    respond_to do |format|
      if @zwemmer.update_attributes(params[:zwemmer])
        if params[:zwemmer][:rapports_attributes]
          format.html { redirect_to @zwemmer, notice: 'Rapport succesvol bewaard.' }
        else
          format.html { redirect_to @zwemmer, notice: 'Zwemmer werd succesvol gewijzigd.' }
          format.json { head :no_content }
        end
      else
        format.html { render action: "edit" }
        format.json { render json: @zwemmer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /zwemmers/1
  # DELETE /zwemmers/1.json
  def destroy
    @zwemmer = Zwemmer.find(params[:id])
    @zwemmer.destroy

    respond_to do |format|
      format.html { redirect_to groep_path(@zwemmer.groep), notice: 'Zwemmer werd succesvol verwijderd.' }
      format.json { head :no_content }
    end
  end

  def massdelete
    # http://stackoverflow.com/questions/12081156/rails-using-link-to-to-make-a-link-without-href
    if params[:zwemmer_ids]
      Zwemmer.destroy(params[:zwemmer_ids])
      redirect_to zwemmers_path(import: true), notice: "#{"Zwemmer".pluralize(params[:zwemmer_ids].size)} #{"werd".pluralize(params[:zwemmer_ids].size)} succesvol verwijderd"
    else
      redirect_to zwemmers_path(import: true), notice: "Geen zwemmers aangevinkt."
    end
  end
end
