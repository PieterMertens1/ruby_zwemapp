require 'spec_helper'

describe RapportsController do
	describe "ingelogd als admin" do
		before :each do
			@request.env["devise.mapping"] = Devise.mappings[:lesgever]
				roleids = [FactoryGirl.create(:role, name: "admin").id]
				@lesgever = FactoryGirl.create(:lesgever, role_ids: roleids)
				@klas = FactoryGirl.create(:kla)
				@niveau = FactoryGirl.create(:niveau)
				@groep = FactoryGirl.create(:groep, niveau_id: @niveau.id)
				@zwemmer = FactoryGirl.create(:zwemmer, kla_id: @klas.id, groep_id: @groep.id)
				@rapport = FactoryGirl.create(:rapport, zwemmer_id: @zwemmer.id)
		      	sign_in @lesgever
		end
		it "renders new template" do
			zwemmer = FactoryGirl.create(:zwemmer, kla_id: @klas.id, groep_id: @groep.id)
			get :new, zwemmerid: zwemmer.id, niveau_id: @niveau.id
			response.should render_template :new
		end
		it "correctly assigns rapport variable in new" do
			zwemmer = FactoryGirl.create(:zwemmer, kla_id: @klas.id, groep_id: @groep.id)
			proef = FactoryGirl.create(:proef, niveau_id: zwemmer.groep.niveau.id)
			get :new, zwemmerid: zwemmer.id, niveau_id: @niveau.id
			assigns(:rapport).id.should be_nil
			assigns(:zwemmer).should == zwemmer
            assigns(:proefs).should == [proef]
		end
		it "should correctly load edit page" do
            proef = FactoryGirl.create(:proef, niveau_id: @rapport.zwemmer.groep.niveau.id)
            @rapport.niveau.should == "groen"
            @rapport.zwemmer.groep.niveau.name.should == "groen"
            get :edit, id: @rapport.id
            response.should render_template :edit
            assigns(:rapport).should == @rapport
            assigns(:zwemmer).should == @rapport.zwemmer
            assigns(:proefs).should == [proef]
        end
        it "deletes the rapport correctly" do
    		expect{
      			delete :destroy, id: @rapport.id        
    			}.to change(Rapport,:count).by(-1)
    	end
    	it "redirects to dags" do
		    delete :destroy, id: @rapport.id
		    response.should redirect_to zwemmer_path(@rapport.zwemmer)
  		end
	end
end