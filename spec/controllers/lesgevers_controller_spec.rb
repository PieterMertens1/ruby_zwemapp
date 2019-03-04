require 'spec_helper'

describe LesgeversController do
	it "logs in correct" do
		@request.env["devise.mapping"] = Devise.mappings[:lesgever]
		lesgever = FactoryGirl.create(:lesgever)
      	sign_in lesgever
		subject.current_lesgever.should_not be_nil
	end
	describe "ingelogd als master" do
		before :each do
			@request.env["devise.mapping"] = Devise.mappings[:lesgever]
			roleids = [FactoryGirl.create(:role, name: "master").id]
			@lesgever = FactoryGirl.create(:lesgever, role_ids: roleids)
			@groep = FactoryGirl.create(:groep, lesgever: @lesgever)
	      	sign_in @lesgever
		end
		it "redirects to root when trying index" do
			get :index
			response.should redirect_to root_path
		end
	end
	describe "ingelogd als admin" do
		before :each do
			@request.env["devise.mapping"] = Devise.mappings[:lesgever]
			@roleids = [FactoryGirl.create(:role).id]
			@lesgever = FactoryGirl.create(:lesgever, role_ids: @roleids)
			@groep = FactoryGirl.create(:groep, lesgever: @lesgever)
	      	sign_in @lesgever
		end
		it "renders index template" do
			get :index
			response.should render_template :index
		end
		it "correctly assigns lesgevers variable in index" do
			get :index
			assigns(:lesgevers).should eq([@lesgever])
		end
		it "renders show template" do
			get :show, id: @lesgever.id
			response.should render_template :show
		end
		it "correctly assigns lesgever variable in show" do
			get :show, id: @lesgever.id
			assigns(:lesgever).should eq(@lesgever)
		end
		it "renders new template" do
			get :new
			response.should render_template :new
		end
		it "correctly assigns lesgever variable in new" do
			get :new
			assigns(:lesgever).id.should be_nil
		end
		it "creates a new lesgever" do
      		expect{
        		post :create, lesgever: FactoryGirl.attributes_for(:lesgever, role_ids: @roleids)
      		}.to change(Lesgever,:count).by(1)
    	end
    	it "does not save new lesgever with wrong attributes" do
    		expect{
        		post :create, lesgever: FactoryGirl.attributes_for(:lesgever, name: nil, role_ids: @roleids)
      		}.to_not change(Lesgever,:count)
    	end
    	it "redirects to the new lesgever" do
	      	post :create, lesgever: FactoryGirl.attributes_for(:lesgever, role_ids: @roleids)
	      	response.should redirect_to Lesgever.last
    	end
    	it "renders edit template" do
			get :edit, id: @lesgever.id
			response.should render_template :edit
			assigns(:lesgever).should == @lesgever
		end
    	it "updates correctly" do 
    		put :update, id: @lesgever.id, lesgever: FactoryGirl.attributes_for(:lesgever, name: "gigi")
    		@lesgever.reload
    		@lesgever.name.should eql("gigi")
    	end
    	it "tries wrong update and renders edit" do 
    		put :update, id: @lesgever.id, lesgever: FactoryGirl.attributes_for(:lesgever, name: nil)
    		response.should render_template :edit
    		assigns(:lesgever).should == @lesgever
    	end
    	it "deletes the lesgever correctly" do
    		expect{
      			delete :destroy, id: @lesgever.id        
    		}.to change(Lesgever,:count).by(-1)
    	end
	end
end