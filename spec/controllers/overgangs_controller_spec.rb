require 'spec_helper'

describe OvergangsController do
	describe "ingelogd als admin" do
		before :each do
			@request.env["devise.mapping"] = Devise.mappings[:lesgever]
			roleids = [FactoryGirl.create(:role, name: "admin").id]
			@lesgever = FactoryGirl.create(:lesgever, role_ids: roleids)
			@zwemmer = FactoryGirl.create(:zwemmer)
			@overgang1 = FactoryGirl.create(:overgang, zwemmer_id: @zwemmer.id)
			@overgang2 = FactoryGirl.create(:overgang, van: "pipi", naar: "kaka", zwemmer_id: @zwemmer.id)
		    sign_in @lesgever
		end
		
    	it "deletes the klas correctly" do
    		@zwemmer.overgangs.size.should == 2
    		expect{
      			delete :destroy, id: @overgang1.id        
    			}.to change(Overgang,:count).by(-1)
    	end
	end
end