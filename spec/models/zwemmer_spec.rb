# encoding: UTF-8
# https://github.com/thoughtbot/factory_girl/wiki/How-factory_girl-interacts-with-ActiveRecord
# https://github.com/plataformatec/devise/wiki/How-To%3a-Controllers-and-Views-tests-with-Rails-3-%28and-rspec%29
# https://github.com/thoughtbot/factory_girl/blob/master/GETTING_STARTED.md

require 'spec_helper'
require 'data'
include Datums

describe Zwemmer do
	it "has a valid factory" do
		FactoryGirl.create(:zwemmer).should be_valid
	end
	it "is invalid without name" do
		FactoryGirl.build(:zwemmer, name: nil).should_not be_valid
	end
	it "is invalid without kla_id" do
		FactoryGirl.build(:zwemmer, kla_id: nil).should_not be_valid
	end
	it "is invalid without groep_id" do
		FactoryGirl.build(:zwemmer, groep_id: nil).should_not be_valid
	end
	it "upcases correctly" do
		zwemmer = FactoryGirl.create(:zwemmer, name: "Coenen Naïade Gaëten Cédric")
		zwemmer.name.should == "COENEN NAÏADE GAËTEN CÉDRIC"
	end
	it "upcases correctly before updating" do
		zwemmer = FactoryGirl.create(:zwemmer, name: "Coenen Naïade Gaëten Cédric")
		zwemmer.name = "Naïade"
		zwemmer.save
		zwemmer.name.should == "NAÏADE"
	end
	it "returns the correct search results" do
		#hier moet eerst groep aangemaakt worden, als hier -zwemmer1 = FactoryGirl.create(:zwemmer, name: "Smith")-enzovoort- gebruikt wordt, wordt geprobeerd om 3 keer eenzelfde lesgever aan te maken, met volgende fout als gevolg: "ActiveRecord::RecordInvalid:Validation failed: Email has already been taken, Name has already been taken"
		groep = FactoryGirl.create(:groep)
		zwemmer1 = FactoryGirl.create(:zwemmer, name: "Smith", groep: groep)
    	zwemmer2 = FactoryGirl.create(:zwemmer, name: "Jones", groep: groep)
    	zwemmer3 = FactoryGirl.create(:zwemmer, name: "Johnson", groep: groep)
    	Zwemmer.search("Jo").should == [zwemmer3, zwemmer2]
	end

	it "returns the correct search results for names with accents" do
		groep = FactoryGirl.create(:groep)
		zwemmer1 = FactoryGirl.create(:zwemmer, name: "Smith", groep: groep)
    	zwemmer2 = FactoryGirl.create(:zwemmer, name: "Fürst", groep: groep)
    	zwemmer3 = FactoryGirl.create(:zwemmer, name: "Johnson", groep: groep)
    	zwemmer4 = FactoryGirl.create(:zwemmer, name: "Possé Maéla", groep: groep)
    	zwemmer5 = FactoryGirl.create(:zwemmer, name: "Kaesemans Ariël-Oskar", groep: groep)
    	Zwemmer.search("Jo").should == [zwemmer3]
    	Zwemmer.search("FÜRST").should == [zwemmer2]
    	Zwemmer.search("fürst").should == [zwemmer2]
    	Zwemmer.search("possé").should == [zwemmer4]
    	Zwemmer.search("ariël").should == [zwemmer5]
	end

	it "should return empty array when searching for empty string" do
		groep = FactoryGirl.create(:groep)
		zwemmer1 = FactoryGirl.create(:zwemmer, name: "Smith", groep: groep)
    	zwemmer2 = FactoryGirl.create(:zwemmer, name: "Fürst", groep: groep)
    	zwemmer3 = FactoryGirl.create(:zwemmer, name: "Johnson", groep: groep)
    	zwemmer4 = FactoryGirl.create(:zwemmer, name: "Possé Maéla", groep: groep)
    	zwemmer5 = FactoryGirl.create(:zwemmer, name: "Kaesemans Ariël-Oskar", groep: groep)
    	Zwemmer.search("").should == []
	end
	it "should return the correct progress (overgangen) since september of current school year" do
		witvis = FactoryGirl.create(:niveau, name: "wit vis")
		groen = FactoryGirl.create(:niveau, name: "groen")
		groen_1 = FactoryGirl.create(:niveau, name: "groen 1")
		groen_2 = FactoryGirl.create(:niveau, name: "groen 2")
		geel = FactoryGirl.create(:niveau, name: "geel")
		groep = FactoryGirl.create(:groep, niveau: groen_2)
		zwemmer1 = FactoryGirl.create(:zwemmer, name: "Maeskens Jean-paul", groep: groep)
		Timecop.freeze(DateTime.parse("01-12-2014 12:00:00")) do
		rapport = FactoryGirl.create(:rapport, zwemmer_id: zwemmer1.id, niveau: "groen 2")
			naar_groen = FactoryGirl.create(:overgang, van: "wit vis", naar: "groen", zwemmer: zwemmer1, created_at: DateTime.parse("01-06-2014 12:00:00"))
			naar_groen_1 = FactoryGirl.create(:overgang, van: "groen", naar: "groen 1", zwemmer: zwemmer1, created_at: DateTime.parse("01-10-2014 12:00:00"))
			naar_groen_2 = FactoryGirl.create(:overgang, van: "groen 1", naar: "groen 2", zwemmer: zwemmer1, created_at: DateTime.parse("01-11-2014 12:00:00"))
			zwemmer1.overgangen_since_september.should == [["01-10-2014", "groen", "groen 1"], ["01-11-2014", "groen 1", "groen 2"]]
		end
	end
	it "should return the correct progress (overgangen) since september of current school year (with overgang from last rapport)" do
		witvis = FactoryGirl.create(:niveau, name: "wit vis")
		groen = FactoryGirl.create(:niveau, name: "groen")
		groen_1 = FactoryGirl.create(:niveau, name: "groen 1")
		groen_2 = FactoryGirl.create(:niveau, name: "groen 2")
		geel = FactoryGirl.create(:niveau, name: "geel")
		groep = FactoryGirl.create(:groep, niveau: groen_2)
		zwemmer1 = FactoryGirl.create(:zwemmer, name: "Maeskens Jean-paul", groep: groep)
		Timecop.freeze(DateTime.parse("01-12-2014 12:00:00")) do
			rapport = FactoryGirl.create(:rapport, zwemmer_id: zwemmer1.id, niveau: "groen 2")
			naar_groen = FactoryGirl.create(:overgang, van: "wit vis", naar: "groen", zwemmer: zwemmer1, created_at: DateTime.parse("01-06-2014 12:00:00"))
			naar_groen_1 = FactoryGirl.create(:overgang, van: "groen", naar: "groen 1", zwemmer: zwemmer1, created_at: DateTime.parse("01-10-2014 12:00:00"))
			naar_groen_2 = FactoryGirl.create(:overgang, van: "groen 1", naar: "groen 2", zwemmer: zwemmer1, created_at: DateTime.parse("01-11-2014 12:00:00"))
			naar_geel = FactoryGirl.create(:overgang, van: "groen 2", naar: "geel", zwemmer: zwemmer1, created_at: DateTime.parse("03-11-2014 12:00:00"))
			zwemmer1.overgangen_since_september.should == [["01-10-2014", "groen", "groen 1"], ["01-11-2014", "groen 1", "groen 2"], ["03-11-2014", "groen 2", "geel"]]
	    end
	end
	it "should return the correct progress (overgangen) since september of current school year of zwemmer who was sent back" do
		witvis = FactoryGirl.create(:niveau, name: "wit vis")
		groen = FactoryGirl.create(:niveau, name: "groen")
		groen_1 = FactoryGirl.create(:niveau, name: "groen 1")
		groen_2 = FactoryGirl.create(:niveau, name: "groen 2")
		geel = FactoryGirl.create(:niveau, name: "geel")
		groep = FactoryGirl.create(:groep, niveau: groen_2)
		zwemmer1 = FactoryGirl.create(:zwemmer, name: "Maeskens Jean-paul", groep: groep)
		Timecop.freeze(DateTime.parse("01-12-2014 12:00:00")) do
			rapport = FactoryGirl.create(:rapport, zwemmer_id: zwemmer1.id, niveau: "groen 2")
			naar_groen = FactoryGirl.create(:overgang, van: "wit vis", naar: "groen", zwemmer: zwemmer1, created_at: DateTime.parse("01-06-2014 12:00:00"))
			naar_groen_1 = FactoryGirl.create(:overgang, van: "groen", naar: "groen 1", zwemmer: zwemmer1, created_at: DateTime.parse("01-10-2014 12:00:00"))
			terug_naar_groen = FactoryGirl.create(:overgang, van: "groen 1", naar: "groen", zwemmer: zwemmer1, created_at: DateTime.parse("05-10-2014 12:00:00"))
			naar_groen_2 = FactoryGirl.create(:overgang, van: "groen 1", naar: "groen 2", zwemmer: zwemmer1, created_at: DateTime.parse("01-11-2014 12:00:00"))
			zwemmer1.overgangen_since_september.should == [["01-10-2014", "groen", "groen 1"], ["01-11-2014", "groen 1", "groen 2"]]
		end
	end
	it "should return the correct progress (overgangen) since september of current school year (with 1 overgang missing)" do
		witvis = FactoryGirl.create(:niveau, name: "wit vis")
		groen = FactoryGirl.create(:niveau, name: "groen")
		groen_1 = FactoryGirl.create(:niveau, name: "groen 1")
		groen_2 = FactoryGirl.create(:niveau, name: "groen 2")
		geel = FactoryGirl.create(:niveau, name: "geel")
		groep = FactoryGirl.create(:groep, niveau: groen_2)
		Timecop.freeze(DateTime.parse("01-12-2014 12:00:00")) do
			zwemmer1 = FactoryGirl.create(:zwemmer, name: "Maeskens Jean-paul", groep: groep)
			rapport = FactoryGirl.create(:rapport, zwemmer_id: zwemmer1.id, niveau: "groen 2")
			naar_groen = FactoryGirl.create(:overgang, van: "wit vis", naar: "groen", zwemmer: zwemmer1, created_at: DateTime.parse("01-10-2014 12:00:00"))
			#naar_groen_1 = FactoryGirl.create(:overgang, van: "groen", naar: "groen 1", zwemmer: zwemmer1, created_at: DateTime.parse("03-10-2014 12:00:00"))
			naar_groen_2 = FactoryGirl.create(:overgang, van: "groen 1", naar: "groen 2", zwemmer: zwemmer1, created_at: DateTime.parse("01-11-2014 12:00:00"))
			
			zwemmer1.overgangen_since_september.should == [["01-10-2014", "wit vis", "groen"], ["01-11-2014", "groen", "groen 1"], ["01-11-2014", "groen 1", "groen 2"]]
		end
	end
	it "should return the correct progress (overgangen) since september of current school year (with 2 consecutive overgangen missing)" do
		witvis = FactoryGirl.create(:niveau, name: "wit vis")
		groen = FactoryGirl.create(:niveau, name: "groen")
		groen_1 = FactoryGirl.create(:niveau, name: "groen 1")
		groen_2 = FactoryGirl.create(:niveau, name: "groen 2")
		geel = FactoryGirl.create(:niveau, name: "geel")
		groep = FactoryGirl.create(:groep, niveau: groen_2)
		zwemmer1 = FactoryGirl.create(:zwemmer, name: "Maeskens Jean-paul", groep: groep)
		Timecop.freeze(DateTime.parse("01-12-2014 12:00:00")) do
			rapport = FactoryGirl.create(:rapport, zwemmer_id: zwemmer1.id, niveau: "geel")
			naar_groen = FactoryGirl.create(:overgang, van: "wit vis", naar: "groen", zwemmer: zwemmer1, created_at: DateTime.parse("01-10-2014 12:00:00"))
			#naar_groen_1 = FactoryGirl.create(:overgang, van: "groen", naar: "groen 1", zwemmer: zwemmer1, created_at: DateTime.parse("03-10-2014 12:00:00"))
			#naar_groen_2 = FactoryGirl.create(:overgang, van: "groen 1", naar: "groen 2", zwemmer: zwemmer1, created_at: DateTime.parse("01-11-2014 12:00:00"))
			naar_geel = FactoryGirl.create(:overgang, van: "groen 2", naar: "geel", zwemmer: zwemmer1, created_at: DateTime.parse("01-11-2014 12:00:00"))
			
			zwemmer1.overgangen_since_september.should == [["01-10-2014", "wit vis", "groen"], ["01-11-2014", "groen", "groen 1"], ["01-11-2014", "groen 1", "groen 2"], ["01-11-2014", "groen 2", "geel"]]
		end
	end
	it "should return the correct progress (overgangen) since september of current school year (with 2 npn-consecutive overgangen missing)" do
		witvis = FactoryGirl.create(:niveau, name: "wit vis")
		groen = FactoryGirl.create(:niveau, name: "groen")
		groen_1 = FactoryGirl.create(:niveau, name: "groen 1")
		groen_2 = FactoryGirl.create(:niveau, name: "groen 2")
		geel = FactoryGirl.create(:niveau, name: "geel")
		oranje = FactoryGirl.create(:niveau, name: "oranje")
		groep = FactoryGirl.create(:groep, niveau: groen_2)
		zwemmer1 = FactoryGirl.create(:zwemmer, name: "Maeskens Jean-paul", groep: groep)
		Timecop.freeze(DateTime.parse("01-12-2014 12:00:00")) do
			rapport = FactoryGirl.create(:rapport, zwemmer_id: zwemmer1.id, niveau: "oranje")
			naar_groen = FactoryGirl.create(:overgang, van: "wit vis", naar: "groen", zwemmer: zwemmer1, created_at: DateTime.parse("01-10-2014 12:00:00"))
			#naar_groen_1 = FactoryGirl.create(:overgang, van: "groen", naar: "groen 1", zwemmer: zwemmer1, created_at: DateTime.parse("03-10-2014 12:00:00"))
			naar_groen_2 = FactoryGirl.create(:overgang, van: "groen 1", naar: "groen 2", zwemmer: zwemmer1, created_at: DateTime.parse("01-11-2014 12:00:00"))
			#naar_geel = FactoryGirl.create(:overgang, van: "groen 2", naar: "geel", zwemmer: zwemmer1, created_at: DateTime.parse("01-11-2014 12:00:00"))
			naar_oranje = FactoryGirl.create(:overgang, van: "geel", naar: "oranje", zwemmer: zwemmer1, created_at: DateTime.parse("06-11-2014 12:00:00"))
			
			zwemmer1.overgangen_since_september.should == [["01-10-2014", "wit vis", "groen"], ["01-11-2014", "groen", "groen 1"], ["01-11-2014", "groen 1", "groen 2"], ["06-11-2014", "groen 2", "geel"], ["06-11-2014", "geel", "oranje"]]
	    end
	end
	it "should return the correct progress (overgangen) since september of current school year (with sending back and forth)" do
		witvis = FactoryGirl.create(:niveau, name: "wit vis")
		groen = FactoryGirl.create(:niveau, name: "groen")
		groen_1 = FactoryGirl.create(:niveau, name: "groen 1")
		groen_2 = FactoryGirl.create(:niveau, name: "groen 2")
		geel = FactoryGirl.create(:niveau, name: "geel")
		oranje = FactoryGirl.create(:niveau, name: "oranje")
		groep = FactoryGirl.create(:groep, niveau: groen_2)
		zwemmer1 = FactoryGirl.create(:zwemmer, name: "Maeskens Jean-paul", groep: groep)
		Timecop.freeze(DateTime.parse("01-12-2014 12:00:00")) do
			rapport = FactoryGirl.create(:rapport, zwemmer_id: zwemmer1.id, niveau: "oranje")
			naar_groen = FactoryGirl.create(:overgang, van: "wit vis", naar: "groen", zwemmer: zwemmer1, created_at: DateTime.parse("01-10-2014 12:00:00"))
			naar_groen_1 = FactoryGirl.create(:overgang, van: "groen", naar: "groen 1", zwemmer: zwemmer1, created_at: DateTime.parse("03-10-2014 12:00:00"))
			naar_groen = FactoryGirl.create(:overgang, van: "groen 1", naar: "groen", zwemmer: zwemmer1, created_at: DateTime.parse("05-10-2014 12:00:00"))
			naar_groen_2 = FactoryGirl.create(:overgang, van: "groen 1", naar: "groen 2", zwemmer: zwemmer1, created_at: DateTime.parse("01-11-2014 12:00:00"))
			naar_geel = FactoryGirl.create(:overgang, van: "groen 2", naar: "geel", zwemmer: zwemmer1, created_at: DateTime.parse("02-11-2014 12:00:00"))
			naar_oranje = FactoryGirl.create(:overgang, van: "geel", naar: "oranje", zwemmer: zwemmer1, created_at: DateTime.parse("06-11-2014 12:00:00"))
			
			zwemmer1.overgangen_since_september.should == [["01-10-2014", "wit vis", "groen"], ["03-10-2014", "groen", "groen 1"], ["01-11-2014", "groen 1", "groen 2"], ["02-11-2014", "groen 2", "geel"], ["06-11-2014", "geel", "oranje"]]
		end
	end

	it { should have_many(:rapports).dependent(:destroy) }
	it { should have_many(:overgangs) }
end