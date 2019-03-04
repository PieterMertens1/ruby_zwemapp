# encoding: UTF-8
class FrontsController < ApplicationController
  require_dependency 'foo.rb'
  include Foo
  before_filter :authenticate_lesgever!
  
  def paneel
  #@n_dilbeeks =  Zwemmer.where(:kla_id => (Kla.where('nietdilbeeks = ?', false).pluck(:id))).count
  #@n_niet_dilbeeks = Zwemmer.where(:kla_id => (Kla.where('nietdilbeeks = ?', true).pluck(:id))).count
  #@n_dilbeeks_wek = Zwemmer.where(:kla_id => (Kla.where('nietdilbeeks = ? and tweeweek = ?', false, false).pluck(:id))).count
  #@n_dilbeeks_2wek = Zwemmer.where(:kla_id => (Kla.where('nietdilbeeks = ? and tweeweek = ?', false, true).pluck(:id))).count
  #@nk_dilbeeks = Kla.where("nietdilbeeks = ?", false).count
  #@nk_niet_dilbeeks = Kla.where("nietdilbeeks = ?", true).count
  #gem_groeps_grootte_d = []
  #gem_groeps_grootte_nd = []
  #Lesuur.all.each do |l|
  #  case l.nietdilbeeks
  #    when false
  #      gem_groeps_grootte_d << l.groeps.collect{|g| g.omvang}.flatten
  #    when true
  #      gem_groeps_grootte_nd << l.groeps.collect{|g| g.omvang}.flatten
  #  end
  #end
  #@gem_d = gem_groeps_grootte_d.flatten.sum / gem_groeps_grootte_d.flatten.size
  #@gem_nd = gem_groeps_grootte_nd.flatten.sum / (gem_groeps_grootte_nd.flatten.size.nonzero? || 1)
  @alle_zwemmers = Zwemmer.count
  @n_wekelijks = Zwemmer.where(:kla_id => (Kla.where('tweeweek = ?', false).pluck(:id))).count
  @n_wek_relative = ((@n_wekelijks.to_f/@alle_zwemmers.to_f)*100.to_f).round(2)
  @n_2wekelijks = Zwemmer.where(:kla_id => (Kla.where('tweeweek = ?', true).pluck(:id))).count
  @n_2wek_relative = ((@n_2wekelijks.to_f/@alle_zwemmers.to_f)*100.to_f).round(2)
  @kleuters = Zwemmer.where(:kla_id => (Kla.where("name like ?", "%k%").pluck(:id))).count
  @n_kl_relative = ((@kleuters.to_f/@alle_zwemmers.to_f)*100.to_f).round(2)
  @lagereschool_kinderen = Zwemmer.count - @kleuters
  @n_lager_relative = ((@lagereschool_kinderen.to_f/@alle_zwemmers.to_f)*100.to_f).round(2)
  if Tijd.last 
    @laatste_reset = Tijd.last.created_at
  end
  #@oranje_zwemmer =  Zwemmer.find((1..1000).detect {|i| Zwemmer.find(i).groep.niveau.rang == 4})
end

def tijd_toevoegen
  #toggle rapportperiode boolean met xor operator "^"  https://janvdl.com/showthread.php?977-Toggle-true-false-state
  app = Applicatie.first
  if app.rapportperiode
    Zwemmer.update_all(netovervlag: false)
    Groep.update_all(done_vlag: false)
  else
    t = Tijd.create(aantal: 5)
  end
  app.update_attributes(rapportperiode: app.rapportperiode ^ true)
  redirect_to fronts_paneel_path
end

def verander_importeer
  Zwemmer.update_all(importvlag: false)
  redirect_to fronts_paneel_path
end

=begin def statistieken
  #http://objectmix.com/ruby/185450-merge-array-hashes.html
  @h = Array.new
  s = School.find(1)
  @klassen = [1,2,3,4,5,6]
  @freqs = Hash.new
  School.all.each do |s|
    @freqs[s.name] = {}
    @klassen.each do |kl| 
      @freqs[s.name][kl] = {}
      Niveau.all.each do |n| 
        @freqs[s.name][kl][n.name] = 0
      end
    end
    s.klas.each do |k|
      k.zwemmers.each do |z|
        @freqs[s.name][z.kla.name[0].to_i][z.groep.niveau.name]  += 1
      end
    end
  end
  hash= Hash.new 
  School.all.each_with_index do |s, fidx|
    @freqs[s.name].values.each { |h| hash.merge!(h){ |key, v1, v2| v1 + v2}} 
    @h[fidx] = LazyHighCharts::HighChart.new('chart') do |f|
      f.options[:title][:text] = s.name
      f.options[:colors] = Niveau.all.collect {|n| n.kleurcode}
      f.options[:chart][:defaultSeriesType] = "column"
      f.options[:chart][:inverted] = false
        f.series(:name=>s.name, :data=>hash.values, :colorByPoint => true, :showInLegend => false)
        f.options[:xAxis][:categories] = hash.keys
      end
    hash.clear
  end
  @h[10] = LazyHighCharts::HighChart.new('chart') do |f|
      f.options[:title][:text] = "RC 6es"
      f.options[:colors] = Niveau.all.collect {|n| n.kleurcode}
      f.options[:chart][:defaultSeriesType] = "column"
      f.options[:chart][:inverted] = false
        f.series(:name=>"RC 6es", :data=>@freqs["RC"][6].values, :colorByPoint => true, :showInLegend => false)
        f.options[:xAxis][:categories] = @freqs["RC"][6].keys
        
    end
=end
def singlestat
  @picture = Picture.new
  @scholen = School.order('name').collect{ |s| [s.name, s.id]}
  @pictures = Picture.order('created_at asc')
  school = School.order('name').first
  freqs = Hash.new
  Niveau.all.each do |n| 
    freqs[n.name] = 0
  end
  klsn = school.klas.select{|k| k.name[0] == '1'}
  klsn.each do |klas|
    klas.zwemmers.each do |z|
      freqs[z.groep.niveau.name] += 1
    end
  end
  @h = LazyHighCharts::HighChart.new('chart') do |f|
      f.options[:title][:text] = "#{school.name} 1e leerjaar"
      f.options[:colors] = Niveau.all.collect {|n| n.kleurcode}
      f.options[:chart][:defaultSeriesType] = "column"
      f.options[:chart][:inverted] = false
      # http://jsfiddle.net/gh/get/jquery/1.9.1/highslide-software/highcharts.com/tree/master/samples/highcharts/demo/pie-donut/
      f.series(:name=>"zwemmers", :data=>freqs.values, :colorByPoint => true, :showInLegend => false)
      f.series(:name=>"zwemmers2", :data=>[0,0,0,0,0,0], :colorByPoint => true, :showInLegend => false, :visible => false)
      f.options[:xAxis][:categories] = Niveau.all.collect{|n| n.name}#["wit", "groen", "geel", "oranje", "rood", "blauw"]
  end
end
def getstat
  # fiddle: http://jsfiddle.net/ABydq/
  # http://stackoverflow.com/questions/19163979/pie-hidden-serie-datalabels-not-hidden?noredirect=1#comment28350435_19163979
  zwmrs = "ddd"
  title = nil
  freqs = []
  active_reeks = nil
  niveaus_namen = []
  niveaus_namen[0] = []
  niveaus_namen[1] = []
  colors = []
  colors[0] = []
  colors[1] = []
  messages = []
  error = false
  freqs[0] = Hash.new
  freqs[1] = Hash.new
  #freqs.each do |f|
  #  Niveau.all.each do |n| 
  #    f[n.name] = 0
  #  end
  #end
  [params[:school1], params[:school2]].each_with_index do |param_school, pi|
    params_picture = params["picture#{pi+1}".to_sym]
    if params_picture.to_i > 0
      niveaus_namen[pi] = Picture.find(params_picture).niveaus.collect{|k,v| v[0]}  if param_school != ""
      niveaus_namen[pi].each do |n| 
        freqs[pi][n] = 0
      end
    else
      niveaus_namen[pi] = Niveau.all.collect{|n| n.name} if param_school != ""
      niveaus_namen[pi].each do |n| 
        freqs[pi][n] = 0
      end
    end
  end
  if niveaus_namen[0] != [] && niveaus_namen[1] != [] && niveaus_namen[0] != niveaus_namen[1]
    error = "niveaus"
    title = "Statistieken met verschillende niveaureeksen kunnen niet vergeleken worden."
    active_reeks = 0
    freqs[0] = []
    freqs[1] = []
    niveaus_namen[0].each do |n| 
        freqs[0].push(0)
        freqs[1].push(0)
    end
  else
    if niveaus_namen[0] != [] && niveaus_namen[1].size == 0
      active_reeks = 0
      niveaus_namen[0].each do |n| 
        freqs[1][n] = 0
      end
    else
      if niveaus_namen[1].size > 0 && niveaus_namen[0].size == 0
        active_reeks = 1
        niveaus_namen[1].each do |n| 
          freqs[0][n] = 0
        end
      else
        active_reeks = 0
      end
    end
    [params[:school1], params[:school2]].each_with_index do |param_school, pi|
      param_jaar = params["jaar#{pi+1}".to_sym]
      params_picture = params["picture#{pi+1}".to_sym]
      jaar_message = (param_jaar.include?"k") ? "#{param_jaar[0]}e kleuterklas" : "#{param_jaar}e leerjaar"
      if params_picture.to_i > 0
        messages[pi], freqs[pi] = get_picture_freqs(params_picture, param_school, param_jaar, freqs[pi])
        colors[pi] = Picture.find(params_picture).niveaus.collect{|k,v| v[1]}  if param_school != ""
      else
        jaar = (param_jaar == '1 tot 6' ? '%' : (param_jaar + '[abcdefgh]?'))
        colors[pi] = Niveau.all.collect {|n| n.kleurcode}  if param_school != ""
        case param_school
        when ""
          messages[pi] = ""
          klsn = []
        when "lv"
          messages[pi] = "Lagere scholen #{jaar_message}"
          klsn = Kla.where("name not like ?", "%k%").where("name similar to ?", "#{jaar}")
        when "wd"
          messages[pi] = "Wekelijks dilbeeks #{jaar_message}"
          klsn = Kla.where(tweeweek: false, nietdilbeeks: false).where("name similar to ?", "#{jaar}")
        when "2d"
          messages[pi] = "2-wekelijks dilbeeks #{jaar_message}"
          klsn = Kla.where(tweeweek: true, nietdilbeeks: false).where("name similar to ?", "#{jaar}")
        else
          school = School.find(param_school)
          messages[pi] = "#{school.name} #{jaar_message}"
          if param_jaar == "1 tot 6"
            klsn = school.klas.all
          else
            klsn = school.klas.select{|k|  /^#{param_jaar}[abcdefgh]?$/.match(k.name)}
          end
        end
        klsn.each do |klas|
          klas.zwemmers.each do |z|
            freqs[pi][z.groep.niveau.name] += 1
          end
        end
        freqs[pi] = freqs[pi].values
      end
    end
  end
  h = LazyHighCharts::HighChart.new('chart') do |f|
      f.options[:title][:text] = "piep"
      f.options[:colors] = Niveau.all.collect {|n| n.kleurcode}
      f.options[:chart][:defaultSeriesType] = "column"
      f.options[:chart][:inverted] = false
      f.series(:name=>"zwemmers", :data=> freqs[0], :colorByPoint => true, :showInLegend => false)
      f.options[:xAxis][:categories] = ["wit", "groen", "geel", "oranje", "rood", "blauw"]
  end
  separator = (messages[0] == '' || messages[1] == '') ? '' : ' - '
  
  render :json => {"freqs" => freqs[0],"freqs2" => freqs[1], "title" => title || (messages[0] + separator + messages[1]), "niveaus" => niveaus_namen[active_reeks], "colors" => colors[active_reeks], "error" => error}
end

def picture_calc
  # get pictures
  if params[:format2] != 'pdf'
    p1 = Picture.find(params[:picture1])
    p2 = Picture.find(params[:picture2])
    # set 0 and empty values for all years
    year_totals = {}
    colors = Hash[ p1.niveaus.map{|k,v| [v[0], v[1]]}]
    niveaus = p1.niveaus
    (1..6).to_a.each {|i| year_totals[i] = 0}
    years = {}
    (1..6).to_a.each do |i| 
      years[i] = {}
      p1.niveaus.each do |niv_k, niv_v|
        years[i][niv_k] = {}
      end
    end
    med = years.clone
    #start calc
    p1.details.each do |k, v|
      z_id = k
      z_last = p2.details[z_id]
      if z_last && v[2] == "wd"
        jaar = v[1][0].to_i
        z_first_niveau = v[0].to_i
        z_last_niveau = z_last[0].to_i
        z_diff = z_last_niveau - z_first_niveau
        if z_diff >= 0
          year_totals[jaar] += 1
          (0..z_diff).to_a.each do |d|
            years[jaar][z_first_niveau][d] = 0 if not years[jaar][z_first_niveau][d]
          end
          #years[jaar][z_first_niveau][z_diff] = 0 if not years[jaar][z_first_niveau][z_diff]
          years[jaar][z_first_niveau][z_diff] += 1
        end
      end
    end
    complete_total = year_totals.values.inject{|sum, x| sum + x}
    to_send = []
    years.each_with_index do |(y, nivs), years_index|
      year_put = false
      nivs.each_with_index do |(n, diffs), nivs_index|
        sum = 0
        total1 = diffs.values.inject{|sum, x| sum + x}
        diffs.each_with_index do |(d, aantal), diffs_index|
          to_send.push([(year_put ? "" : y), (diffs_index > 0  ? "" : niveaus[n][0]), d, aantal, ((aantal.to_f/total1.to_f)*100).round(2), ((aantal.to_f/year_totals[y].to_f)*100).round(2), ((aantal.to_f/complete_total.to_f)*100).round(2)])
          year_put = true
        end
      end
    end
    render :json => {"comp" => {"rows" => to_send.to_json}, "colors" => colors.to_json}
  else
    pdf = PicturecompPdf.new(params[:picture1], params[:picture2])
    send_data pdf.render, filename: "stats_vergelijk_foto.pdf",
                              type: "application/pdf",
                              disposition: "inline"
  end
end

def import_form
  # maak hash van niveau-naam en -karakterduo's, volgens: http://stackoverflow.com/questions/5519380/build-hash-from-collection-of-activerecord-models
  @codes = Hash[ Niveau.select("name, karakter").map{|n| [n.karakter, n.name]}]
end

def klas_import
  codes = Hash[ Niveau.select("name, karakter").map{|n| [n.karakter, n.name]}]
  @verwerkte_zwemmers = Hash.new
  nieuw_gecheckt = (params[:nieuw] == "1") ? true : false
  @klas = Kla.find(params[:klas].to_i)
  niveau_id = params[:niveau].to_i
  zwemmers = params[:zwemmers].split(/\r\n/).collect {|x| x.strip}
  huidige_basis = Groep.where("niveau_id= ? AND lesuur_id = ?", niveau_id, @klas.lesuur.id).first
  if not huidige_basis
    huidige_basis = Groep.create(niveau_id: niveau_id, lesuur_id: @klas.lesuur.id)
  end
  logger.debug zwemmers
  zwemmers.each do |z|
    if z != ""
      z = z.upcase
      z.gsub!(/[ëéêâàäçïíüöôèû]/,"ë" => "Ë", "é" => "É", "ê" => "Ê", "â" => "Â","à" => "À", "ä" => "Ä","ç" => "Ç", "ï" => "Ï", "í" => "Í", "ü" => "Ü", "ö" => "Ö", "ô" => "Ô","è" => "È", "û" => "Û")
      z.gsub!(/\t/, " ")
      z.gsub!(/  /, " ")
      # http://stackoverflow.com/questions/5482862/check-if-an-element-of-an-array-partly-exists-in-a-given-string
      # http://ruby-doc.org/core-1.9.3/Enumerable.html#method-i-find
       @result = codes.keys.detect{|c| z.include? c }
      if  @result
        z = z.gsub(/[#{codes.keys.join}]/, "")
        z.strip!
        groep = Groep.where("niveau_id= ? AND lesuur_id = ?", Niveau.where(name:codes[@result]).first.id, @klas.lesuur.id).first
        if not groep
          groep = Groep.create(lesuur_id: @klas.lesuur.id, niveau_id: Niveau.where(name:codes[@result]).first.id)
        end
        extra = (nieuw_gecheckt) ? "nieuw" : ""
        zwemmer = Zwemmer.create(name: z, kla_id: params[:klas].to_i, groep_id: groep.id, importvlag: true, extra: extra)
        @verwerkte_zwemmers[zwemmer] = ["plus", groep.niveau.kleurcode]
      else
        if zwemmer = Zwemmer.where(name: z).first
          groep = Groep.where("niveau_id= ? AND lesuur_id = ?", zwemmer.groep.niveau.id, @klas.lesuur.id).first
          if groep.nil?
            groep = Groep.create(niveau_id: zwemmer.groep.niveau.id, lesuur_id: @klas.lesuur.id)
          end
          zwemmer.update_attributes(:kla_id => params[:klas].to_i, groep_id: groep.id, importvlag: true)
          @verwerkte_zwemmers[zwemmer] = ["ok", groep.niveau.kleurcode]
        else
          extra = (nieuw_gecheckt) ? "nieuw" : ""
          zwemmer = Zwemmer.create(name: z, kla_id: params[:klas].to_i, groep_id: huidige_basis.id, importvlag: true, extra: extra)
          @verwerkte_zwemmers[zwemmer] = ["plus", zwemmer.groep.niveau.kleurcode]
        end
      end
    end
  end
end


def autoinfo
  # http://stackoverflow.com/questions/2234008/how-can-i-render-a-json-response-from-a-hash-while-maintaining-order-in-ruby-on
  # http://stackoverflow.com/questions/8462540/how-to-send-get-request-to-rails-from-javascript
  # http://stackoverflow.com/questions/11338592/jquery-textarea-change-event
  # http://stackoverflow.com/questions/7713873/javascript-html-to-alternate-row-colors-for-input-type-textarea
  #zwemmers = {"silke" => 1, "sanne" => 2}
  # ontvangt textarea-inhoud via jQuery-get(ajax), split het in lijnen, vervangt speciale karakters, zoek codes, stuur array van arrays terug, bv: [["diederik roelandt", "#62c462", "<i class="icon-plus"></i>"], [],...]
  codes = Hash[ Niveau.select("karakter, kleurcode").map{|n| [n.karakter, n.kleurcode]}]
  prm = params[:zwemmers]
  niveau_id = params[:niveau].to_i
  zwmrs = Array.new
  zwemmers = params[:zwemmers].split(/\n/).collect {|x| x.strip}
  zwemmers.each do |z|
    if z != ""
      z = z.upcase
      z.gsub!(/[ëéêâàäçïíüöôèû]/,"ë" => "Ë", "é" => "É", "ê" => "Ê", "â" => "Â","à" => "À", "ä" => "Ä","ç" => "Ç", "ï" => "Ï", "í" => "Í", "ü" => "Ü", "ö" => "Ö", "ô" => "Ô","è" => "È", "û" => "Û")
      z.gsub!(/\t/, " ")
      z.gsub!(/  /, " ")
      result = codes.keys.detect{|c| z.include? c }
      klas = ""
      suggestie_naam = ""
      suggestie_id = 0
      suggestie_code = ""
      if result
        z = z.gsub(/[#{codes.keys.join}]/, "")
        z.strip!
        code = codes[result]
        nofo = "<i class=\"icon-plus\"></i>"
      else
        if zwemmer = Zwemmer.where(name: z).first
          code = zwemmer.groep.niveau.kleurcode
          nofo = "<i class=\"icon-ok\"></i>"
          klas = " (#{zwemmer.kla.school.name[0..1]+zwemmer.kla.name})"
        else
          # Zwemmer.all.collect{|z| [z.id, z.name.similar("SAMOILà MIRELA")]}.sort_by{|v| v[1]}.last
          code = Niveau.find(niveau_id).kleurcode
          nofo = "<i class=\"icon-plus\"></i>"
          suggestie_id, suggestie_naam, suggestie_code = suggestie(z)
        end
      end
      zwmrs.push([z+klas, code, nofo, suggestie_naam, suggestie_id, suggestie_code])
    end
  end
  render :json => {"zwemmers" => zwmrs.to_json}
end

def import_wijzig
  zwemmer = Zwemmer.find(params[:zwemmer].to_i)
  naam = params[:naam]
  zwemmer.name = naam
  succes = false
  succes = true if zwemmer.save
  render :json => {"succes" => succes, "kleur" => zwemmer.groep.niveau.kleurcode, "naam" => zwemmer.name, "klas" => " (#{zwemmer.kla.school.name[0..1]+zwemmer.kla.name})"}
end

def stat_file
  
  respond_to do |format|
      format.pdf do 
        pdf = StatPdf.new(params[:school], params[:jaar])
        send_data pdf.render, filename: "stat.pdf",
                              type: "application/pdf",
                              disposition: "inline"
      end
      format.xls do
        send_data( stats_to_xls(params[:school], params[:jaar]), :filename => "stats_#{School.find(params[:school]).name}_#{params[:jaar]}.xls" )
      end
  end
end

def temp_stat
    p1 = Picture.find(5)
    p2 = Picture.find(6)
    book = Spreadsheet::Workbook.new
    bold = Spreadsheet::Format.new :weight => :bold
    #@rows = rijen_per_niveau
    #@colors = colors
    nt_opgenomen_scholen = [13, 14] #lucerna en sint-martinus
    nt_opgenomen_scholen = []
    bladen_klassen = [[p1.klas.select{|kl_k, kl_v| (!kl_v[0].include? "k") && (!nt_opgenomen_scholen.include? kl_v[1])}, "alle zwemmers", false]]
    bladen_klassen.push([p1.klas.select{|kl_k, kl_v| (kl_v[2] == true) && (!kl_v[0].include? "k") && (!nt_opgenomen_scholen.include? kl_v[1])}, "2-wekelijks", false])
    bladen_klassen.push([p1.klas.select{|kl_k, kl_v| (kl_v[2] != true) && (!kl_v[0].include? "k") && (!nt_opgenomen_scholen.include? kl_v[1])}, "wekelijks", false])
    p1.schools.each do |id, naam|
      bladen_klassen.push([p1.klas.select{|kl_k, kl_v| (kl_v[1] == id) && (!kl_v[0].include? "k")}, naam, true])
    end
    bladen_klassen.each do |blad_klassen|
      rijen_per_jaar_en_niveau, rijen_per_niveau, rijen_per_jaar, totaal, jaar_totalen, diffs_totalen = stat_diff_general(blad_klassen[0], p1, p2)
      excel_row_counter = 1
      sheet = book.create_worksheet :name => blad_klassen[1]
      sheet.row(0).default_format = bold
      sheet[0,10] = blad_klassen[1].upcase
      sheet.row(3).set_format(3, bold)
      sheet[3,3] = "Totaal:"
      sheet[3,4] = totaal
      if blad_klassen[2]
        geprinte_klas_totalen = []
        sheet.row(2).set_format(7, bold)
        sheet[2,7] = "klassen:"
        sheet[2,8] = "jaartotaal"
        sheet[2,9] = "klas"
        excel_row_counter = 3
        blad_klassen[0].collect{|blad_klas_k, blad_klas_v| [blad_klas_k, blad_klas_v[0], blad_klas_v[2]]}.sort_by{|blad_klas| blad_klas[1]}.each_with_index do |kla, kla_i|
          sheet[excel_row_counter,9] = kla[1]
          sheet[excel_row_counter,10] = (kla[2] == true ? "2-wekelijks" : "wekelijks")
          kla_jaar = kla[1][0].to_i 
          if !geprinte_klas_totalen.include? kla_jaar
            sheet[excel_row_counter,8] = jaar_totalen[kla_jaar]
            geprinte_klas_totalen.push(kla_jaar)
          end
          excel_row_counter += 1
        end
      end
      excel_row_counter += 4
      sheet.row(excel_row_counter-1).default_format = bold
      sheet[excel_row_counter-1,9] = "evolutie per jaar en niveau, #{blad_klassen[1]}".upcase
      sheet[excel_row_counter,0] = "jaar"
      sheet[excel_row_counter,1] = "niveau"
      sheet[excel_row_counter,2] = "aantal niveaus gestegen"
      sheet[excel_row_counter,3] = "aantal"
      sheet[excel_row_counter,4] = "% van niveau"
      sheet[excel_row_counter,5] = "% van jaar"
      sheet[excel_row_counter,6] = "% van totaal"
      rijen_per_jaar_en_niveau.each_with_index do |row, row_index|
        excel_row_counter += 1
        row.each_with_index do |ele, ele_index|
          sheet[excel_row_counter, ele_index] = ele
        end
      end
      excel_row_counter += 4
      sheet.row(excel_row_counter-1).default_format = bold
      sheet[excel_row_counter-1,9] = "evolutie per niveau, #{blad_klassen[1]}".upcase
      sheet[excel_row_counter,0] = "niveau"
      sheet[excel_row_counter,1] = "aantal niveaus gestegen"
      sheet[excel_row_counter,2] = "aantal"
      sheet[excel_row_counter,3] = "% van niveau"
      sheet[excel_row_counter,4] = "% van totaal"
      rijen_per_niveau.each_with_index do |row, row_index|
        excel_row_counter += 1
        row.each_with_index do |ele, ele_index|
          sheet[excel_row_counter, ele_index] = ele
        end
      end
      excel_row_counter += 4
      sheet.row(excel_row_counter-1).default_format = bold
      sheet[excel_row_counter-1,9] = "evolutie per jaar, #{blad_klassen[1]}".upcase
      sheet[excel_row_counter,0] = "jaar"
      sheet[excel_row_counter,1] = "aantal niveaus gestegen"
      sheet[excel_row_counter,2] = "aantal"
      sheet[excel_row_counter,3] = "% van jaar"
      sheet[excel_row_counter,4] = "% van totaal"
      rijen_per_jaar.each_with_index do |row, row_index|
        excel_row_counter += 1
        row.each_with_index do |ele, ele_index|
          sheet[excel_row_counter, ele_index] = ele
        end
      end
      excel_row_counter += 4
      sheet.row(excel_row_counter-1).default_format = bold
      sheet[excel_row_counter-1,9] = "verdeling Δ".upcase
      sheet[excel_row_counter,1] = "aantal niveaus gestegen"
      sheet[excel_row_counter,2] = "aantal"
      sheet[excel_row_counter,3] = "% van totaal"
      diffs_totalen.each_with_index do |row, row_index|
        excel_row_counter += 1
        row.each_with_index do |ele, ele_index|
          sheet[excel_row_counter, ele_index+1] = ele
        end
      end
    end
    spreadsheet = StringIO.new
    book.write spreadsheet
    send_data( spreadsheet.string, :filename => "stats_comp.xls" )
    #render :json => {"comp" => {"rows" => to_send.to_json}, "colors" => colors.to_json}
  end

def handleiding
  
end
end