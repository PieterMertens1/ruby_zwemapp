require 'spec_helper'
describe Kla do
	it "has a valid factory" do
		FactoryGirl.build(:kla).should be_valid
	end

	it "validates presence of name correctly" do
		FactoryGirl.build(:kla, name: "").should_not be_valid
	end

	it "validates presence of school_id correctly" do
		FactoryGirl.build(:kla, school_id: nil).should_not be_valid
	end

	it "validates presence of lesuur_id correctly" do
		FactoryGirl.build(:kla, lesuur_id: nil).should_not be_valid
	end

	it { should validate_uniqueness_of(:name).with_message(/bestaat al/).scoped_to(:school_id) }

	it "should set all_rapports_klaar false for when not all zwemmers in klas have rapport klaar" do
		swimmers = []
		groep = FactoryGirl.create(:groep)
		klas = FactoryGirl.create(:kla)
		tijd = FactoryGirl.create(:tijd)
		5.times do |i|
			swimmers.push(FactoryGirl.create(:zwemmer, kla_id: klas.id, groep_id: groep.id))
		end
		swimmers.each do |s|
			FactoryGirl.create(:rapport, zwemmer_id: s.id, klaar: false)
		end
		klas.all_rapports_klaar.should == false
	end
	it "should set all_rapports_klaar true for when all zwemmers in klas have rapport klaar" do
		swimmers = []
		groep = FactoryGirl.create(:groep)
		klas = FactoryGirl.create(:kla)
		tijd = FactoryGirl.create(:tijd)
		5.times do |i|
			swimmers.push(FactoryGirl.create(:zwemmer, kla_id: klas.id, groep_id: groep.id))
		end
		swimmers.each do |s|
			FactoryGirl.create(:rapport, zwemmer_id: s.id, klaar: true)
		end
		klas.all_rapports_klaar.should == true
	end
	it "should set all_rapports_klaar false for when all zwemmers in klas have rapport klaar, but with rapports are from before last tijd" do
		swimmers = []
		groep = FactoryGirl.create(:groep)
		klas = FactoryGirl.create(:kla)
		tijd = FactoryGirl.create(:tijd)
		5.times do |i|
			swimmers.push(FactoryGirl.create(:zwemmer, kla_id: klas.id, groep_id: groep.id))
		end
		swimmers.each do |s|
			FactoryGirl.create(:rapport, zwemmer_id: s.id, klaar: true)
		end
		tijd = FactoryGirl.create(:tijd)
		klas.all_rapports_klaar.should == false
	end
end