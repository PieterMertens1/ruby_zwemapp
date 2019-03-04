require 'spec_helper'
describe Proef do
	it "has a valid factory" do
		FactoryGirl.build(:proef).should be_valid
	end

	it { should validate_presence_of(:content) }
	it { should validate_presence_of(:niveau_id) }
	it { should validate_presence_of(:scoretype) }
	it { should validate_uniqueness_of(:content).scoped_to(:niveau_id).with_message(/bestaat al/) } 

	it "is invalid without content" do
		FactoryGirl.build(:proef, :content => nil).should_not be_valid
	end

	it "is invalid without groep_id" do
		FactoryGirl.build(:proef, niveau_id: nil).should_not be_valid
	end

	it "is invalid with same content on same niveau_id" do
		niveau = FactoryGirl.create(:niveau)
		FactoryGirl.create(:proef, content: "didi", niveau_id: niveau.id)
		FactoryGirl.build(:proef, content: "didi", niveau_id: niveau.id).should_not be_valid
	end
	it "is valid with same content on same niveau_id, but different niet-dilbeeks" do
		niveau = FactoryGirl.create(:niveau)
		FactoryGirl.create(:proef, content: "didi", niveau_id: niveau.id)
		FactoryGirl.build(:proef, content: "didi", niveau_id: niveau.id, nietdilbeeks: true).should be_valid
	end
	it "is valid with same content on different niveau_id" do
		niveau1 = FactoryGirl.create(:niveau, name: "wit")
		niveau2 = FactoryGirl.create(:niveau, name: "groen")
		FactoryGirl.create(:proef, content: "didi", niveau_id: niveau1.id)
		FactoryGirl.build(:proef, content: "didi", niveau_id: niveau2.id).should be_valid
	end
end