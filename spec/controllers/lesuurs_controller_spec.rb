require 'spec_helper'

describe LesuursController do
	describe "ingelogd als admin" do
		before :each do
			@request.env["devise.mapping"] = Devise.mappings[:lesgever]
				roleids = [FactoryGirl.create(:role, name: "admin").id]
				@lesgever = FactoryGirl.create(:lesgever, role_ids: roleids)
				@lesuur = FactoryGirl.create(:lesuur)
		      	sign_in @lesgever
		end
		it "renders index template" do
			get :index
			response.should render_template :index
		end
		it "correctly assigns lesuurs variable in index" do
			get :index
			assigns(:lesuurs).should eq([@lesuur])
		end
		it "renders show template" do
			get :show, id: @lesuur.id
			response.should render_template :show
		end
		it "correctly assigns lesuur variable in show" do
			get :show, id: @lesuur.id
			assigns(:lesuur).should eq(@lesuur)
		end
		it "renders new template" do
			get :new
			response.should render_template :new
		end
		it "correctly assigns lesuur variable in new" do
			get :new
			assigns(:lesuur).id.should be_nil
		end
		it "creates a new lesuur" do
      		expect{
        		post :create, lesuur: FactoryGirl.attributes_for(:lesuur, name: "13u20", dag_id: @lesuur.dag.id)
      		}.to change(Lesuur,:count).by(1)
    	end
    	it "redirects to the dag" do
	      	post :create, lesuur: FactoryGirl.attributes_for(:lesuur, name: "15u40", dag_id: @lesuur.dag.id)
	      	response.should redirect_to dags_path
    	end
    	it "tries wrong create and renders new" do 
    		post :create, lesuur: FactoryGirl.attributes_for(:lesuur, name: "44", dag_id: @lesuur.dag.id)
    		response.should render_template :new
    	end
    	it "renders edit template" do
			get :edit, id: @lesuur.id
			response.should render_template :edit
			assigns(:lesuur).should == @lesuur
		end
    	it "updates correctly" do 
    		put :update, id: @lesuur.id, lesuur: FactoryGirl.attributes_for(:lesuur, name: "66u55")
    		@lesuur.reload
    		@lesuur.name.should eql("66u55")
    	end
    	it "tries wrong update and renders edit" do 
    		put :update, id: @lesuur.id, lesuur: FactoryGirl.attributes_for(:lesuur, name: "44")
    		response.should render_template :edit
    		assigns(:lesuur).should == @lesuur
    	end
    	it "deletes the lesuur correctly" do
    		expect{
      			delete :destroy, id: @lesuur.id        
    			}.to change(Lesuur,:count).by(-1)
    	end
    	it "redirects to dags" do
		    delete :destroy, id: @lesuur.id
		    response.should redirect_to dags_path
  		end
	end
end