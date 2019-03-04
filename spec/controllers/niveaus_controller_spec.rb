require 'spec_helper'

describe NiveausController do
	describe "ingelogd als admin" do
		before :each do
			@request.env["devise.mapping"] = Devise.mappings[:lesgever]
				roleids = [FactoryGirl.create(:role, name: "admin").id]
				@lesgever = FactoryGirl.create(:lesgever, role_ids: roleids)
				@niveau = FactoryGirl.create(:niveau)
		      	sign_in @lesgever
		end
		it "renders index template" do
			get :index
			response.should render_template :index
		end
		it "correctly assigns niveaus variable in index" do
			get :index
			assigns(:niveaus).should eq([@niveau])
		end
		it "renders show template" do
			get :show, id: @niveau
			response.should render_template :show
		end
		it "correctly assigns niveau variable in show" do
			get :show, id: @niveau
			assigns(:niveau).should eq(@niveau)
		end
		it "renders new template" do
			get :new
			response.should render_template :new
		end
		it "correctly assigns niveau variable in new" do
			get :new
			assigns(:niveau).id.should be_nil
		end
		it "creates a new niveau" do
      		expect{
        		post :create, niveau: FactoryGirl.attributes_for(:niveau, name: "geel")
      		}.to change(Niveau,:count).by(1)
    	end
    	it "redirects to the new niveau" do
	      	post :create, niveau: FactoryGirl.attributes_for(:niveau, name: "geel")
	      	response.should redirect_to Niveau.last
    	end
    	it "tries wrong create and renders new" do 
    		post :create, niveau: FactoryGirl.attributes_for(:niveau, name: nil)
    		response.should render_template :new
    	end
    	it "renders edit template" do
			get :edit, id: @niveau.id
			response.should render_template :edit
			assigns(:niveau).should == @niveau
		end
    	it "updates correctly" do 
    		put :update, id: @niveau.id, niveau: FactoryGirl.attributes_for(:niveau, name: "roze")
    		@niveau.reload
    		@niveau.name.should eql("roze")
    	end
    	it "tries wrong update and renders edit" do 
    		put :update, id: @niveau.id, niveau: FactoryGirl.attributes_for(:niveau, name: nil)
    		response.should render_template :edit
    		assigns(:niveau).should == @niveau
    	end
    	it "deletes the niveau correctly" do
    		expect{
      			delete :destroy, id: @niveau        
    			}.to change(Niveau,:count).by(-1)
    	end
    	it "redirects to index" do
		    delete :destroy, id: @niveau
		    response.should redirect_to niveaus_path
  		end
  		it "passes sorteer params to action and changes position of niveaus" do
  			geel = FactoryGirl.create(:niveau, name: "geel")
  			oranje = FactoryGirl.create(:niveau, name: "oranje")
  			post :sorteren, niveau: ["1", "3", "2"]
  			geel.reload.position.should == 3
  			oranje.reload.position.should == 2
  		end
  		it "passes sorteer params to action and changes position of proefs" do
  			buik = FactoryGirl.create(:proef, content: "buik", niveau_id: @niveau.id)
  			rug = FactoryGirl.create(:proef, content: "rug", niveau_id: @niveau.id)
  			post :sorteren, proef: ["2", "1"]
  			buik.reload.position.should == 2
  			rug.reload.position.should == 1
  		end
	end
end