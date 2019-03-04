require 'spec_helper'

describe SchoolsController do
	describe "ingelogd als admin" do
		before :each do
			@request.env["devise.mapping"] = Devise.mappings[:lesgever]
				roleids = [FactoryGirl.create(:role, name: "admin").id]
				@lesgever = FactoryGirl.create(:lesgever, role_ids: roleids)
				@school = FactoryGirl.create(:school)
		      	sign_in @lesgever
		end
		it "renders edit template" do
			get :edit, id: @school.id
			response.should render_template :edit
			assigns(:school).should == @school
		end
    	it "updates correctly" do 
    		put :update, id: @school.id, school: FactoryGirl.attributes_for(:school, name: "Regina Caeli")
    		@school.reload
    		@school.name.should eql("Regina Caeli")
    	end
        it "should correctly order klassen of school: 3ka before 1a" do
            kleuterklas = FactoryGirl.create(:kla, school: @school, name: "3ka")
            eerste_leerjaar = FactoryGirl.create(:kla, school: @school, name: "1a")
            get :show, id: @school.id
            assigns(:klassen).should == [kleuterklas, eerste_leerjaar] 
        end
    	it "tries wrong update and renders edit" do 
    		put :update, id: @school.id, school: FactoryGirl.attributes_for(:school, name: nil)
    		response.should render_template :edit
    		assigns(:school).should == @school
    	end
    	it "deletes the school correctly" do
    		expect{
      			delete :destroy, id: @school.id        
    			}.to change(School,:count).by(-1)
    	end
    	it "redirects to index" do
		    delete :destroy, id: @school.id
		    response.should redirect_to schools_path
  		end
        it "for index: should separate niet-dilbeekse and dilbeekse scholen as instance variables" do
            school2 = FactoryGirl.create(:school, name: "didi's school")
            klas = FactoryGirl.create(:kla, school: school2, nietdilbeeks: true)
            get :index
            assigns(:dilbeekse_scholen).should == [@school]
            assigns(:niet_dilbeekse_scholen).should == [school2]
        end
	end
end