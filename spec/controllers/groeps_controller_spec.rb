require 'spec_helper'
require 'data'
include Datums

describe GroepsController do
	it "returns loginpage when asking for index, not logged in" do
		get :index
		response.should redirect_to new_lesgever_session_path
	end
	describe "ingelogd als admin" do
			
		before :each do
			@request.env["devise.mapping"] = Devise.mappings[:lesgever]
				roleids = [FactoryGirl.create(:role, name: "admin").id]
				@lesgever = FactoryGirl.create(:lesgever, role_ids: roleids)
				@groep = FactoryGirl.create(:groep)
		      	sign_in @lesgever
		end
		it "correctly assigns dags variable in index" do
			get :index
			assigns(:dags).should eq([@groep.lesuur.dag])
		end
		it "correctly sets an alert flash in index, when there is a groep without lesgever" do
			groep_zonder_lesgever = FactoryGirl.create(:groep, lesgever: nil, niveau: @groep.niveau, lesuur: @groep.lesuur)
			get :index
			flash[:alert].should == ["Er is een <a href='/groeps/#{groep_zonder_lesgever.id}'>groep</a> zonder lesgever."]
		end
		it "correctly assigns niveaus variable in index" do
			get :index
			assigns(:niveaus).should eq([@groep.niveau])
		end
		it "renders the :index view" do
    		get :index
    		response.should render_template :index
  		end
		it "tries wrong update and renders edit" do 
	    	put :update, id: @groep.id, groep: FactoryGirl.attributes_for(:groep, niveau_id: nil)
	    	response.should render_template :edit
	    	assigns(:groep).should == @groep
	    end
	    it "deletes the groep correctly" do
    		expect{
      			delete :destroy, id: @groep.id        
    			}.to change(Groep,:count).by(-1)
    	end
    	it "redirects to groeps path of correct day: maandag" do
		    Timecop.freeze(Date.parse("29-09-2014")) do 
		    	delete :destroy, id: @groep.id
		    	response.should redirect_to "#{root_path}groeps?dag=1"
		    end
  		end
  		it "redirects to groeps path of correct day: zaterdag => maandag" do
		    Timecop.freeze(Date.parse("28-09-2014")) do 
		    	delete :destroy, id: @groep.id
		    	response.should redirect_to "#{root_path}groeps?dag=1"
		    end
  		end
  		it "creates a new witgroep in change action if no witgroep is found when zwemmers are sent to wit from groepshow" do
  			niveau_wit = FactoryGirl.create(:niveau, name: "wit", kleurcode: "#f5f5f5")
  			zwemmer1 = FactoryGirl.create(:zwemmer, name: "didi", groep_id: @groep.id)
  			zwemmer2 = FactoryGirl.create(:zwemmer, name: "pipi", groep_id: @groep.id)
  			zwemmer3 = FactoryGirl.create(:zwemmer, name: "kaka", groep_id: @groep.id)
  			put :change, zwemmer_ids: [zwemmer1.id, zwemmer3.id], groepid: @groep.id, wit: "Stuur naar wit"
  			Groep.count.should == 2
  			zwemmer1.reload.groep.niveau.name.should == "wit"
  			zwemmer3.reload.groep.niveau.name.should == "wit"
  			Groep.last.niveau.name.should == "wit"
  		end
  		it "doesn't delete the groep when it has zwemmers for non-wit groep" do
  			zwemmer1 = FactoryGirl.create(:zwemmer, name: "didi", groep_id: @groep.id)
  			zwemmer2 = FactoryGirl.create(:zwemmer, name: "pipi", groep_id: @groep.id)
    		expect{
      			delete :destroy, id: @groep.id        
    		}.to_not change(Groep,:count)
    	end
    	it "returns the correct vakantie-dates" do 
    		vakanties = get_vakanties(2014, 2)
    		vakanties.size.should == 43
    		readable_vak = []
			vakanties.each {|k,v| readable_vak.push [k.strftime("%d/%m/%Y"), v]}
			readable_vak.should == [["07/10/2013", "jaarmarkt"],
									["28/10/2013", "herfstvakantie"], ["29/10/2013", "herfstvakantie"], 
									["30/10/2013", "herfstvakantie"], ["31/10/2013", "herfstvakantie"], 
									["01/11/2013", "allerheiligen"], ["02/11/2013", "allerzielen"], 
									["11/11/2013", "wapenstilstand"], ["23/12/2013", "kerstvakantie"], 
									["24/12/2013", "kerstvakantie"], ["25/12/2013", "kerstvakantie"], 
									["26/12/2013", "kerstvakantie"], ["27/12/2013", "kerstvakantie"],
									["28/12/2013", "kerstvakantie"], ["29/12/2013", "kerstvakantie"], 
									["30/12/2013","kerstvakantie"], ["31/12/2013", "kerstvakantie"], 
									["01/01/2014", "kerstvakantie"], ["02/01/2014", "kerstvakantie"], 
									["03/01/2014", "kerstvakantie"], ["03/03/2014", "krokusvakantie"], 
									["04/03/2014", "krokusvakantie"], ["05/03/2014", "krokusvakantie"], 
									["06/03/2014", "krokusvakantie"], ["07/03/2014", "krokusvakantie"],
									["07/04/2014", "paasvakantie"], ["08/04/2014", "paasvakantie"], 
									["09/04/2014","paasvakantie"], ["10/04/2014", "paasvakantie"], 
									["11/04/2014", "paasvakantie"],["12/04/2014", "paasvakantie"], 
									["13/04/2014", "paasvakantie"], ["14/04/2014","paasvakantie"], 
									["15/04/2014", "paasvakantie"], ["16/04/2014", "paasvakantie"],
									["17/04/2014", "paasvakantie"], ["18/04/2014", "paasvakantie"], 
									["21/04/2014","paasmaandag"], ["01/05/2014", "feest vd arbeid"], 
									["29/05/2014", "olh hemelvaart"], ["30/05/2014", "olh hemelvaart"], 
									["08/06/2014", "pinksteren"], ["09/06/2014", "pinkstermaandag"]]
			vakanties = get_vakanties(2014, 8)
    		vakanties.size.should == 43
    		readable_vak = []
			vakanties.each {|k,v| readable_vak.push [k.strftime("%d/%m/%Y"), v]}
			readable_vak.should == [["06/10/2014", "jaarmarkt"], 
									["27/10/2014", "herfstvakantie"], ["28/10/2014", "herfstvakantie"], 
									["29/10/2014", "herfstvakantie"], ["30/10/2014", "herfstvakantie"],
									["31/10/2014", "herfstvakantie"], ["01/11/2014", "allerheiligen"], 
									["02/11/2014", "allerzielen"], ["11/11/2014", "wapenstilstand"], 
									["22/12/2014", "kerstvakantie"], ["23/12/2014", "kerstvakantie"], 
									["24/12/2014", "kerstvakantie"], ["25/12/2014", "kerstvakantie"],
									["26/12/2014", "kerstvakantie"], ["27/12/2014", "kerstvakantie"], 
									["28/12/2014", "kerstvakantie"], ["29/12/2014", "kerstvakantie"], 
									["30/12/2014", "kerstvakantie"], ["31/12/2014", "kerstvakantie"], 
									["01/01/2015", "kerstvakantie"], ["02/01/2015", "kerstvakantie"], 
									["16/02/2015", "krokusvakantie"], ["17/02/2015", "krokusvakantie"], 
									["18/02/2015", "krokusvakantie"], ["19/02/2015", "krokusvakantie"],
									["20/02/2015", "krokusvakantie"], ["06/04/2015", "paasmaandag"], 
									["07/04/2015","paasvakantie"], ["08/04/2015", "paasvakantie"], 
									["09/04/2015", "paasvakantie"], ["10/04/2015", "paasvakantie"], 
									["11/04/2015", "paasvakantie"], ["12/04/2015","paasvakantie"], 
									["13/04/2015", "paasvakantie"], ["14/04/2015", "paasvakantie"], 
									["15/04/2015", "paasvakantie"], ["16/04/2015", "paasvakantie"], 
									["17/04/2015","paasvakantie"], ["01/05/2015", "feest vd arbeid"], 
									["14/05/2015", "olh hemelvaart"], ["15/05/2015", "olh hemelvaart"], 
									["24/05/2015", "pinksteren"], ["25/05/2015", "pinkstermaandag"]]
    	end
	end
end