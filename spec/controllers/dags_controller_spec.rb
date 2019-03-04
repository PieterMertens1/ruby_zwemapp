require 'spec_helper'

describe DagsController do
	describe "ingelogd als admin" do
		before :each do
			@request.env["devise.mapping"] = Devise.mappings[:lesgever]
				roleids = [FactoryGirl.create(:role, name: "admin").id]
				@lesgever = FactoryGirl.create(:lesgever, role_ids: roleids)
				@dag = FactoryGirl.create(:dag)
		      	sign_in @lesgever
		end
		it "renders index template" do
			get :index
			response.should render_template :index
		end
		it "correctly assigns dags variable in index" do
			get :index
			assigns(:dags).should eq([@dag])
		end
		it "renders show template" do
			get :show, id: @dag
			response.should render_template :show
		end
		it "correctly assigns dag variable in show" do
			get :show, id: @dag
			assigns(:dag).should eq(@dag)
		end
		it "renders new template" do
			get :new
			response.should render_template :new
		end
		it "correctly assigns dag variable in new" do
			get :new
			assigns(:dag).id.should be_nil
		end
		it "creates a new dag" do
      		expect{
        		post :create, dag: FactoryGirl.attributes_for(:dag, name: "dinsdag")
      		}.to change(Dag,:count).by(1)
    	end
    	it "redirects to the new dag" do
	      	post :create, dag: FactoryGirl.attributes_for(:dag, name: "dinsdag")
	      	response.should redirect_to Dag.last
    	end
    	it "tries wrong create and renders new" do 
    		post :create, dag: FactoryGirl.attributes_for(:dag, name: nil)
    		response.should render_template :new
    	end
    	it "renders edit template" do
			get :edit, id: @dag.id
			response.should render_template :edit
			assigns(:dag).should == @dag
		end
    	it "updates correctly" do 
    		put :update, id: @dag.id, dag: FactoryGirl.attributes_for(:dag, name: "woensdag")
    		@dag.reload
    		@dag.name.should eql("woensdag")
    	end
    	it "tries wrong update and renders edit" do 
    		put :update, id: @dag.id, dag: FactoryGirl.attributes_for(:dag, name: nil)
    		response.should render_template :edit
    		assigns(:dag).should == @dag
    	end
    	it "deletes the dag correctly" do
    		expect{
      			delete :destroy, id: @dag        
    			}.to change(Dag,:count).by(-1)
    	end
    	it "redirects to index" do
		    delete :destroy, id: @dag
		    response.should redirect_to dags_path
  		end
	end
end