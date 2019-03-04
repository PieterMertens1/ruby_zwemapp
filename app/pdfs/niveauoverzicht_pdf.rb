# encoding: UTF-8
class NiveauoverzichtPdf < Prawn::Document
	def initialize
		super(:margin => 40)
		text "NIVEAUS - PROEVEN - FOUTEN (#{Time.now.strftime("%d/%m/%Y")})", :align => :center
		move_down 30
		niveaus
	end

	def niveaus
		Niveau.order(:position).each do |n|
			text n.name.upcase, :align => :center
			tafel = [["proef + fouten", "type"]]
			belangrijk = []
			n.proefs.where(nietdilbeeks: false).order(:position).each_with_index do |p, pi|
				bouw = ""
				belangrijk.push(pi) if p.belangrijk
				p.fouts.order(:position).each do |f|
					bouw = bouw + "\n" + "   - " + f.name
				end
				tafel.push([(pi+1).to_s + ". " + p.content + bouw, p.scoretype])
			end
			table tafel do |t|
				t.columns(1).width = 45
				belangrijk.each do |b|
					t.rows(b+1).background_color = "C0C0C0"
				end
			end
			move_down 20
		end
	end
end