require 'spec_helper'
describe School do
	it "has a valid factory" do
		FactoryGirl.build(:school).should be_valid
	end

	it { should validate_presence_of(:name) }
	it { should have_many(:klas) }

	it "should have a working (twee)week method for a week-school" do
		s = FactoryGirl.create(:school)
		FactoryGirl.create(:kla, school_id: s.id, tweeweek: false)
		FactoryGirl.create(:kla, school_id: s.id, tweeweek: false, name: "3a")
		s.week.should == true
		s.tweeweek.should == false
	end

	it "should have a working (twee)week method for a tweeweek-school" do
		s = FactoryGirl.create(:school)
		FactoryGirl.create(:kla, school_id: s.id, tweeweek: true)
		FactoryGirl.create(:kla, school_id: s.id, tweeweek: false, name: "3a")
		s.week.should == true
		s.tweeweek.should == true
	end
end