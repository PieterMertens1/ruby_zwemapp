require 'spec_helper'

describe FrontsController do
	
	describe "ingelogd" do
		before :each do
			@request.env["devise.mapping"] = Devise.mappings[:lesgever]
			@lesgever = FactoryGirl.create(:lesgever)
			@lesuur = FactoryGirl.create(:lesuur)
			@groep = FactoryGirl.create(:groep, lesgever: @lesgever, lesuur_id: @lesuur.id)
			@klas = FactoryGirl.create(:kla, lesuur_id: @lesuur.id)
	      	sign_in @lesgever
		end
		it "renders import_form template" do
			get :import_form
			response.should render_template :import_form
			assigns(:codes).should eq({@groep.niveau.karakter.to_s => @groep.niveau.name})
		end
		it "should correctly return getstat data" do
			school = FactoryGirl.create(:school)
			klas3a = FactoryGirl.create(:kla, school_id: school.id, name: "3a", tweeweek: false, nietdilbeeks: false)
			klas4b = FactoryGirl.create(:kla, school_id: school.id, name: "4b", tweeweek: false, nietdilbeeks: false)
			klas5b = FactoryGirl.create(:kla, school_id: school.id, name: "5b", tweeweek: true, nietdilbeeks: false)
			groen = @groep.niveau
			geel = FactoryGirl.create(:niveau, name: "geel")
			oranje = FactoryGirl.create(:niveau, name: "oranje") 
			gr_groen = @groep
			gr_geel = FactoryGirl.create(:groep, lesuur_id: @lesuur.id, niveau_id: geel.id) 
			gr_oranje = FactoryGirl.create(:groep, lesuur_id: @lesuur.id, niveau_id: oranje.id) 
			z1 = FactoryGirl.create(:zwemmer, kla_id: klas3a.id, groep_id: gr_geel.id)
			z2 = FactoryGirl.create(:zwemmer, kla_id: klas3a.id, groep_id: gr_groen.id)
			z3 = FactoryGirl.create(:zwemmer, kla_id: klas3a.id, groep_id: gr_geel.id)
			z4 = FactoryGirl.create(:zwemmer, kla_id: klas3a.id, groep_id: gr_oranje.id)
			z5 = FactoryGirl.create(:zwemmer, kla_id: klas3a.id, groep_id: gr_groen.id)
			z6 = FactoryGirl.create(:zwemmer, kla_id: klas3a.id, groep_id: gr_groen.id)
			###
			z7 = FactoryGirl.create(:zwemmer, kla_id: klas4b.id, groep_id: gr_groen.id)
			z8 = FactoryGirl.create(:zwemmer, kla_id: klas5b.id, groep_id: gr_oranje.id)
			get :getstat,:school1 => school.id, :jaar1 => "3",:school2 => school.id, :jaar2 => "3", :format => :json
			JSON.parse(response.body)["freqs"].should == [3,2,1]
			JSON.parse(response.body)["freqs2"].should == [3,2,1]
			get :getstat,:school1 => school.id, :jaar1 => "1 tot 6",:school2 => school.id, :jaar2 => "3", :format => :json
			JSON.parse(response.body)["freqs"].should == [4,2,2]
			JSON.parse(response.body)["freqs2"].should == [3,2,1]
			get :getstat,:school1 => "wd", :jaar1 => "3",:school2 => school.id, :jaar2 => "3", :format => :json
			JSON.parse(response.body)["freqs"].should == [3,2,1]
			JSON.parse(response.body)["freqs2"].should == [3,2,1]
			get :getstat,:school1 => "2d", :jaar1 => "5",:school2 => school.id, :jaar2 => "3", :format => :json
			JSON.parse(response.body)["freqs"].should == [0,0,1]
			JSON.parse(response.body)["freqs2"].should == [3,2,1]
			get :getstat,:school1 => school.id, :jaar1 => "3",:school2 => "", :jaar2 => "3", :format => :json
			JSON.parse(response.body)["freqs"].should == [3,2,1]
			JSON.parse(response.body)["freqs2"].should == [0,0,0]
		end
		it "should correctly return getstat data for picture" do
			school2 = FactoryGirl.create(:school, name: "Kriebel")
			p = Picture.create(FactoryGirl.attributes_for(:picture))
			# gewone picture
			get :getstat,:school1 => @klas.school.id, :jaar1 => "1", picture1: p.id, :school2 => school2.id, :jaar2 => "5", picture2: p.id, :format => :json
			JSON.parse(response.body)["freqs"].should == [5,2,6,2,12,3]
			JSON.parse(response.body)["freqs2"].should == [21,11,9,13,5,16]
			# picture met school leeg
			get :getstat,:school1 => @klas.school.id, :jaar1 => "1", picture1: p.id, :school2 => "", :jaar2 => "5", picture2: p.id, :format => :json
			JSON.parse(response.body)["freqs"].should == [5,2,6,2,12,3]
			JSON.parse(response.body)["freqs2"].should == [0]
			# picture met school 1, jaar 1 tot 6
			get :getstat,:school1 => @klas.school.id, :jaar1 => "1", picture1: p.id, :school2 => school2.id, :jaar2 => "1 tot 6", picture2: p.id, :format => :json
			JSON.parse(response.body)["freqs"].should == [5,2,6,2,12,3]
			JSON.parse(response.body)["freqs2"].should == [62, 58, 57, 77, 50, 71]
			# picture met school als wd , jaar 3
			get :getstat,:school1 => @klas.school.id, :jaar1 => "1", picture1: p.id, :school2 => "wd", :jaar2 => "3", picture2: p.id, :format => :json
			JSON.parse(response.body)["freqs"].should == [5,2,6,2,12,3]
			JSON.parse(response.body)["freqs2"].should == [39,40,37,39,27,43]
			# picture met school als wd , jaar 1 tot 6
			get :getstat,:school1 => @klas.school.id, :jaar1 => "1", picture1: p.id, :school2 => "wd", :jaar2 => "1 tot 6", picture2: p.id, :format => :json
			JSON.parse(response.body)["freqs"].should == [5,2,6,2,12,3]
			JSON.parse(response.body)["freqs2"].should == [132, 123, 102, 141, 115, 122]
			# picture met school als 2d , jaar 3
			get :getstat,:school1 => @klas.school.id, :jaar1 => "1", picture1: p.id, :school2 => "2d", :jaar2 => "3", picture2: p.id, :format => :json
			JSON.parse(response.body)["freqs"].should == [5,2,6,2,12,3]
			JSON.parse(response.body)["freqs2"].should == [5,7,2,4,3,9]
			# picture met school als 2d , jaar 1 tot 6
			get :getstat,:school1 => @klas.school.id, :jaar1 => "1", picture1: p.id, :school2 => "2d", :jaar2 => "1 tot 6", picture2: p.id, :format => :json
			JSON.parse(response.body)["freqs"].should == [5,2,6,2,12,3]
			JSON.parse(response.body)["freqs2"].should == [17, 17, 14, 14, 10, 18]
		end
		it "should correctly return autoinfo data" do
			groen = @groep.niveau
			geel = FactoryGirl.create(:niveau, name: "geel")
			oranje = FactoryGirl.create(:niveau, name: "oranje", karakter: 4, kleurcode: "#f89406") 
			z1 = FactoryGirl.create(:zwemmer, kla_id: @klas.id, groep_id: @groep.id)
			get :autoinfo,:zwemmers => "verhasselt diane\n#{z1.name}\njakhals janine4", :niveau => 2, :format => :json
			result =  JSON.parse(response.body)
			JSON.parse(result["zwemmers"]).should == [["VERHASSELT DIANE", "#FFF", "<i class=\"icon-plus\"></i>", "#{z1.name}(#{z1.kla.school.name[0..1] + z1.kla.name})", 1, "#FFF"], ["#{z1.name} (#{z1.kla.school.name[0..1] + z1.kla.name})", "#FFF", "<i class=\"icon-ok\"></i>", "", 0, ""], ["JAKHALS JANINE", "#f89406", "<i class=\"icon-plus\"></i>", "", 0, ""]] 
		end
		it "should correctly implement picture_calc return data" do
			school2 = FactoryGirl.create(:school, name: "Kriebel")
			#maak klassen
			(1..6).to_a.each do |i|
				FactoryGirl.create(:kla, name: i.to_s, school_id: school2.id, lesuur_id: @lesuur.id)
			end
			# maak niveaus en groepen
			groepen = {}
			groepen["groen"] = @groep.id
			["geel", "oranje", "rood", "blauw"].each_with_index do |s, si|
				n = FactoryGirl.create(:niveau, name: s, karakter: 3+si)
				g = FactoryGirl.create(:groep, lesuur_id: @lesuur.id, niveau_id: n.id, lesgever_id: @lesgever.id)
				# sla id's op van groepen per kleur
				groepen[s] = g.id
			end
			# in elke klas 5 zwemmers, 1 in elk niveau
			school2.klas.each do |k|
				5.times do |i|
					FactoryGirl.create(:zwemmer, kla_id: k.id, groep_id: groepen.values[i])
				end
			end
			attributes = FactoryGirl.attributes_for(:picture)
			# 1e foto
			niveaus_hash = {}
			Niveau.all.each{|n| niveaus_hash[n.position] = [n.name, n.kleurcode]}
			attributes[:niveaus] = niveaus_hash
			# totals_hash irrelevant
			details_hash = {}
			Zwemmer.all.each {|z| details_hash[z.id]= [(z.groepvlag > 0 ? Groep.find(z.groepvlag).niveau.position : z.groep.niveau.position), z.kla.name, (z.kla.tweeweek ? "2" : "w")+(z.kla.nietdilbeeks ? "n" : "d")]}
			attributes[:details] = details_hash
			p1 = FactoryGirl.create(:picture, attributes)
			p1.details[3][0].should == 3
			# stuur aantal zwemmers over
			zwemmers = {}
			Zwemmer.all.each{|z| zwemmers[z.id] = z.kla.name}
			Zwemmer.find(3).update_attributes(groep_id: groepen["rood"]) # 3 zit in 1e
			Zwemmer.find(16).update_attributes(groep_id: groepen["geel"]) # 16 zit in 4e
			Zwemmer.find(23).update_attributes(groep_id: groepen["blauw"]) # 23 zit in 5e
			# 2e foto
			details_hash = {}
			Zwemmer.all.each {|z| details_hash[z.id]= [(z.groepvlag > 0 ? Groep.find(z.groepvlag).niveau.position : z.groep.niveau.position), z.kla.name, (z.kla.tweeweek ? "2" : "w")+(z.kla.nietdilbeeks ? "n" : "d")]}
			attributes[:details] = details_hash
			p2 = FactoryGirl.create(:picture, attributes)
			p2.details[3][0].should == 4
			get :picture_calc,:school1 => 2, :jaar1 => "1 tot 6", picture1: p1.id, :school2 => "2", :jaar2 => "1 tot 6", picture2: p2.id, :format => :json
			# TODO
			#JSON.parse(response.body)["comp"]["total"].should == {0=>27, 1=>2, 2=>1}
			rows = [			[1,"groen", 0, 1, (1/1)*100, (1/5)*100, (1/30)*100],
																						["", "geel",  0, 1, (1/1)*100, (1/5)*100, (1/30)*100],
																						["", "oranje",  0, 0, (0/1)*100, (0/5)*100, (0/30)*100],
																						["", "",  1, 1, (1/1)*100, (1/5)*100, (1/30)*100],
																						["", "rood",  0, 1, (1/1)*100, (1/5)*100, (1/30)*100],
																						["", "blauw",  0, 1, (1/1)*100, (1/5)*100, (1/30)*100],
																						[2,"groen", 0, 1, (1/1)*100, (1/5)*100, (1/30)*100],
																						["", "geel",  0, 1, (1/1)*100, (1/5)*100, (1/30)*100],
																						["", "oranje",  0, 1, (1/1)*100, (1/5)*100, (1/30)*100],
																						["", "rood",  0, 1, (1/1)*100, (1/5)*100, (1/30)*100],
																						["", "blauw",  0, 1, (1/1)*100, (1/5)*100, (1/30)*100],
																						[3,"groen", 0, 1, (1/1)*100, (1/5)*100, (1/30)*100],
																						["", "geel",  0, 1, (1/1)*100, (1/5)*100, (1/30)*100],
																						["", "oranje",  0, 1, (1/1)*100, (1/5)*100, (1/30)*100],
																						["", "rood",  0, 1, (1/1)*100, (1/5)*100, (1/30)*100],
																						["", "blauw",  0, 1, (1/1)*100, (1/5)*100, (1/30)*100],
																						[4,"groen", 0, 0, (0/1)*100, (0/5)*100, (0/30)*100],
																						["", "",  1, 1, (1/1)*100, (1/5)*100, (1/30)*100],
																						["", "geel",  0, 1, (1/1)*100, (1/5)*100, (1/30)*100],
																						["", "oranje",  0, 1, (1/1)*100, (1/5)*100, (1/30)*100],
																						["", "rood",  0, 1, (1/1)*100, (1/5)*100, (1/30)*100],
																						["", "blauw",  0, 1, (1/1)*100, (1/5)*100, (1/30)*100],
																						[5,"groen", 0, 1, (1/1)*100, (1/5)*100, (1/30)*100],
																						["", "geel",  0, 1, (1/1)*100, (1/5)*100, (1/30)*100],
																						["", "oranje",  0, 0, (0/1)*100, (0/5)*100, (0/30)*100],
																						["", "",  1, 0, (0/1)*100, (0/5)*100, (0/30)*100],
																						["", "",  2, 1, (1/1)*100, (1/5)*100, (1/30)*100],
																						["", "rood",  0, 1, (1/1)*100, (1/5)*100, (1/30)*100],
																						["", "blauw",  0, 1, (1/1)*100, (1/5)*100, (1/30)*100],
																						[6,"groen", 0, 1, (1/1)*100, (1/5)*100, (1/30)*100],
																						["", "geel",  0, 1, (1/1)*100, (1/5)*100, (1/30)*100],
																						["", "oranje",  0, 1, (1/1)*100, (1/5)*100, (1/30)*100],
																						["", "rood",  0, 1, (1/1)*100, (1/5)*100, (1/30)*100],
																						["", "blauw",  0, 1, (1/1)*100, (1/5)*100, (1/30)*100]]
			rows = rows.collect{|r| [r[0], r[1], r[2], r[3], ((r[3].to_f/1.to_f)*100).round(2), ((r[3].to_f/5.to_f)*100).round(2), ((r[3].to_f/30.to_f)*100).round(2)]}
			JSON.parse(response.body)["comp"].should == {"rows" =>	rows.to_json}


		end
	end
end