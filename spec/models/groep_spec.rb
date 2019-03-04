require 'spec_helper'
describe Groep do
	it "has a valid factory" do
		FactoryGirl.build(:groep).should be_valid
	end

	it "returns a descriptive name" do
		lesgever = FactoryGirl.create(:lesgever, name: "diederik")
		groep = FactoryGirl.create(:groep, lesgever: lesgever)
		groep.descriptive_name.should == "maandag 8u40 groen diederik"
	end
	it "returns a correct gemiddelde" do
		groep = FactoryGirl.create(:groep)
		zwemmer1 = FactoryGirl.create(:zwemmer, groep: groep)
    	zwemmer2 = FactoryGirl.create(:zwemmer, groep: groep)
    	zwemmer3 = FactoryGirl.create(:zwemmer, groep: groep)
		#klas.should have(3).zwemmers
    	groep.gemiddelde.should == 4
	end

	it "correctly validates presence of lesuur_id" do
		FactoryGirl.build(:groep, lesuur_id: nil).should_not be_valid
	end

	it "correctly validates presence of niveau_id" do
		FactoryGirl.build(:groep, niveau_id: nil).should_not be_valid
	end

	describe "return the correct grootte" do
		before :each do
			lesuur = FactoryGirl.create(:lesuur)
			wit = FactoryGirl.create(:niveau, name: "wit")
			groen = FactoryGirl.create(:niveau, name: "groen")
			@witgroep = FactoryGirl.create(:groep, niveau: wit, lesuur: lesuur)
			@groengroep = FactoryGirl.create(:groep, niveau: groen, lesuur: lesuur)
			zwemmer1 = FactoryGirl.create(:zwemmer, groep: @witgroep)
	    	zwemmer2 = FactoryGirl.create(:zwemmer, groep: @witgroep)
	    	zwemmer3 = FactoryGirl.create(:zwemmer, groep: @witgroep)
	    	zwemmer4 = FactoryGirl.create(:zwemmer, groep: @witgroep, groepvlag: @groengroep.id)
		end
		it "for witte groep" do
	    	@witgroep.grootte.should == 4
		end
		it "for niet-witte groep" do
			@groengroep.grootte.should == 0
		end
	end

	it "(omvang) returns the correct grootte per week for groep met enkel wekelijkse" do
		# maak lesuur, niveau, groep, school en een wekelijkse klas
		lesuur = FactoryGirl.create(:lesuur)
		groen = FactoryGirl.create(:niveau, name: "groen")
		wit = FactoryGirl.create(:niveau, name: "wit")
		witgroep = FactoryGirl.create(:groep, niveau_id: wit.id, lesuur_id: lesuur.id)
		groep = FactoryGirl.create(:groep, niveau_id: groen.id, lesuur_id: lesuur.id)
		extragroep = FactoryGirl.create(:groep, niveau_id: groen.id, lesuur_id: lesuur.id)
		school = FactoryGirl.create(:school, name: "Kriebel")
		week_klas = FactoryGirl.create(:kla, name: "4a", week: 0, school_id: school.id, lesuur_id: lesuur.id)
		# maak zwemmers
		FactoryGirl.create(:zwemmer, groep_id: groep.id, kla_id: week_klas.id)
		FactoryGirl.create(:zwemmer, groep_id: groep.id, kla_id: week_klas.id)
		FactoryGirl.create(:zwemmer, groep_id: groep.id, kla_id: week_klas.id)
		FactoryGirl.create(:zwemmer, groep_id: witgroep.id, kla_id: week_klas.id, groepvlag: groep.id)
		FactoryGirl.create(:zwemmer, groep_id: extragroep.id, kla_id: week_klas.id)
		groep.omvang.should == [3]
	end
	it "(omvang) returns the correct grootte per week for groep met enkel wekelijkse met verborgen klas" do
		# maak lesuur, niveau, groep, school en een wekelijkse klas
		lesuur = FactoryGirl.create(:lesuur)
		groen = FactoryGirl.create(:niveau, name: "groen")
		wit = FactoryGirl.create(:niveau, name: "wit")
		witgroep = FactoryGirl.create(:groep, niveau_id: wit.id, lesuur_id: lesuur.id)
		groep = FactoryGirl.create(:groep, niveau_id: groen.id, lesuur_id: lesuur.id)
		extragroep = FactoryGirl.create(:groep, niveau_id: groen.id, lesuur_id: lesuur.id)
		school = FactoryGirl.create(:school, name: "Kriebel")
		week_klas = FactoryGirl.create(:kla, name: "4a", week: 0, school_id: school.id, lesuur_id: lesuur.id)
		week_klas_verborgen = FactoryGirl.create(:kla, name: "5a", week: 0, school_id: school.id, lesuur_id: lesuur.id, verborgen: true)
		# maak zwemmers
		FactoryGirl.create(:zwemmer, groep_id: groep.id, kla_id: week_klas.id)
		FactoryGirl.create(:zwemmer, groep_id: groep.id, kla_id: week_klas.id)
		FactoryGirl.create(:zwemmer, groep_id: groep.id, kla_id: week_klas.id)
		FactoryGirl.create(:zwemmer, groep_id: groep.id, kla_id: week_klas.id)
		FactoryGirl.create(:zwemmer, groep_id: groep.id, kla_id: week_klas_verborgen.id)
		FactoryGirl.create(:zwemmer, groep_id: witgroep.id, kla_id: week_klas.id, groepvlag: groep.id)
		FactoryGirl.create(:zwemmer, groep_id: extragroep.id, kla_id: week_klas.id)
		groep.omvang.should == [4]
	end
	it "(omvang) returns the correct grootte per week for tweeweeks" do
		# maak lesuur, niveau, groep, school en een wekelijkse, en 2 tweewekelijkse klassen
		lesuur = FactoryGirl.create(:lesuur)
		groen = FactoryGirl.create(:niveau, name: "groen")
		wit = FactoryGirl.create(:niveau, name: "wit")
		witgroep = FactoryGirl.create(:groep, niveau_id: wit.id, lesuur_id: lesuur.id)
		groep = FactoryGirl.create(:groep, niveau_id: groen.id, lesuur_id: lesuur.id)
		school = FactoryGirl.create(:school, name: "Kriebel")
		week_klas = FactoryGirl.create(:kla, name: "4a", week: 0, school_id: school.id, lesuur_id: lesuur.id)
		tweeweek1_klas = FactoryGirl.create(:kla, name: "5a", tweeweek: true, week: 1, school_id: school.id, lesuur_id: lesuur.id)
		tweeweek2_klas = FactoryGirl.create(:kla, name: "5b", tweeweek: true, week: 2, school_id: school.id, lesuur_id: lesuur.id)
		# maak zwemmers
		FactoryGirl.create(:zwemmer, groep_id: groep.id, kla_id: week_klas.id)
		FactoryGirl.create(:zwemmer, groep_id: groep.id, kla_id: week_klas.id)
		FactoryGirl.create(:zwemmer, groep_id: groep.id, kla_id: week_klas.id)
		FactoryGirl.create(:zwemmer, groep_id: groep.id, kla_id: tweeweek1_klas.id)
		FactoryGirl.create(:zwemmer, groep_id: groep.id, kla_id: tweeweek2_klas.id)
		FactoryGirl.create(:zwemmer, groep_id: groep.id, kla_id: tweeweek2_klas.id)
		groep.omvang.should == [4,5]
	end
	it "(omvang) returns the correct grootte per week for tweeweeks with a verborgen klas" do
		# maak lesuur, niveau, groep, school en een wekelijkse, en 2 tweewekelijkse klassen
		lesuur = FactoryGirl.create(:lesuur)
		groen = FactoryGirl.create(:niveau, name: "groen")
		wit = FactoryGirl.create(:niveau, name: "wit")
		witgroep = FactoryGirl.create(:groep, niveau_id: wit.id, lesuur_id: lesuur.id)
		groep = FactoryGirl.create(:groep, niveau_id: groen.id, lesuur_id: lesuur.id)
		school = FactoryGirl.create(:school, name: "Kriebel")
		week_klas = FactoryGirl.create(:kla, name: "4a", week: 0, school_id: school.id, lesuur_id: lesuur.id)
		tweeweek1_klas = FactoryGirl.create(:kla, name: "5a", tweeweek: true, week: 1, school_id: school.id, lesuur_id: lesuur.id)
		tweeweek2_klas = FactoryGirl.create(:kla, name: "5b", tweeweek: true, week: 2, school_id: school.id, lesuur_id: lesuur.id, verborgen: true)
		# maak zwemmers
		3.times {FactoryGirl.create(:zwemmer, groep_id: groep.id, kla_id: week_klas.id)}
		6.times {FactoryGirl.create(:zwemmer, groep_id: groep.id, kla_id: tweeweek1_klas.id)}
		2.times {FactoryGirl.create(:zwemmer, groep_id: groep.id, kla_id: tweeweek2_klas.id)}
		groep.omvang.should == [9,3]
	end
end