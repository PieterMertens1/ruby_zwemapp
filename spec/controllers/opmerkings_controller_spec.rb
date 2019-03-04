require 'spec_helper'

describe OpmerkingsController do
describe "ingelogd als admin" do
    before :each do
      @request.env["devise.mapping"] = Devise.mappings[:lesgever]
        roleids = [FactoryGirl.create(:role, name: "admin").id]
        @lesgever = FactoryGirl.create(:lesgever, role_ids: roleids)
        @opmerking = FactoryGirl.create(:opmerking)
        sign_in @lesgever
    end
    it "renders index template" do
      get :index
      response.should render_template :index
    end
    it "correctly assigns opmerkings variable in index" do
      get :index
      assigns(:opmerkings).should eq([@opmerking])
    end
    it "renders new template" do
      get :new
      response.should render_template :new
    end
    it "correctly assigns opmerking variable in new" do
      get :new
      assigns(:opmerking).id.should be_nil
    end
    it "creates a new opmerking" do
          expect{
            post :create, opmerking: FactoryGirl.attributes_for(:opmerking, name: "kan beter!")
          }.to change(Opmerking,:count).by(1)
      end
      it "redirects to the new opmerking" do
          post :create, opmerking: FactoryGirl.attributes_for(:opmerking, name: "niet goed")
          response.should redirect_to opmerkings_path
      end
      it "tries wrong create and renders new" do 
        post :create, opmerking: FactoryGirl.attributes_for(:opmerking, name: nil)
        response.should render_template :new
      end
      it "renders edit template" do
      get :edit, id: @opmerking.id
      response.should render_template :edit
      assigns(:opmerking).should == @opmerking
    end
      it "updates correctly" do 
        put :update, id: @opmerking.id, opmerking: FactoryGirl.attributes_for(:opmerking, name: "uitstekend")
        @opmerking.reload
        @opmerking.name.should eql("uitstekend")
      end
      it "tries wrong update and renders edit" do 
        put :update, id: @opmerking.id, opmerking: FactoryGirl.attributes_for(:opmerking, name: nil)
        response.should render_template :edit
        assigns(:opmerking).should == @opmerking
      end
      it "deletes the opmerking correctly" do
        expect{
            delete :destroy, id: @opmerking        
          }.to change(Opmerking,:count).by(-1)
      end
      it "redirects to index" do
        delete :destroy, id: @opmerking
        response.should redirect_to opmerkings_path
      end
  end
end
