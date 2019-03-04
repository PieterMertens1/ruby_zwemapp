class StatPdf < Prawn::Document
	require_dependency 'foo.rb'
	include Foo
	def initialize(school, jaar)
		super(:margin => 40)
		
		freqs = Hash.new
		Niveau.all.each do |n| 
      		freqs[n.name] = 0
    	end
		case school
	      when ""
	        message = ""
	        klsn = []
	      when "lv"
	        message = "Lagere scholen #{jaar}es"
	        klsn = Kla.where("name not like ?", "%k%").where("name like ?", "#{jaar == '1 tot 6' ? '' : jaar}%")
	      when "wd"
	        message = "Wekelijks dilbeeks #{jaar}es"
	        klsn = Kla.where(tweeweek: false, nietdilbeeks: false).where("name like ?", "#{jaar == '1 tot 6' ? '' : jaar}%")
	      when "2d"
	        message = "2-wekelijks dilbeeks #{jaar}es"
	        klsn = Kla.where(tweeweek: true, nietdilbeeks: false).where("name like ?", "#{jaar == '1 tot 6' ? '' : jaar}%")
	      else
	        school = School.find(school)
	        message = "#{school.name} #{jaar}es"
	        if jaar == "1 tot 6"
	          klsn = school.klas.all
	        else
	          klsn = school.klas.select{|k| k.name[0] == jaar}
	        end
	      end
	      rows = stats_for_single(klsn)
		  text message, :align => :center
		  table rows do |t|
		  	t.position = :center
		  	t.columns(0..100).style(:size => 7.5)
		  end
	end
end