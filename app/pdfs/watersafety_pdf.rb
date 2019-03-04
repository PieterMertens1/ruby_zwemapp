# encoding: UTF-8
class WatersafetyPdf < Prawn::Document
	def initialize(grp)
		super(:page_layout => :landscape, :margin => 20)
		@groep = grp
		text "Watersafety-test #{@groep.lesuur.dag.name} #{@groep.lesuur.name} - #{@groep.niveau.name.upcase} - #{@groep.lesgever.name.capitalize} - alle zwemmers", :style => :bold, :size => 10, :align => :center
		move_down 30
		tafel
	end

	def tafel
		proef_column_width = (752 - 100 - 35) / 12
		table ([proef_rows] + zwemmer_rows) do |t|
			t.columns(0..50).style(
				:size => 7)
			t.columns(0).width = 100
			t.columns(1).width = 35
			t.columns(2..50).width = proef_column_width
		end
	end

	def zwemmer_rows
		rows = []
		empties = []
		12.times{empties.push("")}
		zwemmers = @groep.zicht_zwemmers.sort_by{ |zw| [-zw.kla.name.to_i, zw.kla.name, zw.kla.school.name, zw.name]}
		zwemmers.each_with_index do |z, zi|
			klasnaam = z.kla.school.name.upcase[0..1] +"-"+ z.kla.name.upcase
			row = ["#{zi+1}. #{z.name}", klasnaam] + empties
			rows.push(row)
		end
		return rows
	end

	def proef_rows
		rows = ["", ""]
		stahlman_tests = ["springen of duiken in diep groot bad",
							"12.5m zwemmen in buiklig met aquatische ademhaling",
							"5 seconden drijven in buiklig (kwalletje)", 
							"180° draaien rond lengeas",
							"12.5m zwemmen in ruglig",
							"10 seconden drijven in ruglig",
							"180° draaien rond diepteas",
							"5 maal ter plaatse aquatisch ademen",
							"12.5m zwemmen in ruglig",
							"180° verticaal draaien rond lengteas",
							"12.5m zwemmen in buiklig met aquatische ademhaling",
							"zelfstandig uit te water komen zonder trapje"]
		stahlman_tests.each_with_index do |t, ti|
			rows.push("#{ti+1}. #{t}")
		end
		return rows
	end
end