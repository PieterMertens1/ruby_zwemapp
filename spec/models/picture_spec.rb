require 'spec_helper'

describe Picture do
  it "has a valid factory" do
	FactoryGirl.build(:picture).should be_valid
  end
  it "shouldn't save picture with empty name" do
  	FactoryGirl.build(:picture,name: "").should_not be_valid
  end

  it "saves the picture as a hash" do
  	p = FactoryGirl.create(:picture)
  	p.details[1630].should == [2, "6a"]
    p.details[1633][0].should == 4
  	p.totals["categories"]["cat_dilb_week"][2][2].should == 45
  	p.niveaus[2].should == "groen"
  end	
end
