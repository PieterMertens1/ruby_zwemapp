class ImportlijstPdf < Prawn::Document
def initialize(zwemmers)
	super(:margin => 40)
	@zwemmers = zwemmers
	tafel
end

def tafel
	zwemmers = @zwemmers.sort_by {|zw| [zw.kla.school.name, zw.kla.name, zw.name]}.each.map{|z| [z.name, z.kla.school.name, z.kla.name, z.created_at.strftime("%d/%m/%Y"), z.rapports.count, "#{z.groep.niveau.name}-#{z.groep.lesgever ? z.groep.lesgever.name : "/"}-#{z.groep.lesuur.dag.name} #{z.groep.lesuur.name}"]}
	zwemmers = [['naam', 'school', 'klas', 'datum toegevoegd', '# rapporten', 'groep']] + zwemmers
	table zwemmers do |t|
		t.columns(0..10).style(:size => 8)
	end
end
end