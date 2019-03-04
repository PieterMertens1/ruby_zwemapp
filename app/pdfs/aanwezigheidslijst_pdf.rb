class AanwezigheidslijstPdf < Prawn::Document
#http://railscasts.com/episodes/153-pdfs-with-prawn + revised
	require 'data'
	include Datums
	require 'prawn/table'
	def initialize(grp, week, lesuur = nil)
		@page_counts = []
		super(:page_layout => :landscape, :margin => 20)
		if lesuur == nil
			for_1_group(grp, week)
		else
			groepen = lesuur.groeps.sort {|y,x| y.niveau.position <=> x.niveau.position }
			groepen.each_with_index do |g, gi|
				for_1_group(g, week)
				start_new_page if gi != (groepen.size-1)
			end
		end
	end
	def for_1_group(grp, week)
		@groep = grp
		omvang = @groep.omvang
   		omvang_html = ""
  		omvang.each_with_index {|o, oi| omvang_html += ((omvang.size>1 ? (oi+1).to_s + ": " : "")+o.to_s+(omvang.size == oi+1 ? "" : ","))} 
		kinderen = get_zwemmers(week)
		scholen = kinderen.collect{|k| k.kla.school.name}.uniq.join("-")
		toonweek = [1,2].include?(week) ? " - week #{week}" : ""
		case week
		when 0
			toonweek = " - alle zwemmers"
		when 1..2
			toonweek = " - week #{week} + wekelijks"
		when 11..12
			toonweek = " - week #{week.to_s.last}"
		else
			toonweek = " - wekelijks"
		end
		header_row_tekst = "#{@groep.lesuur.dag.name} #{@groep.lesuur.name} - #{@groep.niveau.name.upcase} - #{@groep.lesgever.name.capitalize} - #{omvang_html} - (#{scholen})#{toonweek}"
		zwemmers(kinderen, header_row_tekst)
	end
	def get_zwemmers(week)
		wits = []
		verborgen_klassen = Kla.where(verborgen: true).pluck(:id)
		witgroep = Groep.where('lesuur_id = ? AND niveau_id = ?', @groep.lesuur.id, Niveau.where('name = ?', "wit").first.id).first
		if @groep.niveau.name != "wit" && witgroep
			if verborgen_klassen.empty?
				wits = Zwemmer.where('groep_id = ? AND groepvlag = ?', witgroep.id, @groep.id)
			else
      			wits = Zwemmer.where('groep_id = ? AND groepvlag = ? and kla_id not in (?)', witgroep.id, @groep.id, verborgen_klassen)
      		end
    	end
    	case week
    	when 0 # alle zwemmers in groep
    		swimmers = @groep.zicht_zwemmers + wits
    	when 1..2 # week 1/2 + wekelijkse
			week_klassen = Kla.where(week: week).pluck(:id) + Kla.where(tweeweek: false)
			swimmers = @groep.zicht_zwemmers.where(kla_id: week_klassen) + (wits.empty? ? [] : wits.where(kla_id: week_klassen))
		when 11..12 # week 1/2 alleen
			week_klassen = Kla.where(week: week.to_s.last).pluck(:id)
			swimmers = @groep.zicht_zwemmers.where(kla_id: week_klassen) + (wits.empty? ? [] : wits.where(kla_id: week_klassen))
		else # wekelijkse alleen
			week_klassen = Kla.where(tweeweek: false)
			swimmers = @groep.zicht_zwemmers.where(kla_id: week_klassen) + (wits.empty? ? [] : wits.where(kla_id: week_klassen))
		end
		zwemmers = swimmers.sort_by{ |zw| [-zw.kla.name.to_i, zw.kla.name, zw.kla.school.name, zw.name]}
		return zwemmers
	end
	def zwemmers(kinderen, header_row_tekst)
		move_down 7
		alle_dates, result_raw = get_dates
		vakanties = get_vakanties(Date.today.strftime("%Y").to_i, Date.today.strftime("%m").to_i)
		n_dates = alle_dates.size
		huidig_jaar = Time.now.year.to_s
		header_row = [{:content=>header_row_tekst, :colspan => n_dates, :align => :center, :font_style => :bold}]
		table([header_row] + zwemmers_rows(kinderen), :header=>2) do |t|
			t.columns(0..1).align = :left
			t.rows(0..kinderen.length+4).border_width = 0.5
			t.rows(1).style(
				:size => 6)
			t.columns(0).style(
				:size =>  7)
			t.columns(1).style(
				:size => 6)
			t.rows(0).style(:size => 9, :align => :center)
			t.columns(0).width = 99
			#t.columns(1).width = 29
			#columns(2..n_dates+2).width = 25
			t.width = 740
			t.row_colors = ["C0C0C0", "FFFFFF"]
			# volgende om lege rijen voldoende hoog te maken
			t.rows(kinderen.length+2..kinderen.length+8).height = 16
			result_raw.each_with_index do |date, di|
				if date != ""
					#date = Date.parse("#{d}/#{huidig_jaar}")
					if vakanties[date] != nil
						t.columns(di+2).background_color = "C0C0C0"
					end
				end
			end
			t.rows(0).background_color = "FFFFFF"
			#columns(2).width = 10
		end
		draw_voetnoot_and_vakanties(result_raw, vakanties, n_dates)
		#draw_text n_dates.to_s, :at => [50,560], :size => 8
	end
	def zwemmers_rows(zwemmers)
		@extras = []
		extrateller = 0
		result_clean, result_raw = get_dates
		# http://stackoverflow.com/questions/4697557/how-to-map-with-index-in-ruby
		zwemmers = zwemmers.each_with_index.map do |z, zi|
			extra = ""
			if z.extra.to_s != ''
				if @extras.include? z.extra.to_s
					extra = "(" + ((@extras.index z.extra.to_s) + 1).to_s + ")"
				else
					extrateller = extrateller + 1
					@extras.push z.extra
					extra = "(" + (@extras.size).to_s + ")"
				end
			end
			if z.badmuts && !z.badmuts.empty?
				["#{zi+1}. "+z.name + " (" + z.badmuts + ")" + extra, z.kla.school.name.upcase[0..1] +"-"+ z.kla.name.upcase]
			else
				if z.groepvlag.to_i > 0
					if @groep.niveau.name == "wit"
						next ["#{zi+1}. "+z.name + " (" + Groep.find(z.groepvlag).niveau.name + ")" + extra, z.kla.school.name.upcase[0..1] +"-"+ z.kla.name.upcase]
					else
						next ["#{zi+1}. "+z.name + " (wit)" + extra, z.kla.school.name.upcase[0..1] +"-"+ z.kla.name.upcase]
					end
				else
					next ["#{zi+1}. "+z.name + extra, z.kla.school.name.upcase[0..1] +"-"+ z.kla.name.upcase]
				end
			end
		end
		#=> [["ROGER VAN DAELE", "1b"], ["DALLAS DERAUW", "1b"], ["QUENTIN ROMBAUT", "1b"
		#], ["CRAWFORD VAN PELT", "3a"], ["ZOLLIE FRANCEUS", "3a"], ["ENRIQUE GOVAERT", "
		#3a"], ["MIKHAIL BRASSART", "3a"], ["RENAUD VAN HECKE", "3a"], ["LEONARD AMANT",
		#"4a"], ["ZACHARIAS DEWULF", "6a"], ["JO VERBEIREN", "6a"], ["GAV DE VIDTS", "6a"
		#]]
		zwemmers.each do |z|
			(result_clean.length-2).times do
				z.push("")
			end
		end
		lege_rijen = []
		inter = []
		result_clean.length.times {inter.push("")}
		3.times {lege_rijen.push(inter)}
		[result_clean] + zwemmers + lege_rijen
		#@groep.zwemmers.map do |z|
		#	[
		#		z.name,
		#		z.kla.school.name[0..1] + z.kla.name
		#	]
		#end
	end
	def draw_voetnoot_and_vakanties(alle_dates, vakanties, n_dates)
		voetnoot = ""
		@extras.each_with_index {|e, ei| voetnoot = voetnoot + "(#{ei+1}) #{e};"}
		move_down 5
		text voetnoot, :size => 8
		page_total = @page_counts.inject{|sum,x| sum + x } || 0
		current_page_count = page_count - page_total
		@page_counts.push(current_page_count)
		go_to_page(page_count - 1) if current_page_count > 1
		huidig_jaar = Time.now.year.to_s
		# teken vakantietekst
		alle_dates.each_with_index do |date, di|
			if date != ""
				#date = Date.parse("#{d}/#{huidig_jaar}")
				if vakanties[date] != nil
					vakanties[date].split(//).each_with_index do |l, li|
						case n_dates
						when 27
							draw_text l, :at => [138+(25*(di))-(di*0.4), 510-(li*10)], :size => 8
						when 26
							draw_text l, :at => [140+(26*(di))-(di*0.5), 510-(li*10)], :size => 8
						when 25
							draw_text l, :at => [142+(27*(di))-(di*0.5), 510-(li*10)], :size => 8
						when 24
							draw_text l, :at => [144+(28*(di))-(di*0.5), 510-(li*10)], :size => 8
						when 23
							draw_text l, :at => [144+(30*(di))-(di*0.6), 510-(li*10)], :size => 8
						else
							draw_text l, :at => [142+(27*(di))-(di*0.5), 510-(li*10)], :size => 8
						end
					end
				end
			end
		end
		go_to_page(page_count)
	end
	def get_dates
		### voor in 2 semesters ##
		#http://stackoverflow.com/questions/10429156/how-do-i-get-all-sundays-between-two-dates-in-ruby
		dagen = {"zondag" => 0, "maandag" => 1, "dinsdag" => 2, "woensdag" => 3, "donderdag" => 4, "vrijdag" => 5, "zaterdag" => 6}
		current_month = Date.today.strftime("%m").to_i
		if (current_month > 7) 
			start_year = Date.today.strftime("%Y").to_i
			end_year = start_year +1
			start_date = Date.parse("1-9-#{start_year}") # your start
			end_date = Date.parse("30-1-#{end_year}") # your end
		else
			year = Date.today.strftime("%Y").to_i
			start_date = Date.parse("3-1-#{year}") # your start
			end_date = Date.parse("25-6-#{year}") # your end
		end
		
		my_days = [dagen[@groep.lesuur.dag.name]] # day of the week in 0-6. Sunday is day-of-week 0; Saturday is day-of-week 6.
		extra = ["", ""]
		result_raw = (start_date..end_date).to_a.select {|k| my_days.include?(k.wday)} 
		result_clean = result_raw.map {|r| r.strftime("%d/%m")}
		return extra + result_clean, result_raw 
	end
=begin
	def get_year_dates
		# voor hele jaar
		dagen = {"zondag" => 0, "maandag" => 1, "dinsdag" => 2, "woensdag" => 3, "donderdag" => 4, "vrijdag" => 5, "zaterdag" => 6}
		current_month = Date.today.strftime("%m").to_i
		if current_month > 7
			start_year = Date.today.strftime("%Y").to_i 
		else
			start_year = Date.today.strftime("%Y").to_i - 1
		end
		end_year = start_year + 1
		start_date = Date.parse("1-9-#{start_year}") # your start
		end_date = Date.parse("30-6-#{end_year}") # your end
		my_days = [dagen[@groep.lesuur.dag.name]] # day of the week in 0-6. Sunday is day-of-week 0; Saturday is day-of-week 6.
		extra = ["", ""]
		result = (start_date..end_date).to_a.select {|k| my_days.include?(k.wday)} 
		result = result.map {|r| r.strftime("%d%m")}
		result = extra + result
=end
	
end