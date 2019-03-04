class GroepsController < ApplicationController
#http://stackoverflow.com/questions/4853373/rails-fields-for-with-index
#http://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-fields_for
#
  require_dependency 'foo.rb'
  include Foo
  before_filter :authenticate_lesgever!
  # GET /groeps
  # GET /groeps.json
  def index
    groep_zonder_lesgever = Groep.pluck(:lesgever_id).include? nil
    zwemmers_met_onvolledige_naam = Zwemmer.where("LTRIM(RTRIM(name)) not like ?", "% %")
    zwemmers_met_onvolledige_naam_string = zwemmers_met_onvolledige_naam.collect{|z| "<a href='#{zwemmer_path(z)}'>#{z.name} (#{current_lesgever.name==z.groep.lesgever.name ? "<strong>" : "" if z.groep.lesgever}#{z.groep.lesgever.name if z.groep.lesgever}#{current_lesgever.name==z.groep.lesgever.name ? "</strong>" : "" if z.groep.lesgever})</a>"}.join(", ")
    zwemmer_met_verkeerde_badmuts = Zwemmer.where("length(badmuts) > 0").select{|z| (z.groep.niveau.name == z.badmuts) || ((z.groep.niveau.position - Niveau.where(name:z.badmuts).first.position)> 1)}
    zwemmer_met_verkeerde_badmuts_string = zwemmer_met_verkeerde_badmuts.collect{|z| "<a href='#{zwemmer_path(z)}'>#{z.name} (#{current_lesgever.name==z.groep.lesgever.name ? "<strong>" : "" if z.groep.lesgever}#{z.groep.lesgever.name if z.groep.lesgever}#{current_lesgever.name==z.groep.lesgever.name ? "</strong>" : "" if z.groep.lesgever})</a>"}.join(", ")
    alert_array = []
    flash.now[:alert] = alert_array.push("Er is een <a href='/groeps/#{Groep.where(lesgever_id: nil).first.id}'>groep</a> zonder lesgever.".html_safe) if groep_zonder_lesgever
    flash.now[:alert] = alert_array.push("Er #{zwemmers_met_onvolledige_naam.count > 1 ? "zijn zwemmers" : "is een zwemmer"} met een onvolledige naam: #{zwemmers_met_onvolledige_naam_string}.".html_safe) if !zwemmers_met_onvolledige_naam.empty?
    flash.now[:alert] = alert_array.push("Er #{zwemmer_met_verkeerde_badmuts.count > 1 ? "zijn zwemmers" : "is een zwemmer"} met een verkeerde badmuts: #{zwemmer_met_verkeerde_badmuts_string}.".html_safe) if !zwemmer_met_verkeerde_badmuts.empty?
    @dags = params[:dag] ? [Dag.includes(:lesuurs).find(params[:dag])] : Dag.includes(:lesuurs).all
    @niveaus = Niveau.all
    @nietdilbeeks = params[:nietdilbeeks] || false
    totperlesuur = Hash.new
    freqs = Hash.new
    max = Hash.new
    Niveau.all.each do |n|
      max[n.name] = 0
    end
    @dags.each do |d|
      d.lesuurs.includes(:groeps).includes(:klas).each do |l|
        Niveau.all.each do |n|
          totperlesuur[n.name] = 0
        end
        l.groeps.includes(:niveau).includes(:lesgever).each do |g|
          totperlesuur[g.niveau.name] = totperlesuur[g.niveau.name] + 1  
        end
        freqs[l.id] = {}
        Niveau.all.each do |n|
          if totperlesuur[n.name] > max[n.name]
            max[n.name] = totperlesuur[n.name]
          end
          freqs[l.id][n.name] = {}
          freqs[l.id][n.name] = totperlesuur[n.name]
        end
        
      end
    end
    @maxs = max
    @freqs = freqs
    respond_to do |format|
      format.html # index.html.erb
      format.pdf do 
        pdf = GroepsoverzichtPdf.new()
        send_data pdf.render, filename: "groepsoverzicht.pdf",
                              type: "application/pdf",
                              disposition: "inline"
      end
      format.json { render json: @groeps }
    end
  end
  
  def tst
  #http://stackoverflow.com/questions/9182434/add-checkbox-with-simple-form-without-association-with-model
  # over testspecifieke javascript -> alert wanneer proberen verlaten buiten submit
  # http://stackoverflow.com/questions/5102602/confirm-to-leave-the-page-when-editing-a-form-with-jquery
  # er wordt een :body content_for gemaakt, dat geyield wordt onderaan layoutpagina
  # http://stackoverflow.com/questions/3437585/best-way-to-add-page-specific-javascript-in-a-rails-3-app
  # http://stackoverflow.com/questions/11075666/leave-page-alert-unless-submit-button-clicked
  # http://stackoverflow.com/questions/9778888/uncaught-typeerror-cannot-set-property-onclick-of-null
    @groep = Groep.find(params[:groep_id])
    @tweeweek = params[:tweeweek]
    nietdilbeeks = @groep.lesuur.nietdilbeeks
    @prfs = Hash.new
    @nietwit = Hash.new
    @prfs[@groep.niveau.name] = @groep.niveau.proefs.where("nietdilbeeks = ?", nietdilbeeks).order("position")
    @rapports = []
    @zwemmers = @groep.zicht_zwemmers.select{|z| z.kla.tweeweek.to_s==@tweeweek && z.netovervlag != true}.sort_by{ |zw| [-zw.kla.name.to_i, zw.kla.name, zw.kla.school.name, zw.name]}
    @zwemmers.each do |z|
      if @groep.niveau.name == "wit" && z.groepvlag.to_i > 0
        zwemmersgroep = Groep.find(z.groepvlag)
        @nietwit[z.name] = zwemmersgroep.niveau.name
        if not @prfs.has_key?(zwemmersgroep.niveau.name)
          @prfs[zwemmersgroep.niveau.name] = zwemmersgroep.niveau.proefs.where("nietdilbeeks = ?", nietdilbeeks).order("position")
        end
      end
      if not z.rapports.last or (z.rapports.order('created_at').last.created_at < Tijd.last.created_at)
        r = z.rapports.build
        if @groep.niveau.name == "wit" && z.groepvlag.to_i > 0
          Niveau.where('name = ?', zwemmersgroep.niveau.name).first.proefs.where("nietdilbeeks = ?", nietdilbeeks).size.times {r.resultaats.build}
        else
          @groep.niveau.proefs.where("nietdilbeeks = ?", nietdilbeeks).size.times {r.resultaats.build}
        end
      else
        r = z.rapports.last
      end
      @rapports << r
    end
  end
  # GET /groeps/1
  # GET /groeps/1.json
  def show
  #http://stackoverflow.com/questions/8797507/sort-a-list-with-multiple-conditions-ruby-on-rails
  # http://www.ruby-forum.com/topic/148948  voor aflopende sort
  # http://stackoverflow.com/questions/10858582/html-code-inside-buttons-with-simple-form   voor icoon op submit button
    @groep = Groep.find(params[:id])
    @tweeweek = @groep.zicht_zwemmers.any? {|z| z.kla.tweeweek}
    @any_wekelijks = @groep.zicht_zwemmers.any? {|z| !z.kla.tweeweek}
    verborgen_klassen = Kla.where(verborgen: true).pluck(:id)
    witgroep = Groep.where('lesuur_id = ? AND niveau_id = ?', @groep.lesuur.id, Niveau.where('name = ?', "wit").first.id).first
    @wits =[]
    if @groep.niveau.name != "wit" && witgroep
      #@wits = Zwemmer.where("groep_id IN (?) AND witvlag = ?", @groep.lesuur.groeps.collect{|g| g.id}, true)
      if verborgen_klassen.empty?
        @wits = Zwemmer.where('groep_id = ? AND groepvlag = ?', witgroep.id, @groep.id)
      else
        @wits = Zwemmer.where('groep_id = ? AND groepvlag = ? AND kla_id not in (?)', witgroep.id, @groep.id, verborgen_klassen)
      end
    end
    @zwemmers = @groep.zicht_zwemmers + @wits
    @equals = Groep.where("niveau_id = ? AND lesuur_id = ? AND id != ?", @groep.niveau.id, @groep.lesuur.id, @groep.id)
    @maxrang = Niveau.maximum("position")
    @minrang = Niveau.minimum("position")
    respond_to do |format|
      format.html # show.html.erb
      format.pdf do 
        if @groep.lesgever && @groep.lesgever.name.length > 0
          case params[:type]
          when "aanwezigheidslijst"
            pdf = AanwezigheidslijstPdf.new(@groep, params[:week].to_i)
          when "evaluatielijst"
            pdf = EvaluatielijstPdf.new(@groep, params[:week].to_i)
          else
            pdf = WatersafetyPdf.new(@groep)
          end
          pdf.number_pages "(afgeprint op #{Time.now.strftime("%d/%m/%Y")})    <page>/<total>", :size => 9, :at => [620, 0]
          send_data pdf.render, filename: "groep_#{@groep.niveau.name}_#{@groep.lesuur.dag.name}_#{@groep.lesuur.name}_#{@groep.lesgever.name}.pdf",
                                type: "application/pdf",
                                disposition: "inline"
        else
          redirect_to groep_path(@groep), notice: "Gelieve een lesgever aan te duiden voor deze groep."
        end
      end
      format.json { render json: @groep }
    end
  end

  # GET /groeps/new
  # GET /groeps/new.json
  def new
    @groep = Groep.new
    @lesgevers = Lesgever.order('name').all
    @dags = Dag.all
    @niveaus = Niveau.order('position').all
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @groep }
    end
  end

  # GET /groeps/1/edit
  def edit
    @groep = Groep.find(params[:id])
    @lesgevers = Lesgever.order('name').all
    @dags = Dag.all
    @lesuurs = Lesuur.all
    @niveaus = Niveau.all
  end

  # POST /groeps
  # POST /groeps.json
  def create
    @groep = Groep.new(params[:groep])
    @lesgevers = Lesgever.order('name').all
    @dags = Dag.all
    @niveaus = Niveau.order('position').all
    respond_to do |format|
      if @groep.save
        format.html { redirect_to @groep, notice: 'Groep werd succesvol aangemaakt.' }
        format.json { render json: @groep, status: :created, location: @groep }
      else
        format.html { render action: "new" }
        format.json { render json: @groep.errors, status: :unprocessable_entity }
      end
    end
  end
  def change
  #http://stackoverflow.com/questions/4964599/rails-how-do-you-submit-a-form-with-a-text-link
  #http://stackoverflow.com/questions/6150388/passing-parameters-from-submit-tag
  currentgroep = Groep.find(params[:groepid])
  if params[:zwemmer_ids]
    if params[:verander]
      # zwemmers binnen zelfde niveau, naar andere groep
      specialswimmers = params[:zwemmer_ids].select{|z| Zwemmer.find(z).groepvlag > 0}
      togroepid = params[:verander].first[0].to_i
      back = zwemmer_shift(:zelfde_kleur, currentgroep, params[:zwemmer_ids]-specialswimmers, togroepid)
      back1 = zwemmer_shift(:inwit_zelfde_kleur, currentgroep, specialswimmers, togroepid)
      redirect_to groep_path(togroepid), notice: "#{"Zwemmer".pluralize(back+specialswimmers.size)} succesvol van groep veranderd."
      GroepVeranderdMailer.groep_veranderd(currentgroep, Groep.find(togroepid), params[:zwemmer_ids]).deliver
    else
      if params[:over]  
        # zwemmers naar ander niveau
        # Parameters: {"utf8"=>"✓", "authenticity_token"=>"spCUaw25z5bqsgPqW1wk2LIEfhZ9Lr2A7EMK35iJJW0=", "groepid"=>"4", "zwemmer_ids"=>["262"], "over"=>{"-1"=>"Groep lager"}}
        # params[:over].flatten[0].to_i == -1
        specialswimmers = params[:zwemmer_ids].select{|z| Zwemmer.find(z).groepvlag > 0}
        dlgroep, back1 = zwemmer_shift(:inwitover, currentgroep, specialswimmers, 1)
        dlgroep, back = zwemmer_shift(:over, currentgroep, params[:zwemmer_ids]-specialswimmers, params[:over].flatten[0].to_i)
        if currentgroep.niveau.name == "wit"
          redirect_to groep_path(currentgroep), notice: "#{"Zwemmer".pluralize(back + specialswimmers.size)} succesvol over gestuurd."
        else
          redirect_to groep_path(dlgroep), notice: "#{"Zwemmer".pluralize(back)} succesvol over gestuurd."
        end
      else
        if params[:wit]
          # zwemmers naar wit
          witgroep = Groep.where('lesuur_id = ? AND niveau_id = ?', currentgroep.lesuur.id, Niveau.where('name = ?', "wit").first.id).first
          if not witgroep
            witgroep = Groep.create(lesuur_id: currentgroep.lesuur.id, niveau_id: Niveau.where('name = ?', "wit").first.id)
          end
          zwemmers = Zwemmer.where(:id => params[:zwemmer_ids]).update_all(:groep_id => witgroep.id, :groepvlag => currentgroep.id)
          redirect_to groep_path(currentgroep), notice: "#{"Zwemmer".pluralize(zwemmers)} succesvol naar wit gestuurd."
        else
          #zwemmers = Zwemmer.where(:id => params[:zwemmer_ids]).update_all(:groep_id => false)
          # zwemmers van wit naar eigen groep
          params[:zwemmer_ids].each do |i|
            zwemmer = Zwemmer.find(i)
            zwemmer.update_attributes(:groep_id => zwemmer.groepvlag, :groepvlag => 0)
          end
          redirect_to groep_path(currentgroep), notice: "#{"Zwemmer".pluralize(params[:zwemmer_ids].count)} succesvol terug gestuurd."
        end
      end
    end
  else
    redirect_to groep_path(currentgroep), notice: "Geen zwemmers aangevinkt."
  end
  end
  # PUT /groeps/1
  # PUT /groeps/1.json
  def update
    @groep = Groep.find(params[:id])
    @dags = Dag.all
    extra = ""
    if @groep.done_vlag != true && params[:groep][:done_vlag] == "1"
      swimmers = @groep.zwemmers.select{|z| z.overvlag && !(z.groepvlag > 0)}.collect{|zw| zw.id}
      if swimmers.size > 0
        extra, zwmrs = zwemmer_shift(:over, @groep, swimmers, 1)
      end
      specialswimmers = @groep.zwemmers.select{|z| z.overvlag && (z.groepvlag > 0)}.collect{|zw| zw.id}
      if specialswimmers.size > 0
        extra, zwmrs = zwemmer_shift(:inwitover, @groep, specialswimmers, 1)
      end
      logger.debug("#--------------------" + zwmrs.to_s + "----------------")
    end
    respond_to do |format|
      if @groep.update_attributes(params[:groep])
        if params[:groep][:zwemmers_attributes]
        format.html { redirect_to @groep, notice: "#{"Testresultaat".pluralize(@groep.zwemmers.size)} succesvol opgeslagen." }
        format.json { head :no_content }
        else
        format.html { redirect_to @groep, notice: 'Groep werd succesvol gewijzigd.' }
        format.json { head :no_content }
        end
      else
        format.html { render action: "edit" }
        format.json { render json: @groep.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /groeps/1
  # DELETE /groeps/1.json
  def destroy
    @groep = Groep.find(params[:id])
   
    respond_to do |format|
      if @groep.zwemmers.size == 0
        if @groep.destroy
          format.html { redirect_to "#{root_path}groeps?dag=#{current_day_index}", notice: 'Groep werd verwijderd.'  }
        end
      else
        format.html { redirect_to @groep, notice: 'Groep werd niet verwijderd (bevat nog zwemmers).' }
        format.json { head :no_content }
      end
    end
  end
end