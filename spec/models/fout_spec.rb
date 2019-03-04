require 'spec_helper'
describe Fout do
	it "has a valid factory" do
		FactoryGirl.build(:fout).should be_valid
	end

	it "is invalid without name" do
		FactoryGirl.build(:fout, :name => nil).should_not be_valid
	end

	it "is invalid without groep_id" do
		FactoryGirl.build(:fout, proef_id: nil).should_not be_valid
	end

	it "is invalid with same name on same proef_id" do
		proef = FactoryGirl.create(:proef)
		FactoryGirl.create(:fout, name: "slecht", proef_id: proef.id)
		FactoryGirl.build(:fout, name: "slecht", proef_id: proef.id).should_not be_valid
	end

	it "is valid with same name on different proef_id" do
		niveau = FactoryGirl.create(:niveau)
		proef1 = FactoryGirl.create(:proef, content: "breedte schoolslag", niveau_id: niveau.id)
		proef2 = FactoryGirl.create(:proef, content: "breedte crawl", niveau_id: niveau.id)
		FactoryGirl.create(:fout, name: "slecht", proef_id: proef1.id)
		FactoryGirl.build(:fout, name: "slecht", proef_id: proef2.id).should be_valid
	end
end