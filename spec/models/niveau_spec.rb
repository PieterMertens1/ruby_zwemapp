require 'spec_helper'
describe Niveau do
	it "has a valid factory" do
		FactoryGirl.build(:niveau).should be_valid
	end

	it { should validate_presence_of(:name) }
	it { should validate_presence_of(:kleurcode) }
	it { should validate_uniqueness_of(:name).with_message(/bestaat al/) }

	it "should sort proefs correctly with proefssorted" do
		n = FactoryGirl.create(:niveau)
		proef1 = FactoryGirl.create(:proef, content: "pletsen", niveau_id: n.id, position: 2)
		proef2 = FactoryGirl.create(:proef, content: "springen", niveau_id: n.id, position: 1)
		n.proefssorted == [proef2, proef1]
	end
	it "should correctly implement name change callback for zwemmer badmuts" do
		geel = FactoryGirl.create(:niveau, name: "geel", karakter: 2)
		oranje = FactoryGirl.create(:niveau, name: "oranje", karakter: 3)
		oranje_groep = FactoryGirl.create(:groep, niveau_id: oranje.id)
		z = FactoryGirl.create(:zwemmer, badmuts: "geel", groep_id: oranje_groep.id)
		geel.update_attributes(name: "zilver")
		geel.reload.name.should == "zilver"
		z.reload.badmuts.should == "zilver"
	end
end