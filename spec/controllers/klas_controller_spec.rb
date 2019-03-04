require 'spec_helper'

describe KlasController do
	describe "ingelogd als admin" do
		before :each do
			@request.env["devise.mapping"] = Devise.mappings[:lesgever]
			roleids = [FactoryGirl.create(:role, name: "admin").id]
			@lesgever = FactoryGirl.create(:lesgever, role_ids: roleids)
			@klas = FactoryGirl.create(:kla)
		    sign_in @lesgever
		end
		it "renders edit template" do
			get :edit, id: @klas.id
			response.should render_template :edit
			assigns(:kla).should == @klas
		end
		it "updates correctly" do 
    		put :update, id: @klas.id, kla: FactoryGirl.attributes_for(:kla, name: "6k")
    		@klas.reload
    		@klas.name.should eql("6k")
    	end
		it "tries wrong update and renders edit" do 
    		put :update, id: @klas.id, kla: FactoryGirl.attributes_for(:kla, name: nil)
    		response.should render_template :edit
    		assigns(:kla).should == @klas
    	end
    	it "deletes the klas correctly" do
    		expect{
      			delete :destroy, id: @klas.id        
    			}.to change(Kla,:count).by(-1)
    	end
    	it "redirects to index" do
		    delete :destroy, id: @klas.id
		    response.should redirect_to school_path(@klas.school)
  		end
	end
end