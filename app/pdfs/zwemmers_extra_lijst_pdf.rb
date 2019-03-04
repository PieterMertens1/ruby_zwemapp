class ZwemmersExtraLijstPdf < Prawn::Document
	def initialize()
		@page_counts = []
		super(:margin => 20)
		text "Kinderen met aandachtspunten".upcase, :style => :bold, :size => 10, :align => :center
		tafel
	end

	def tafel
		move_down 15
		#table kinderen, :position => :center
		table kinderen do |t|
			t.columns(0).width = 150
			t.columns(1).width = 60
			t.position = :center
			t.columns(0..5).style(:size => 9)
		end
	end

	def kinderen
		z = Zwemmer.where("extra != ''").sort_by{ |zw| [-zw.kla.name.to_i, zw.kla.name, zw.kla.school.name, zw.name]}
		zwemmers = z.each_with_index.map { |x, i| [x.name, x.kla.school.name, x.kla.name, x.extra]}
	end
end