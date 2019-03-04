require 'spec_helper'
describe Lesuur do
	it "returns a correct klassen_label" do
		lesuur = FactoryGirl.create(:lesuur)
		FactoryGirl.create(:kla, lesuur: lesuur)
		FactoryGirl.create(:kla, name: "5a", lesuur: lesuur)
		lesuur.klassen_label.should == "RC 4a-RC 5a-"
	end

	it "accepts a valid lesuur name format" do
		FactoryGirl.create(:lesuur).should be_valid
	end

	it "does not accept an invalid lesuur name format" do 
		FactoryGirl.build(:lesuur, name: "8").should_not be_valid
	end

	it "does not accept an invalid lesuur name format" do 
		FactoryGirl.build(:lesuur, name: "8uff").should_not be_valid
	end

	it { should validate_presence_of(:name) }
	it { should validate_presence_of(:dag_id) }

	it "should return correct value with sorthelper" do
		lesuur = FactoryGirl.create(:lesuur, name: "5u20")
		lesuur.sorthelper.should == 320
	end

	it "should return true if lesuur is nietdilbeeks" do
		lesuur = FactoryGirl.create(:lesuur, name: "5u20")
		klas = FactoryGirl.create(:kla, lesuur_id: lesuur.id, nietdilbeeks: true)
		lesuur.nietdilbeeks.should == true
	end

	it "should return false if lesuur is dilbeeks" do
		lesuur = FactoryGirl.create(:lesuur, name: "5u20")
		klas = FactoryGirl.create(:kla, lesuur_id: lesuur.id)
		lesuur.nietdilbeeks.should == false
	end
end