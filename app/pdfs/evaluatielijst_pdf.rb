class EvaluatielijstPdf < Prawn::Document
	@quoteringsadvies = false
	def initialize(grp, week, lesuur = nil)
		super(:page_layout => :landscape, :margin => 20)
		@page_counts = []
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
		@proefs = @groep.niveau.proefs.where("nietdilbeeks = ?", @groep.lesuur.nietdilbeeks).order("position")
		omvang = @groep.omvang
		toonweek = [1,2].include?(week) ? " - week #{week}" : " - wekelijks"
		case week
		when -1
			toonweek = " - alle zwemmers"
		when 1..2
			toonweek = " - week #{week}"
		else
			toonweek = " - wekelijks"
		end
   		omvang_html = ""
  		omvang.each_with_index {|o, oi| omvang_html += ((omvang.size>1 ? (oi+1).to_s + ": " : "")+o.to_s+(omvang.size == oi+1 ? "" : ","))}
		text "evaluatie #{@groep.lesuur.dag.name} #{@groep.lesuur.name} - #{@groep.niveau.name.upcase} - #{@groep.lesgever.name.capitalize} - #{omvang_html} #{toonweek}", :style => :bold, :size => 10, :align => :center
		get_zwemmers(week)
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
		when -1
			week_klassen = Kla.pluck(:id)
		when 1..2
			week_klassen = Kla.where(week: week).pluck(:id)
		else
			week_klassen = Kla.where(tweeweek:false).pluck(:id)
		end
		if @groep.niveau.name != "wit"
			swimmers = @groep.zicht_zwemmers.where(kla_id: week_klassen) + (wits.empty? ? [] : wits.where(kla_id: week_klassen))
			zwemmers = swimmers.sort_by{ |zw| [-zw.kla.name.to_i, zw.kla.name, zw.kla.school.name, zw.name]}
			zwemmers(zwemmers)
		else
			vol_witte_zwemmers = @groep.zicht_zwemmers.where('kla_id in (?) AND groepvlag = ?', week_klassen, 0)
			niet_wit_in_wit_zwemmers = @groep.zicht_zwemmers.where('kla_id in (?) AND groepvlag <> ?', week_klassen, 0)
			zwemmers(vol_witte_zwemmers.sort_by{ |zw| [-zw.kla.name.to_i, zw.kla.name, zw.kla.school.name, zw.name]}) 
			Niveau.order('position').all.each do |n|
				niveau_groepen_ids = Groep.where('niveau_id = ? AND lesuur_id = ?', n.id, @groep.lesuur.id)
				niveau_zwemmers = @groep.zicht_zwemmers.where('kla_id in (?) AND groepvlag in (?)', week_klassen, niveau_groepen_ids)
				if niveau_zwemmers.count > 0
					move_down 7
					text "#{n.name.upcase}", :style => :bold, :size => 10, :align => :center
					zwemmers(niveau_zwemmers.sort_by{ |zw| [-zw.kla.name.to_i, zw.kla.name, zw.kla.school.name, zw.name]}, n)
				end
			end
		end
	end
	def zwemmers(kinderen, niveau = @groep.niveau)
		move_down 7
		name_column_width = 100
		klas_column_width = 35
		proefs = niveau.proefs.where("nietdilbeeks = ?", @groep.lesuur.nietdilbeeks).order("position")
		proef_column_width = (752 - klas_column_width - name_column_width) / proefs.size
		
		#http://stackoverflow.com/questions/5685492/pdf-generating-with-prawn-how-can-i-acces-variable-in-prawn-generate
		rows = zwemmer_rows(kinderen, proefs)
		header_size = @quoteringsadvies ? 2 : 1
		table(rows, :header => header_size) do |t|
			t.columns(0..50).style(
				:size => 7)
			t.columns(0).width = name_column_width
			t.columns(1).width = klas_column_width
			t.columns(2..50).width = proef_column_width
			#t.row(0).columns(2..4).background_color = "D3D3D3"
			proefs.each_with_index do |i, index|
				if i.belangrijk == true
					t.cells[0,index+2].background_color = "808080"
				end
			end
		end
		
	end
	def zwemmer_rows(zwemmers, proefs)
		zwemmers = zwemmers.each_with_index.map do |z, zi|
			[
				(zi+1).to_s+". "+z.name+ ((z.groepvlag>0 && @groep.niveau.name != "wit") ? " (wit)" : ""), z.kla.school.name.upcase[0..1] +"-"+ z.kla.name.upcase
			]
		end
		zwemmers.each do |z|
			(get_proefs(proefs)[0].length-2).times do
				z.push("")
			end
		end
		get_proefs(proefs) + zwemmers
	end 
	def get_proefs(proefs)
		extra =["A: zeer goed\nB: goed\nC: bijna goed\nD: zwak", ""]
		result = Array.new
		quoterings = ["QUOTERINGSADVIES", ""]
		proefs.each_with_index do |t, ti|
			result.push((ti+1).to_s + ". " + t.content)
			(t.quoterings.count > 0) ? quoterings.push(t.quoterings.first.content) : quoterings.push("")
		end
		if quoterings.detect{|q| (q != "QUOTERINGSADVIES" && q != "")}
			@quoteringsadvies = true
			result = [extra + result, quoterings]
		else
			result = [extra + result]
		end
	end
end