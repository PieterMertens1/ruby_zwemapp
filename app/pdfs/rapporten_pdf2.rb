# encoding: UTF-8
class RapportenPdf2 < Prawn::Document
def initialize(kls)
	super(:margin => 40)
	@klas = kls
	@klas.zwemmers.sort_by{ |zw| zw.name}.each_with_index do |z, zidx|
		start_new_page unless zidx == 0 
		bounding_box([0, bounds.top], :width => 80, :height => 80) do
			image "#{Rails.root}/app/assets/images/dilkom5.png", :fit => [80,80]
		end
		bounding_box([100, bounds.top], :width => 170, :height => 80) do
			draw_text "zwemrapportje".upcase, :at => [115, bounds.top]
			move_down 15
			text "Naam: #{z.name}",:size => 10
			text "Klas: #{z.kla.school.name} #{z.kla.name}",:size => 10
			if z.rapports.last
				rap = z.rapports.last
				text "Niveau: #{z.groep.niveau.name}",:size => 10
				text "Lesgever: #{rap.lesgever.capitalize}",:size => 10
			end
		end
		if z.rapports.last
			rap = z.rapports.last
		end
		niveau_y = 673
		rec_width = 29 
		rec_heigth = 20 #40
		wit_begin_x = 532 - (rec_width * Niveau.count)
		#rectangle [wit_begin_x, niveau_y], rec_width, rec_heigth
		line_width 1
		#if (rap && rap.niveau == "wit") 
		# 	fill_color '7f8c8d' 
		#else
		# 	fill_color 'ffffff'
		#end
	  	#fill_and_stroke
	  	#fill_color '000000'
	  	#if (rap && rap.niveau == "wit")
		#	image "#{Rails.root}/app/assets/images/wit_vis_grijs.png", :at => [300, 674], :fit => [25, 25]
	  	#else
	  	#	image "#{Rails.root}/app/assets/images/wit_vis.png", :at => [300, 674], :fit => [25, 25]
	  	#end
	  	#draw_text "wit", :at => [wit_begin_x+8, niveau_y-13], :size => 8
		Niveau.order(:position).each do |n|
			i = n.position - 1
			rectangle [wit_begin_x+i*rec_width, niveau_y], rec_width, rec_heigth
			line_width 1
			if (rap && Niveau.where(name: rap.niveau).first.position == i+1) 
		 		fill_color '7f8c8d' 
			else
		 		fill_color 'ffffff'
			end
	  		fill_and_stroke
	  		fill_color '000000'
	  		niveau_name = [n.name]
	  		case n.name.length
	  		when 1..3
	  			pad = 8
	  		when 4
	  			pad = 6
	  		when 5..6
	  			pad = 4
	  		else
	  			pad = 2
	  		end
	  		case niveau_name[0]
	  		when "lichtblauw"
	  			niveau_name = ["licht", "blauw"]
	  		when "donkerblauw"
	  			niveau_name = ["donker", "blauw"]
	  		end
	  		if niveau_name.size > 1
	  			draw_text niveau_name[0], :at => [wit_begin_x+pad+i*rec_width, niveau_y-10], :size => 8
	  			draw_text niveau_name[1], :at => [wit_begin_x+pad+i*rec_width, niveau_y-16], :size => 8
	  		else
	  			draw_text niveau_name[0], :at => [wit_begin_x+pad+i*rec_width, niveau_y-13], :size => 8
	  		end
	  		
	  		#draw_text i.to_s, :at => [wit_begin_x+10+i*rec_width, niveau_y-30]
	  	end
	 #  	niveau_table_rows = [["wit", "groen", "groen 1", "groen 2", "geel", "oranje", "rood", "blauw", ""],
	 #  						["roze", "wit", "wit vis", "groen 1", "groen 2", "brons", "zilver", "goud", "lichtblauw","blauw", "donkerblauw"]]
	 #  	translation = {"wit"=>["roze", "wit"], "wit vis"=>["wit vis"],"groen"=>["groen 1"], "groen 1"=>["groen 2"], "groen 2"=>["brons"],"geel"=>["zilver"],"oranje"=>["goud"],"rood"=>["lichtblauw"],"blauw"=>["blauw"]}
	 #  	oud_row = ["OUD"]
	 #  	nieuw_row = ["NIEUW"]
	 #  	translation.each do |trans_key, trans_item|
	 #  		background_color = (z.groep.niveau.name == trans_key ? '7f8c8d' : 'ffffff')
	 #  		oud_row.push({content: trans_key, colspan: 2, background_color: background_color})
	 #  		trans_item.each do |item|
	 #  			colspan = trans_item.size > 1 ? 1 : 2
	 #  			nieuw_row.push({content: item, colspan: colspan, background_color: background_color})
	 #  		end
	 #  	end
	 #  	nieuw_row.push({content: "donkerblauw", colspan: 2, background_color: 'ffffff'})
	 #  	niveaus_rows = [oud_row, nieuw_row]
	 #  	bounding_box [192, bounds.bottom + 680], :width  => 50 do
		#   	table niveaus_rows do |t|
		#   		t.rows(0..1).style(:align => :center)
		#   		t.rows(0..1).style(:size => 6)
		#   		t.columns(0).font_style = :bold
		#   		#t.columns(13..14).width=30
		#   		t.width=340
		#   	end
		# end
		if z.rapports.last
			rap = z.rapports.last
			niveaus = rap.niveaus.split(":")
			volgende_niveau = niveaus.at(niveaus.index(rap.niveau)+1)
			overgangen = z.overgangen_since_september
			if overgangen.size > 0
				move_down 10
				text "Vooruitgang in schooljaar '17-'18:", :style => :italic 
				move_down 10
				table overgangen_tafel(overgangen) do |t|
					t.columns(0..5).style(:size => 10)
					t.columns(0..5).style(:align => :center)
					t.row(0).font_style = :bold
					t.width = bounds.right
				end
				move_down 10
				text "Laatste rapport (#{rap.niveau} naar #{volgende_niveau}): ", :style => :italic 
			end	
			#move_down 10
			move_down 10
			tafel(rap)
			commentaar_en_legende(rap)
			move_down 10
			draw_text "Meer informatie over het zwemrapport en de werking van het schoolzwemmen vindt u terug op:", :at => [14, 23]
			draw_text "www.dilkom.be => schoolzwemmen", :at => [177, 10]
		end
	end
end

def tafel(rap)
	#rijen = rap.resultaats.map {|r| [r.name, r.score]}.push(["extra: " + rap.extra, ""])
	# http://www.worldstart.com/the-invisible-character/   
	# voor het bolletje staan geen spaties, maar wel 3 speciale karakters, getypt door: ALT-0160
	rijen = Array.new
	rijen = [["Test + remediëring", "Score"]]
	res_and_fout_count = rap.resultaats.count + rap.fout_count
	rap.resultaats.order("id ASC").each do |r|
		fouten = res_and_fout_count > 22 ? "" : "\n"
		r.fouts.each do |f|
			fouten = fouten + "\n" + "         - " + f.name
		end
		rijen.push(["* " + r.name.capitalize + fouten, r.score])
	end
	table rijen do |t|
		t.columns(0..1).style(:size => 10)
		t.rows(0).style(:align => :center)
		t.row(0).font_style = :bold
		t.columns(1).style(:align => :center)
		t.columns(1).width = 44
		t.width = bounds.right
		#t.rows(0..60).height = 60
	end
end
def overgangen_tafel(overgangen)
	ret_tafel = [["Datum", "Van", "Naar"]]
	overgangen.each do |overgang|
		ret_tafel.push(overgang)
	end
	return ret_tafel
end

def commentaar_en_legende(rap)
	# http://stackoverflow.com/questions/2695019/header-and-footer-in-prawn-pdf/3658530#3658530
	legende = [["A", "zeer goed"], ["B", "goed"], ["C", "bijna goed"], ["D", "zwak"]]
	commentaar = rap.standaard_extra.to_s + " " + rap.extra.to_s
	#bounding_box [bounds.left, bounds.bottom + 60], :width  => bounds.width do
	if commentaar.strip != ""
		bounding_box [116, bounds.bottom + 120], :width  => 300 do
			#text rap.standaard_extra.to_s + " " + rap.extra.to_s
			table [[rap.standaard_extra.to_s + " " + rap.extra.to_s]] do |t|
				t.width = 300
				t.rows(0).style :align => :center
			end
		end
	end
		bounding_box [bounds.right-80, bounds.bottom + 120], :width  => 80 do
			table legende do |t|
				t.columns(0..1).style(:size => 7)
				t.width = 80
			end
		end
	#end
end
end