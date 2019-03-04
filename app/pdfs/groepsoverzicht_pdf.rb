class GroepsoverzichtPdf < Prawn::Document
	def initialize
		super(:margin => 10)
		text "GROEPEN", :size => 12, :align => :center
		move_down 10
		draw_table
	end
	def draw_table
		niveaus = Niveau.all
		totperlesuur = Hash.new
    	freqs = Hash.new
   		maxs = Hash.new
		niveaus.each do |n|
      		maxs[n.name] = 0
    	end
	    Dag.all.each do |d|
	      d.lesuurs.includes(:groeps).includes(:klas).each do |l|
	      	if not l.nietdilbeeks
		        Niveau.all.each do |n|
		          totperlesuur[n.name] = 0
		        end
		        l.groeps.includes(:niveau).includes(:lesgever).each do |g|
		          totperlesuur[g.niveau.name] = totperlesuur[g.niveau.name] + 1  
		        end
		        freqs[l.id] = {}
		        Niveau.all.each do |n|
		          if totperlesuur[n.name] > maxs[n.name]
		            maxs[n.name] = totperlesuur[n.name]
		          end
		          freqs[l.id][n.name] = {}
		          freqs[l.id][n.name] = totperlesuur[n.name]
		        end
		    end
	      end
	    end
	    rows = rijen(freqs, maxs, totperlesuur)
	    #text maxs.inspect, :size => 9
	    #text freqs.inspect, :size => 9
	    #text rows.inspect, :size => 8
	    lesuur_counter = 0
		table rows do |t|
			t.columns(0).width = 35
			t.columns(0..200).style(:size => 7)
			t.position = :center
			t.columns(0..200).style(:align => :center)
			t.cell_style = {:border_width => 1}
			niveau_borders = [6]
			acc = 6
			maxs.values[0..maxs.values.size-2].each_with_index do |max, maxi| 
				acc = acc + (max*6)
				niveau_borders.push(acc)
			end
			# 1 4 2 2 2 2 ||||| 6 12 36 48 60 72
			niveau_borders.each do |niv|
				t.cells[0,niv].border_width = [1,1,1,3] 
			end
			lesuur_counter = 0
			(0..rows.size-1).each do |row_index|
				if t.cells[row_index,0].colspan < 70
					niveau_borders.each do |niv|
						if t.cells[row_index,niv] 
							t.cells[row_index,niv].border_width = [1,1,1,3]
						end
					end
				end
			end
		end
	end
	def rijen(freqs, maxs, totperlesuur)
		# bereken totalen
		niveaus = Niveau.all
		
	    # eigenlijke tabel
	    maxcolspan = (maxs.values.inject{|sum,x| sum + x }+1)*6
		inter = []
		row = []
		row.push(:content => "", :colspan => 6)
		niveaus.each do |n|
			# opgepast, dit bekijkt ook niet-dilbeekse groepen
			if Groep.where(niveau_id: n.id).count > 0
				row.push(:content => n.name.upcase, :colspan => maxs[n.name]*6, :font_style => :bold)
			end
		end
		inter.push(row)
		Dag.all.each do |d|
			if d.lesuurs.count > 0
				inter.push([{:content => d.name.upcase, :colspan => maxcolspan, :font_style => :bold}])
				d.lesuurssorted.each do |l|
					if not l.nietdilbeeks
						row = []
						row.push(:content => l.name, :colspan => 6)
						groepen = l.groeps.sort {|y,x| y.niveau.position <=> x.niveau.position }
						groepteller = 0 
						niveaus.each do |n|
							maxteller = 0
							while maxteller < maxs[n.name] do
								comp = freqs[l.id][n.name] == 0 ? freqs[l.id][n.name] : (freqs[l.id][n.name]+1)
								if maxteller < comp
									groepslesgever = groepen[groepteller].lesgever.nil? ? " " : groepen[groepteller].lesgever.name
									omvang = ""
									groepen[groepteller].omvang.size > 1 ? (groepen[groepteller].omvang.each_with_index {|o, oi| omvang += "\n#{oi+1} : #{o}"}) : omvang = "\n" + groepen[groepteller].omvang[0].to_s 
									kleur = "\n (#{groepen[groepteller].niveau.name})"
									row.push(:content => groepslesgever + omvang + kleur, :colspan => ((maxs[n.name].to_f/freqs[l.id][n.name].to_f)*6).to_i)
									
									groepteller += 1
									maxteller += (maxs[n.name].to_f/freqs[l.id][n.name].to_f)
								else
									row.push(:content => "", :colspan => 6)
									maxteller += 1
								end
							end
						end
						inter.push(row)
					end
				end
			end
		end
		return inter
	end
end