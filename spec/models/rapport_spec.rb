require 'spec_helper'
describe Rapport do
	it "has a valid factory" do
		FactoryGirl.build(:rapport).should be_valid
	end

	it { should have_many(:resultaats).dependent(:destroy) }
	it "should upcase extra before saving it" do
		rapport = FactoryGirl.create(:rapport, extra: "pipi.")
		rapport.reload.extra.should == "Pipi."
	end
	it "should put a . at the end of extra if it doesn't have one already" do
		rapport = FactoryGirl.create(:rapport, extra: "pipi")
		rapport.reload.extra.should == "Pipi."
	end
	it "doesn't put a . in extra if extra is empty" do
		rapport = FactoryGirl.create(:rapport, extra: "")
		rapport.reload.extra.should == ""
	end
	it "doesn't put a . in extra if extra ends with another mark, like !,?" do
		rapport = FactoryGirl.create(:rapport, extra: "pipi!")
		rapport.reload.extra.should == "Pipi!"
	end
	it "should only touch first letter when capitalizing" do
		rapport = FactoryGirl.create(:rapport, extra: "abc Emilie")
		rapport.reload.extra.should == "Abc Emilie."
	end
	it "should correctly calculate total fout count for rapport" do
		rapport = FactoryGirl.create(:rapport, extra: "abc Emilie")
		niveau = FactoryGirl.create(:niveau, name: "geel")
		proef1 = FactoryGirl.create(:proef, content: "breedte schoolslag", niveau_id: niveau.id)
		proef2 = FactoryGirl.create(:proef, content: "breedte crawl", niveau_id: niveau.id)
		res1 = FactoryGirl.create(:resultaat, name: "breedte schoolslag", rapport_id: rapport.id)
		res2 = FactoryGirl.create(:resultaat, name: "breedte crawl", rapport_id: rapport.id)
		fout1 = FactoryGirl.create(:fout, name: "slechte schoolslag", proef_id: proef1.id)
		fout2 = FactoryGirl.create(:fout, name: "goede schoolslag", proef_id: proef1.id)
		fout3 = FactoryGirl.create(:fout, name: "slechte crawl", proef_id: proef2.id)
		fout4 = FactoryGirl.create(:fout, name: "goede crawl", proef_id: proef2.id)
		fw1 = FactoryGirl.create(:foutwijzing, resultaat_id: res1.id, fout_id: fout1.id)
		fw2 = FactoryGirl.create(:foutwijzing, resultaat_id: res1.id, fout_id: fout2.id)
		fw3 = FactoryGirl.create(:foutwijzing, resultaat_id: res2.id, fout_id: fout3.id)
		rapport.reload.fout_count.should == 3
	end
end