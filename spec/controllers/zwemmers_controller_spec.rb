require 'spec_helper'

describe ZwemmersController do
	describe "ingelogd als admin" do
		before :each do
			@request.env["devise.mapping"] = Devise.mappings[:lesgever]
				roleids = [FactoryGirl.create(:role, name: "admin").id]
				@lesgever = FactoryGirl.create(:lesgever, role_ids: roleids)
				@zwemmer = FactoryGirl.create(:zwemmer, importvlag: false)
		      	sign_in @lesgever
		end
		it "correctly renders index with import param" do
			zwemmers = Array.new
			school = FactoryGirl.create(:school, name: "Babel")
			klas= FactoryGirl.create(:kla, name: "3a", school: school)
			klas2 = FactoryGirl.create(:kla, name: "4a", school: school)
			zwemmers[0] = FactoryGirl.create(:zwemmer, name: "diederik", importvlag: false, groep_id: @zwemmer.groep.id, kla: klas2)
			zwemmers[1] = FactoryGirl.create(:zwemmer, name: "pipi", importvlag: true, groep_id: @zwemmer.groep.id)
			zwemmers[2] = FactoryGirl.create(:zwemmer, name: "kaka", importvlag: false, groep_id: @zwemmer.groep.id, kla: klas)
			get :index, import: true
			response.should render_template :index
			assigns(:zwemmers).should == [zwemmers[2],zwemmers[0],@zwemmer]
		end
		it "correctly gets index with import param as importlijst pdf" do
			zwemmers = Array.new
			zwemmers[0] = FactoryGirl.create(:zwemmer, name: "diederik", importvlag: false, groep_id: @zwemmer.groep.id)
			zwemmers[1] = FactoryGirl.create(:zwemmer, name: "pipi", importvlag: true, groep_id: @zwemmer.groep.id)
			zwemmers[2] = FactoryGirl.create(:zwemmer, name: "kaka", importvlag: false, groep_id: @zwemmer.groep.id)
			get :index, format: "pdf", import: true
			response.code.should == "200"
		end
		it "correctly renders index with search param" do
			zwemmers = Array.new
			zwemmers[0] = FactoryGirl.create(:zwemmer, name: "diederik", importvlag: false, groep_id: @zwemmer.groep.id)
			zwemmers[1] = FactoryGirl.create(:zwemmer, name: "pipikaka", importvlag: true, groep_id: @zwemmer.groep.id)
			zwemmers[2] = FactoryGirl.create(:zwemmer, name: "kaka", importvlag: false, groep_id: @zwemmer.groep.id)
			get :index, search: "kaka"
			response.should render_template :index
			assigns(:zwemmers).should == [zwemmers[2], zwemmers[1]]
		end
		it "renders show template" do
			get :show, id: @zwemmer.id
			response.should render_template :show
		end
		it "correctly assigns zwemmer variable in show" do
			get :show, id: @zwemmer.id
			assigns(:zwemmer).should eq(@zwemmer)
		end
		it "renders edit template" do
			get :edit, id: @zwemmer.id
			response.should render_template :edit
			assigns(:zwemmer).should == @zwemmer
		end
    	it "updates correctly" do 
    		put :update, id: @zwemmer.id, zwemmer: FactoryGirl.attributes_for(:zwemmer, name: "didi", groep_id: @zwemmer.groep.id, kla_id: @zwemmer.kla.id)
    		response.should redirect_to @zwemmer
    		@zwemmer.reload
    		@zwemmer.name.should eql("DIDI")
    	end
    	it "tries wrong update and renders edit" do 
    		put :update, id: @zwemmer.id, zwemmer: FactoryGirl.attributes_for(:zwemmer, name: nil, groep_id: @zwemmer.groep.id, kla_id: @zwemmer.kla.id)
    		response.should render_template :edit
    		assigns(:zwemmer).should == @zwemmer
    	end
    	it "deletes the zwemmer correctly" do
    		expect{
      			delete :destroy, id: @zwemmer.id        
    			}.to change(Zwemmer,:count).by(-1)
    	end
    	it "redirects to index" do
		    delete :destroy, id: @zwemmer.id
		    response.should redirect_to groep_path(@zwemmer.groep)
  		end
  		it "should massdelete zwemmers correctly" do
  			zwemmers = Array.new
			zwemmers[0] = FactoryGirl.create(:zwemmer, name: "diederik", importvlag: false, groep_id: @zwemmer.groep.id)
			zwemmers[1] = FactoryGirl.create(:zwemmer, name: "pipi", importvlag: true, groep_id: @zwemmer.groep.id)
			zwemmers[2] = FactoryGirl.create(:zwemmer, name: "kaka", importvlag: false, groep_id: @zwemmer.groep.id)
  			put :massdelete, zwemmer_ids: [@zwemmer.id, zwemmers[1].id]
  			response.should redirect_to zwemmers_path(import: true)
  			Zwemmer.count.should == 2
  		end
  		it "should handle massdirect correctly without zwemmerids passed" do
  			put :massdelete
  			response.should redirect_to zwemmers_path(import: true)
  		end
	end
end