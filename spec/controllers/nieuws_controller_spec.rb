require 'spec_helper'

describe NieuwsController do
	describe "ingelogd als admin" do
		before :each do
			@request.env["devise.mapping"] = Devise.mappings[:lesgever]
				roleids = [FactoryGirl.create(:role, name: "admin").id]
				@lesgever = FactoryGirl.create(:lesgever, role_ids: roleids)
				@nieuw = FactoryGirl.create(:nieuw)
		      	sign_in @lesgever
		end
		it "renders index template" do
			get :index
			response.should render_template :index
		end
		it "correctly assigns nieuws variable in index" do
			get :index
			assigns(:nieuws).should eq([@nieuw])
		end
		it "renders new template" do
			get :new
			response.should render_template :new
		end
		it "correctly assigns nieuw variable in new" do
			get :new
			assigns(:nieuw).id.should be_nil
		end
		it "creates a new nieuw" do
      		expect{
        		post :create, nieuw: FactoryGirl.attributes_for(:nieuw, content: "blabla")
      		}.to change(Nieuw,:count).by(1)
    	end
    	it "redirects to the nieuws" do
	      	post :create, nieuw: FactoryGirl.attributes_for(:nieuw, content: "vdld")
	      	response.should redirect_to nieuws_path
    	end
    	it "tries wrong create and renders new" do 
    		post :create, nieuw: FactoryGirl.attributes_for(:nieuw, content: "")
    		response.should render_template :new
    	end
	end
end