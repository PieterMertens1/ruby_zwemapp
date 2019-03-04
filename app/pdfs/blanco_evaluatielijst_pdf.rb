class BlancoEvaluatielijstPdf < Prawn::Document
	@quoteringsadvies = false
	def initialize(niveau)
		super(:page_layout => :landscape, :margin => 20)
		@niveau = niveau
		text "evaluatie - #{@niveau.name.upcase}", :style => :bold, :size => 10, :align => :center
		teken_tafel
	end
	def teken_tafel
		move_down 7
		name_column_width = 120
		klas_column_width = 35
		proefs = @niveau.proefs.where("nietdilbeeks = ?", false).order("position")
		proef_column_width = (752 - klas_column_width - name_column_width) / proefs.size
		
		rows = get_proefs(proefs)
		header_size = @quoteringsadvies ? 2 : 1
		table(rows, :header => header_size) do |t|
			t.columns(0..50).style(
				:size => 7)
			t.columns(0).width = name_column_width
			t.columns(1).width = klas_column_width
			t.columns(2..50).width = proef_column_width
			if @quoteringsadvies
				t.rows(2..50).height = 20
			else
				t.rows(1..50).height = 20
			end
			#t.row(0).columns(2..4).background_color = "D3D3D3"
			proefs.each_with_index do |i, index|
				if i.belangrijk == true
					t.cells[0,index+2].background_color = "808080"
				end
			end
		end
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
		zwemmers = (0..19).map{|i| ["#{i+1}.", ""]}
		zwemmers.each do |z|
			(proefs.length).times do
				z.push("")
			end
		end
		return (result + zwemmers)
	end
end