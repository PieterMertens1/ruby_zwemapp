# encoding: UTF-8
class RapportenPdf < Prawn::Document
def initialize(kls)
	super(:margin => 40)
	@klas = kls
	@klas.zwemmers.sort_by{ |zw| zw.name}.each_with_index do |z, zidx|
		start_new_page unless zidx == 0 
		image "#{Rails.root}/app/assets/images/dilkom.png", :fit => [80,80], :at => [220, 720]
		text z.name
		text z.kla.school.name + " " + z.kla.name
		text z.groepvlag.to_i > 0 ? Groep.find(z.groepvlag).niveau.name : z.groep.niveau.name
		if z.rapports.last
			rap = z.rapports.last
			text rap.lesgever
			text rap.created_at.strftime("%d/%m/%Y")
			move_down 7
			tafel(rap)
			move_down 7
			legende
		end
	end
end

def tafel(rap)
	#rijen = rap.resultaats.map {|r| [r.name, r.score]}.push(["extra: " + rap.extra, ""])
	# http://www.worldstart.com/the-invisible-character/   
	# voor het bolletje staan geen spaties, maar wel 3 speciale karakters, getypt door: ALT-0160
	rijen = Array.new
	rap.resultaats.each do |r|
		fouten = ""
		r.fouts.each do |f|
			fouten = fouten + "\n" + "   • " + f.name
		end
		rijen.push(["- " + r.name + fouten, r.score])
	end
	rijen.push(["extra: " + rap.standaard_extra.to_s + " " + rap.extra.to_s, ""])
	table rijen do |t|
		t.columns(0..1).style(:size => 10)
	end
end

def legende
	# http://stackoverflow.com/questions/2695019/header-and-footer-in-prawn-pdf/3658530#3658530
	legende = [["AA", "uitstekend"], ["A", "zeer goed"], ["B", "goed"], ["C", "bijna goed"], ["D", "zwak"]]
	bounding_box [bounds.left, bounds.bottom + 100], :width  => bounds.width do
	table legende do |t|
		t.columns(0..1).style(:size => 7)
	end
end
end
end