class NiveausController < ApplicationController
  before_filter :authenticate_lesgever!
  # GET /niveaus
  # GET /niveaus.json
  def index
    @niveaus = Niveau.order('position')
    authorize! :index, Niveau
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @niveaus }
      format.pdf do 
        pdf = NiveauoverzichtPdf.new()
        pdf.number_pages "<page>/<total>", :size => 9, :at => [500, 0]
        send_data pdf.render, filename: "niveauoverzicht.pdf",
                              type: "application/pdf",
                              disposition: "inline"
      end
      format.xls do
        send_data( Niveau.to_xls, :filename => "niveaus_(#{Time.now.strftime("%d-%m-%y")}).xls" )
      end
    end
  end

  # GET /niveaus/1
  # GET /niveaus/1.json
  def show
    # als er geen nietdilbeeks-param gegeven is, is nietdilbeeks sowieso false 
    @niveau = Niveau.find(params[:id])
    nietdilbeeks = params[:nietdilbeeks] == "true"
    @proefs = @niveau.proefs.where("nietdilbeeks = ?", nietdilbeeks) 
    authorize! :show, @niveau
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @niveau }
      format.pdf do 
          pdf = BlancoEvaluatielijstPdf.new(@niveau)
          pdf.number_pages "(afgeprint op #{Time.now.strftime("%d/%m/%Y")})    <page>/<total>", :size => 9, :at => [620, 0]
          send_data pdf.render, filename: "#{@niveau.name}_blanco_rijen.pdf",
                                  type: "application/pdf",
                                  disposition: "inline"
      end
    end
  end

  # GET /niveaus/new
  # GET /niveaus/new.json
  def new
    @niveau = Niveau.new
    authorize! :new, @niveau
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @niveau }
    end
  end

  # GET /niveaus/1/edit
  def edit
    @niveau = Niveau.find(params[:id])
    authorize! :edit, @niveau
  end

  # POST /niveaus
  # POST /niveaus.json
  def create
    @niveau = Niveau.new(params[:niveau])
    authorize! :create, @niveau
    respond_to do |format|
      if @niveau.save
        format.html { redirect_to @niveau, notice: 'Niveau werd succesvol aangemaakt.' }
        format.json { render json: @niveau, status: :created, location: @niveau }
      else
        format.html { render action: "new" }
        format.json { render json: @niveau.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /niveaus/1
  # PUT /niveaus/1.json
  def update
    @niveau = Niveau.find(params[:id])
    authorize! :update, @niveau
    respond_to do |format|
      if @niveau.update_attributes(params[:niveau])
        format.html { redirect_to @niveau, notice: 'Niveau werd succesvol gewijzigd.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @niveau.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /niveaus/1
  # DELETE /niveaus/1.json
  def destroy
    @niveau = Niveau.find(params[:id])
    authorize! :destroy, @niveau
    @niveau.destroy

    respond_to do |format|
      format.html { redirect_to niveaus_url }
      format.json { head :no_content }
    end
  end
  def sorteren
    #railscast 147 revised  https://github.com/ryanb/railscasts-episodes/tree/master/episode-147/revised/faqapp-after
    # http://www.foliotek.com/devblog/make-table-rows-sortable-using-jquery-ui-sortable/
    #acts_as_list is afhankelijk van een 'position'-kolom in de db en creëert automatisch opeenvolgende posities wanneer nieuwe records worden aangemaakt, acts_as_list voor proefs heeft als scope niveau. 
    if params[:niveau]
      params[:niveau].each_with_index do |id, index|
        Niveau.update_all({position: index+1}, {id: id})
      end
    else
      params[:proef].each_with_index do |id, index|
        Proef.update_all({position: index+1}, {id: id})
      end
    end
    render nothing: true
  end
end
