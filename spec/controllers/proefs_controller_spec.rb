require 'spec_helper'

describe ProefsController do
	describe "ingelogd als admin" do
		before :each do
			@request.env["devise.mapping"] = Devise.mappings[:lesgever]
				roleids = [FactoryGirl.create(:role, name: "admin").id]
				@lesgever = FactoryGirl.create(:lesgever, role_ids: roleids)
				@proef = FactoryGirl.create(:proef)
		      	sign_in @lesgever
		end
		it "renders show template" do
			get :show, id: @proef.id
			response.should render_template :show
		end
		it "correctly assigns proef variable in show" do
			get :show, id: @proef.id
			assigns(:proef).should eq(@proef)
		end
		it "renders new template" do
			get :new
			response.should render_template :new
		end
		it "correctly assigns proef variable in new" do
			get :new
			assigns(:proef).id.should be_nil
		end
		it "creates a new proef" do
      		expect{
        		post :create, proef: FactoryGirl.attributes_for(:proef, content: "pletsen", niveau_id: @proef.niveau.id)
      		}.to change(Proef,:count).by(1)
    	end
    	it "redirects to the niveau" do
	      	post :create, proef: FactoryGirl.attributes_for(:proef, content: "pletsen", niveau_id: @proef.niveau.id)
	      	response.should redirect_to niveau_path(@proef.niveau)
    	end
    	it "tries wrong create and renders new" do 
    		post :create, proef: FactoryGirl.attributes_for(:proef, content: nil, niveau_id: @proef.niveau.id)
    		response.should render_template :new
    	end
    	it "renders edit template" do
			get :edit, id: @proef.id
			response.should render_template :edit
			assigns(:proef).should == @proef
		end
    	it "updates correctly" do 
    		put :update, id: @proef.id, proef: FactoryGirl.attributes_for(:proef, content: "vissen")
    		@proef.reload
    		@proef.content.should eql("vissen")
    	end
    	it "tries wrong update and renders edit" do 
    		put :update, id: @proef.id, proef: FactoryGirl.attributes_for(:proef, content: nil)
    		response.should render_template :edit
    		assigns(:proef).should == @proef
    	end
    	it "deletes the proef correctly" do
    		expect{
      			delete :destroy, id: @proef.id        
    			}.to change(Proef,:count).by(-1)
    	end
    	it "redirects to niveau" do
		    delete :destroy, id: @proef.id
		    response.should redirect_to niveau_path(@proef.niveau)
  		end
  		it "passes sorteer params to action and changes position of fouts" do
  			buik = FactoryGirl.create(:proef, content: "buik", niveau_id: @proef.niveau.id)
  			fout1 = FactoryGirl.create(:fout, name: "zeer slecht", proef_id: buik.id)
  			fout2 = FactoryGirl.create(:fout, name: "matig slecht", proef_id: buik.id)
  			fout3 = FactoryGirl.create(:fout, name: "extreem slecht", proef_id: buik.id)
  			post :sorteren, fout: ["3", "1", "2"]
  			fout1.reload.position.should == 2
  			fout2.reload.position.should == 3
  			fout3.reload.position.should == 1
  		end
	end
end