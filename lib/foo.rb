module Foo
  def suggestie(naam)
    ret = Zwemmer.all.collect{|z| [z.id, z.name.similar(naam), z.name]}.sort_by{|v| v[1]}.last
    z = Zwemmer.find(ret[0])
    return ret[0], "#{ret[2]}(#{z.kla.school.name[0..1]}#{z.kla.name})", z.groep.niveau.kleurcode
  end
  def current_day_index
    day = Time.now.wday
    if (1..5).include? day
      return day
    else
      return 1
    end
  end
  def week_split_light(groep)
    verborgen_klassen = Kla.where(verborgen: true).pluck(:id)
    week_1_klassen = Kla.where(week: 1).pluck(:id)
    week_2_klassen = Kla.where(week: 2).pluck(:id)
    a = []
    if verborgen_klassen.empty?
      a[1] = groep.zwemmers.where('kla_id in (?)', week_1_klassen).count
      a[2] = groep.zwemmers.where('kla_id in (?)', week_2_klassen).count
      a[0] = groep.zwemmers.count - a[1] - a[2]
    else
      a[1] = groep.zwemmers.where('kla_id not in (?) and kla_id in (?)', verborgen_klassen, week_1_klassen).count
      a[2] = groep.zwemmers.where('kla_id not in (?) and kla_id in (?)', verborgen_klassen, week_2_klassen).count
      a[0] = groep.zicht_zwemmers_count - a[1] - a[2]
    end
    return a 
  end
  def picture_comparison(p1, p2)
    p1 = Picture.find(p1)
    p2 = Picture.find(p2)
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
    # http://stackoverflow.com/questions/4453511/ruby-group-hashes-by-keys-and-sum-the-values
    totals = years.values.collect{|h| h.values}.flatten.inject{|memo, el| memo.merge( el ){|k, old_v, new_v| old_v + new_v}}
    ret_totals = [["aantal niveaus gestegen", "aantal", "% van totaal"]]
    totals.each do |k,v|
      ret_totals.push([k, v, ((v.to_f/complete_total.to_f)*100).round(2)])
    end
    return {'rows'=>[['jaar', 'niveau', 'aantal niveaus gestegen', 'aantal', '% van niveau', '% van jaar', '% van totaal']] + to_send, 'totals' => ret_totals}
  end

  def stats_for_single(klsn)
    # initialiseer alles
      year_totals = {}
      years = {}
      niveaus = Niveau.order(:position)
      (1..6).to_a.each {|i| year_totals[i] = 0}
      (1..6).to_a.each do |i| 
        years[i] = {}
        niveaus.each do |n|
          years[i][n.name] = 0
        end
      end

        klsn.each do |klas|
          klas.zwemmers.each do |z|
            jaar = z.kla.name[0].to_i
            year_totals[jaar] += 1
            years[jaar][z.groep.niveau.name] += 1
          end
        end
        complete_total = year_totals.values.inject{|sum, x| sum + x}

        rows = [["jaar", "niveau", "aantal", "% van jaar"]]
        years.each_with_index do |(y, nivs), years_index|
          year_put = false
          nivs.each_with_index do |(n, aantal), nivs_index|
            verhouding = (year_totals[y] == 0) ? "/" : ((aantal.to_f/year_totals[y].to_f)*100).round(2) 
            rows.push([(year_put ? "" : y), n, aantal, verhouding])
            year_put = true
          end
      end
      return rows
  end

  def stats_to_xls(school, jaar)

    case school
        when ""
          message = ""
          klsn = []
        when "lv"
          message = "Lagere scholen #{jaar}es"
          klsn = Kla.where("name not like ?", "%k%").where("name like ?", "#{jaar == '1 tot 6' ? '' : jaar}%")
        when "wd"
          message = "Wekelijks dilbeeks #{jaar}es"
          klsn = Kla.where(tweeweek: false, nietdilbeeks: false).where("name like ?", "#{jaar == '1 tot 6' ? '' : jaar}%")
        when "2d"
          message = "2-wekelijks dilbeeks #{jaar}es"
          klsn = Kla.where(tweeweek: true, nietdilbeeks: false).where("name like ?", "#{jaar == '1 tot 6' ? '' : jaar}%")
        else
          school = School.find(school)
          message = "#{school.name} #{jaar}es"
          if jaar == "1 tot 6"
            klsn = school.klas.all
          else
            klsn = school.klas.select{|k| k.name[0] == jaar}
          end
    end

    rows = stats_for_single(klsn)
    book = Spreadsheet::Workbook.new

    sheet = book.create_worksheet :name => "stats"

    bold = Spreadsheet::Format.new :weight => :bold
    #sheet.column(1).width = 10
    #sheet.column(3).width = 15
    rows.each_with_index do |r, ri|
      sheet[1+ri,1] = r[0]
      sheet[1+ri,2] = r[1]
      sheet[1+ri,3] = r[2]
      sheet[1+ri,4] = r[3]
    end

    sheet.row(1).default_format = bold
    spreadsheet = StringIO.new
    book.write spreadsheet
    return spreadsheet.string
  end

  def stat_diff_general(klassen, p1, p2)

    niet_verborgen_klassen = klassen.select{|kl_k, kl_v| kl_v[3] != true}.keys
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

    level_totals = {}
    p1.niveaus.each do |niv_k, niv_v|
      level_totals[niv_k] = {}
    end
    voor_jaar_totals = {}
    (1..6).to_a.each do |i|
      voor_jaar_totals[i] = {}
    end

    med = years.clone
    #start calc
    p1.details.each do |k, v|
      if niet_verborgen_klassen.include? v[3]
        z_id = k
        z_last = p2.details[z_id]
        if z_last 
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
    end
    complete_total = year_totals.values.inject{|sum, x| sum + x}

    to_send = []
    rows_level_total = []
    rows_jaar_total = []
    rows_diff_totals = []
    diffs_totals = {}
    years.each_with_index do |(y, nivs), years_index|
      year_put = false
      nivs.each_with_index do |(n, diffs), nivs_index|
        sum = 0
        total1 = diffs.values.inject{|sum, x| sum + x}
        diffs.each_with_index do |(d, aantal), diffs_index|
          voor_jaar_totals[y][d] ? voor_jaar_totals[y][d] += aantal : voor_jaar_totals[y][d] = aantal
          level_totals[n][d] ? level_totals[n][d] += aantal : level_totals[n][d] = aantal
          to_send.push([(year_put ? "" : y), (diffs_index > 0  ? "" : niveaus[n][0]), d, aantal, ((aantal.to_f/total1.to_f)*100).round(2), ((aantal.to_f/year_totals[y].to_f)*100).round(2), ((aantal.to_f/complete_total.to_f)*100).round(2)])
          diffs_totals[d] ? diffs_totals[d] += aantal : diffs_totals[d] = aantal 
          year_put = true
        end
      end
    end
    level_totals.each do |level, diffs|
      level_totaal = diffs.values.inject{|sum, x| sum + x}
      diffs.each do |diff, aantal|
        rows_level_total.push([(diff > 0 ? "" : niveaus[level][0]), diff, aantal, ((aantal.to_f/level_totaal.to_f)*100).round(2), ((aantal.to_f/complete_total.to_f)*100).round(2)])
      end
    end
    voor_jaar_totals.each do |jaar, diffs|
      jaar_totaal = diffs.values.inject{|sum, x| sum + x}
      diffs.each do |diff, aantal|
        rows_jaar_total.push([(diff > 0 ? "" : jaar), diff, aantal, ((aantal.to_f/jaar_totaal.to_f)*100).round(2), ((aantal.to_f/complete_total.to_f)*100).round(2)])
      end
    end
    diffs_totals.each do |diff, aantal|
      rows_diff_totals.push([diff, aantal, ((aantal.to_f/complete_total.to_f)*100).round(2)])
    end
    return to_send, rows_level_total, rows_jaar_total, complete_total, year_totals, rows_diff_totals
  end
end