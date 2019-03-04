require 'spec_helper'
describe Foutwijzing do
	it "has a valid factory" do
		rapport = FactoryGirl.create(:rapport, extra: "abc Emilie")
		niveau = FactoryGirl.create(:niveau, name: "geel")
		proef1 = FactoryGirl.create(:proef, content: "breedte schoolslag", niveau_id: niveau.id)
		res1 = FactoryGirl.create(:resultaat, name: "breedte schoolslag", rapport_id: rapport.id)
		fout1 = FactoryGirl.create(:fout, name: "slechte schoolslag", proef_id: proef1.id)
		FactoryGirl.build(:foutwijzing, resultaat_id: res1.id, fout_id: fout1.id).should be_valid
	end

end