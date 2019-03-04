class LesuursController < ApplicationController
  before_filter :authenticate_lesgever!
  # GET /lesuurs
  # GET /lesuurs.json
  def index
    @lesuurs = Lesuur.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @lesuurs }
    end
  end

  # GET /lesuurs/1
  # GET /lesuurs/1.json
  def show
    @lesuur = Lesuur.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @lesuur }
      format.pdf do 
        if !@lesuur.groeps.any? {|g| !(g.lesgever && g.lesgever.name.length > 0)}
          case params[:type]
          when "aanwezigheidslijst"
            pdf = AanwezigheidslijstPdf.new(0, 0, @lesuur)
            pdf.number_pages "(afgeprint op #{Time.now.strftime("%d/%m/%Y")})", :size => 9, :at => [620, 0]
            send_data pdf.render, filename: "aanwezigheidslijsten_lesuur_#{@lesuur.name}.pdf",
                                    type: "application/pdf",
                                    disposition: "inline"
          when "evaluatielijst"
            pdf = EvaluatielijstPdf.new(0, 0, @lesuur)
            pdf.number_pages "(afgeprint op #{Time.now.strftime("%d/%m/%Y")})", :size => 9, :at => [620, 0]
            send_data pdf.render, filename: "evaluatielijsten_lesuur_#{@lesuur.name}.pdf",
                                    type: "application/pdf",
                                    disposition: "inline"
          end
        else
          redirect_to groeps_path(dag: @lesuur.dag.id), notice: "Gelieve een lesgever aan te duiden voor elk van deze groepen."
        end
      end
    end
  end

  # GET /lesuurs/new
  # GET /lesuurs/new.json
  def new
    @lesuur = Lesuur.new
    @dags = Dag.all
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @lesuur }
    end
  end

  # GET /lesuurs/1/edit
  def edit
    @lesuur = Lesuur.find(params[:id])
    @dags = Dag.all
  end

  # POST /lesuurs
  # POST /lesuurs.json
  def create
    @lesuur = Lesuur.new(params[:lesuur])
    @dags = Dag.all
    respond_to do |format|
      if @lesuur.save
        format.html { redirect_to dags_path, notice: 'Lesuur werd succesvol aangemaakt.' }
        format.json { render json: @lesuur, status: :created, location: @lesuur }
      else
        format.html { render action: "new" }
        format.json { render json: @lesuur.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /lesuurs/1
  # PUT /lesuurs/1.json
  def update
    @lesuur = Lesuur.find(params[:id])

    respond_to do |format|
      if @lesuur.update_attributes(params[:lesuur])
        format.html { redirect_to dags_path, notice: 'Lesuur werd succesvol gewijzigd.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @lesuur.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lesuurs/1
  # DELETE /lesuurs/1.json
  def destroy
    @lesuur = Lesuur.find(params[:id])
    @lesuur.destroy

    respond_to do |format|
      format.html { redirect_to dags_path, notice: 'Lesuur werd succesvol verwijderd.' }
      format.json { head :no_content }
    end
  end
end
