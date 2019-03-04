require 'spec_helper'

describe PicturesController do
	describe "ingelogd als admin" do
		before :each do
			@request.env["devise.mapping"] = Devise.mappings[:lesgever]
				roleids = [FactoryGirl.create(:role, name: "admin").id]
				@lesgever = FactoryGirl.create(:lesgever, role_ids: roleids)
				@picture = FactoryGirl.create(:picture)
		      	sign_in @lesgever
		end
		it "creates a new picture" do
      		expect{
        		post :create, picture: FactoryGirl.attributes_for(:picture)
      		}.to change(Picture,:count).by(1)
    	end
		it "deletes the picture correctly" do
            expect{
                delete :destroy, id: @picture.id        
                }.to change(Picture,:count).by(-1)
        end
        it "redirects to singlestat afterpicture create" do
	      	post :create, picture: FactoryGirl.attributes_for(:picture)
	      	response.should redirect_to fronts_singlestat_path
    end
    	it "doesn't create a new picture if name is empty" do
      		expect{
        		post :create, picture: FactoryGirl.attributes_for(:picture, name: "")
      		}.to change(Picture,:count).by(0)
    	end
    it "should create the picture in the right way" do
      lesuur = FactoryGirl.create(:lesuur)
      klas = FactoryGirl.create(:kla)
      groen = FactoryGirl.create(:niveau, name: "groen")
      geel = FactoryGirl.create(:niveau, name: "geel")
      groep_groen = FactoryGirl.create(:groep, lesuur_id: lesuur.id, niveau_id: groen.id, lesgever_id: @lesgever.id)
      groep_geel = FactoryGirl.create(:groep, lesuur_id: lesuur.id, niveau_id: geel.id, lesgever_id: @lesgever.id)
      3.times{FactoryGirl.create(:zwemmer, groep_id: groep_groen.id, kla_id: klas.id)}
      post :create, picture: FactoryGirl.attributes_for(:picture)
      p = Picture.last
      p.niveaus.should == {1=>["groen","#FFF", 1], 2=>["geel","#FFF", 2]}
      p.details.should == {1=>[1, "4a", "wd", klas.id], 2=>[1, "4a", "wd", klas.id], 3=>[1, "4a", "wd", klas.id]}
      p.totals.should == {"categories"=>{"cat_dilb_week"=>{1=>{1=>0, 2=>0}, 2=>{1=>0, 2=>0}, 3=>{1=>0, 2=>0}, 4=>{1=>3, 2=>0}, 5=>{1=>0, 2=>0}, 6=>{1=>0, 2=>0}}, "cat_dilb_tweeweek"=>{1=>{1=>0, 2=>0}, 2=>{1=>0, 2=>0}, 3=>{1=>0, 2=>0}, 4=>{1=>0, 2=>0}, 5=>{1=>0, 2=>0}, 6=>{1=>0, 2=>0}}, "cat_nietdilb"=>{1=>{1=>0, 2=>0}, 2=>{1=>0, 2=>0}, 3=>{1=>0, 2=>0}, 4=>{1=>0, 2=>0}, 5=>{1=>0, 2=>0}, 6=>{1=>0, 2=>0}}},"schools"=>{1=>{1=>{1=>0, 2=>0}, 2=>{1=>0, 2=>0}, 3=>{1=>0, 2=>0}, 4=>{1=>3, 2=>0}, 5=>{1=>0, 2=>0}, 6=>{1=>0, 2=>0}}}}
    end
    it "should save a geel zwemmer in wit as geel in picture details" do
      lesuur = FactoryGirl.create(:lesuur)
      klas = FactoryGirl.create(:kla)
      wit = FactoryGirl.create(:niveau, name: "wit")
      groen = FactoryGirl.create(:niveau, name: "groen")
      geel = FactoryGirl.create(:niveau, name: "geel")
      groep_wit = FactoryGirl.create(:groep, lesuur_id: lesuur.id, niveau_id: wit.id, lesgever_id: @lesgever.id)
      groep_groen = FactoryGirl.create(:groep, lesuur_id: lesuur.id, niveau_id: groen.id, lesgever_id: @lesgever.id)
      groep_geel = FactoryGirl.create(:groep, lesuur_id: lesuur.id, niveau_id: geel.id, lesgever_id: @lesgever.id)
      3.times{FactoryGirl.create(:zwemmer, groep_id: groep_groen.id, kla_id: klas.id)}
      FactoryGirl.create(:zwemmer, groep_id: groep_wit.id, kla_id: klas.id, groepvlag: groep_geel.id)
      post :create, picture: FactoryGirl.attributes_for(:picture)
      p = Picture.last
      p.niveaus.should == {1=>["wit","#FFF", 1],2=>["groen","#FFF", 2], 3=>["geel","#FFF", 3]}
      p.details.should == {1=>[2, "4a", "wd", klas.id], 2=>[2, "4a", "wd", klas.id], 3=>[2, "4a", "wd", klas.id], 4=>[3, "4a", "wd", klas.id]}
      p.totals.should == {"categories"=>{"cat_dilb_week"=>{1=>{1=>0, 2=>0, 3=>0}, 2=>{1=>0, 2=>0, 3=>0}, 3=>{1=>0, 2=>0, 3=>0}, 4=>{1=>0, 2=>3, 3=>1}, 5=>{1=>0, 2=>0, 3=>0}, 6=>{1=>0, 2=>0, 3=>0}}, "cat_dilb_tweeweek"=>{1=>{1=>0, 2=>0, 3=>0}, 2=>{1=>0, 2=>0, 3=>0}, 3=>{1=>0, 2=>0, 3=>0}, 4=>{1=>0, 2=>0, 3=>0}, 5=>{1=>0, 2=>0, 3=>0}, 6=>{1=>0, 2=>0, 3=>0}}, "cat_nietdilb"=>{1=>{1=>0, 2=>0, 3=>0}, 2=>{1=>0, 2=>0, 3=>0}, 3=>{1=>0, 2=>0, 3=>0}, 4=>{1=>0, 2=>0, 3=>0}, 5=>{1=>0, 2=>0, 3=>0}, 6=>{1=>0, 2=>0, 3=>0}}},"schools"=>{1=>{1=>{1=>0, 2=>0, 3=>0}, 2=>{1=>0, 2=>0, 3=>0}, 3=>{1=>0, 2=>0, 3=>0}, 4=>{1=>0, 2=>3, 3=>1}, 5=>{1=>0, 2=>0, 3=>0}, 6=>{1=>0, 2=>0, 3=>0}}}}

    end
    it "should redirect to singlestat with correct notice after failed save" do
      post :create, picture: FactoryGirl.attributes_for(:picture, name: "")
      response.should redirect_to fronts_singlestat_path
      flash[:notice].should == "Vul een beschrijving in voor de foto."
    end
	end
end