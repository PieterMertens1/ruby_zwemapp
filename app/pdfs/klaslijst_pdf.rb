class KlaslijstPdf < Prawn::Document
def initialize(kls)
	super(:margin => 40)
	@klas = kls
	text @klas.school.name + " " + @klas.name
	text @klas.lesuur.dag.name.to_s + " " + @klas.lesuur.name.to_s
	if @klas.tweeweek
		text "2-wekelijks, week #{@klas.week.to_s}"
	end
	tafel
end
def tafel
	move_down 15
	#table kinderen, :position => :center
	table kinderen do |t|
		t.columns(0).width = 150
		t.position = :center
	end
end
def kinderen
	z = @klas.zwemmers.sort_by{|z| z.name}
	zwemmers = z.each_with_index.map { |x, i| ["", i+1, x.name, x.groep.niveau.name]}
end
end