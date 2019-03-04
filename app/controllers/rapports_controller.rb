class RapportsController < ApplicationController

  # GET /rapports/new
  # GET /rapports/new.json
  def new
    @rapport = Rapport.new
    @zwemmer = Zwemmer.find(params[:zwemmerid])
    @niveau = Niveau.find(params[:niveau_id])
    nietdilbeeks =@zwemmer.groep.lesuur.nietdilbeeks
    @proefs = @niveau.proefs.where("nietdilbeeks = ?", nietdilbeeks).order("position")
    @rapport = @zwemmer.rapports.build
    @proefs.size.times {@rapport.resultaats.build}
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @rapport }
    end
  end

  # GET /rapports/1/edit
  def edit
    @rapport = Rapport.find(params[:id])
    @zwemmer = @rapport.zwemmer
    nietdilbeeks =@zwemmer.groep.lesuur.nietdilbeeks
    @proefs = Niveau.where('name = ?', @rapport.niveau).first.proefs.where("nietdilbeeks = ?", nietdilbeeks).order("position")
  end

  # DELETE /rapports/1
  # DELETE /rapports/1.json
  def destroy
    @rapport = Rapport.find(params[:id])
    @rapport.destroy

    respond_to do |format|
      format.html { redirect_to zwemmer_path(@rapport.zwemmer) }
      format.json { head :no_content }
    end
  end

  def show
    @rapport = Rapport.find(params[:id])
      pdf = SingleRapportPdf.new(@rapport)
        send_data pdf.render, filename: "#{@rapport.niveau}_#{@rapport.zwemmer.name}.pdf",
                                  type: "application/pdf",
                                  disposition: "inline"
  end
end
