require 'spec_helper'

describe FoutsController do
	describe "ingelogd als admin" do
		before :each do
			@request.env["devise.mapping"] = Devise.mappings[:lesgever]
				roleids = [FactoryGirl.create(:role, name: "admin").id]
				@lesgever = FactoryGirl.create(:lesgever, role_ids: roleids)
				@fout = FactoryGirl.create(:fout)
		      	sign_in @lesgever
		end
		it "renders new template" do
			get :new
			response.should render_template :new
		end
		it "correctly assigns fout variable in new" do
			get :new
			assigns(:fout).id.should be_nil
		end
		it "creates a new fout" do
      		expect{
        		post :create, fout: FactoryGirl.attributes_for(:fout, name: "slecht", proef_id: @fout.proef.id)
      		}.to change(Fout,:count).by(1)
    	end
    	it "redirects to the proef" do
	      	post :create, fout: FactoryGirl.attributes_for(:fout, name: "slecht", proef_id: @fout.proef.id)
	      	response.should redirect_to proef_path(@fout.proef)
    	end
    	it "tries wrong create and renders new" do 
    		post :create, fout: FactoryGirl.attributes_for(:fout, name: nil, proef_id: @fout.proef.id)
    		response.should render_template :new
    	end
    	it "renders edit template" do
			get :edit, id: @fout.id
			response.should render_template :edit
			assigns(:fout).should == @fout
		end
    	it "updates correctly" do 
    		put :update, id: @fout.id, fout: FactoryGirl.attributes_for(:fout, name: "slecht", proef_id: @fout.proef.id)
    		@fout.reload
    		@fout.name.should eql("slecht")
    	end
    	it "tries wrong update and renders edit" do 
    		put :update, id: @fout.id, fout: FactoryGirl.attributes_for(:fout, name: nil, proef_id: @fout.proef.id)
    		response.should render_template :edit
    		assigns(:fout).should == @fout
    	end
    	it "deletes the fout correctly" do
    		expect{
      			delete :destroy, id: @fout.id        
    			}.to change(Fout,:count).by(-1)
    	end
    	it "redirects to proef" do
		    delete :destroy, id: @fout.id
		    response.should redirect_to proef_path(@fout.proef)
  		end
	end
end