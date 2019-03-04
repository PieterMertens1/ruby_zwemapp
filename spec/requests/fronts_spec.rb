# encoding: utf-8
require 'spec_helper'
#require "selenium-webdriver"

rapport_niveaus = "wit:groen:geel:oranje:rood:blauw"
describe "Requests" do
	describe "not logged in" do
		it "correctly loads login page" do
			visit root_path
			page.should have_content "Wachtwoord"
		end

		it "correctly reloads login page after invalid loginattempt" do
			visit root_path
			fill_in 'lesgever[name]', with: "diederik"
			fill_in 'lesgever[password]', with: "steekvoet"
			click_on "Inloggen"
			page.should have_content "Wachtwoord"
		end
	end
	describe "seeded" do
		before :all do
			# http://stackoverflow.com/questions/1574797/how-to-load-dbseed-data-into-test-database-automatically
			load "#{Rails.root}/db/seeds.rb"
		end
		it "correctly loads login page" do
			visit root_path
			page.should have_content "Wachtwoord"
		end
		describe "logged in" do
			before :each do
				visit root_path
				fill_in 'lesgever[name]', with: "diederik"
				fill_in 'lesgever[password]', with: "steekvoet"
				click_on "Inloggen"
			end
			it "should correctly load individual dag pages" do
				click_on "Woensdag"
				page.status_code.should == 200
				page.should have_content "9u35"
				page.should_not have_content "8u40"
			end
			it "should correctly load nieuws page" do
				visit nieuws_path
				page.status_code.should == 200
				page.should have_link "Nieuw"
				page.should have_content "Extra commentaar per zwemmer kan toegevoegd worden, zwemmer krijgt (*) achter naam."
			end
			it "should correctly save new nieuws" do
				visit nieuws_path
				all('a').select {|elt| elt.text == "Nieuw" }.first.click
				page.status_code.should == 200
				select "goed", from: "nieuw[soort]"
				fill_in "nieuw[content]", with: "nieuwe toevoeging"
				click_on "Bewaar"
				Nieuw.last.content.should == "nieuwe toevoeging"
				page.should have_content "nieuwe toevoeging"
			end
			it "should correctly load groepsoverzicht pdf" do
				visit groeps_path 
				click_on "Groepsoverzicht"
				page.status_code.should == 200
			end
			it "should return 200 code when opening excel file in school show" do
				school = School.first
				visit school_path(school)
				click_on "Overzicht niveaus"
				page.status_code.should == 200
			end

			it "should correctly save nieuwe fout" do
				proef = Proef.find(15)
				n_fouts = proef.fouts.size
				visit proef_path(proef.id)
				click_on "Nieuwe fout"
				page.should have_content proef.content
				fill_in "fout[name]", with: "naar de lichtjes kijken"
				click_on "Bewaar"
				proef.fouts.reload.size.should == (n_fouts+1)
			end
			it "should correctly edit fout" do
				fout = Fout.find(10)
				visit edit_fout_path(fout.id)
				fill_in "fout[name]", with: "pipi"
				click_on "Bewaar"
				fout.reload.name.should == "pipi"
			end
			it "should correctly show groepsomvang in groepsshow" do
				#for 2-wek lesuur
				klas = Kla.where(tweeweek: true).first
				groep = Groep.find(klas.zwemmers.first.groep.id)
				visit groep_path(groep)
				groep.omvang.each do |o|
					page.should have_content ": " + o.to_s
				end
			end
			it "should correctly return 200 for aanwezigheidslijst-pdf's of tweeweek groep" do
				#2-week-klas: broeders 5b
				klas = Kla.find(86)
				klas.school.name.should == "Broeders"
				klas.name.should == "5b"
				groep = klas.zwemmers.first.groep
				visit groep_path(groep)
				page.should have_link "Aanwezigheidslijst (volledig)"
				page.should have_link "Aanwezigheidslijst (wekelijks)"
				page.should have_link "Aanwezigheidslijst (week 1 + wekelijks)"
				page.should have_link "Aanwezigheidslijst (week 2 + wekelijks)"
				page.should have_link "Aanwezigheidslijst (week 1)"
				page.should have_link "Aanwezigheidslijst (week 2)"
				#all('a').select {|elt| elt.text == "Aanwezigheidslijst" }.first.click
				#page.status_code.should == 200
				visit groep_path(groep)
				click_on "Aanwezigheidslijst (volledig)"
				page.status_code.should == 200
				visit groep_path(groep)
				click_on "Aanwezigheidslijst (wekelijks)"
				page.status_code.should == 200
				visit groep_path(groep)
				click_on "Aanwezigheidslijst (week 1 + wekelijks)"
				page.status_code.should == 200
				visit groep_path(groep)
				click_on "Aanwezigheidslijst (week 2 + wekelijks)"
				page.status_code.should == 200
				visit groep_path(groep)
				click_on "Aanwezigheidslijst (week 1)"
				page.status_code.should == 200
				visit groep_path(groep)
				click_on "Aanwezigheidslijst (week 2)"
				page.status_code.should == 200
			end
			it "should correctly return 200 for aanwezigheidslijst-pdf's of witte tweeweek groep" do
				broeders = School.where(name: "Broeders").first
				broeders_klassen = broeders.klas.pluck(:id)
				witte_broeder_zwemmer = Zwemmer.where(kla_id: broeders_klassen).detect{|z| z.groep.niveau.name =="wit"}
				#witte tweeweekse groep:
				groep = witte_broeder_zwemmer.groep
				visit groep_path(groep)
				page.should have_link "Aanwezigheidslijst (volledig)"
				page.should have_link "Aanwezigheidslijst (week 1 + wekelijks)"
				page.should have_link "Aanwezigheidslijst (week 2 + wekelijks)"
				#all('a').select {|elt| elt.text == "Aanwezigheidslijst" }.first.click
				click_on "Aanwezigheidslijst (volledig)"
				page.status_code.should == 200
				visit groep_path(groep)
				click_on "Aanwezigheidslijst (week 1 + wekelijks)"
				page.status_code.should == 200
				visit groep_path(groep)
				click_on "Aanwezigheidslijst (week 2 + wekelijks)"
				page.status_code.should == 200
			end
			it "should correctly return 200 for aanwezigheidslijst-pdf's of niet-witte tweeweek groep on lesuur zonder witte groep" do
				broeders = School.where(name: "Broeders").first
				broeders_klassen = broeders.klas.pluck(:id)
				witte_broeder_zwemmer = Zwemmer.where(kla_id: broeders_klassen).detect{|z| z.groep.niveau.name =="wit"}
				witte_groep = witte_broeder_zwemmer.groep
				# maak witte groep leeg en verwijder
				volgende_groep = Groep.find(witte_groep.id+1)
				witte_groep.zwemmers.update_all(groep_id: volgende_groep.id)
				witte_groep.zwemmers.count.should == 0
				visit groep_path(witte_groep)
				click_on "Verwijder deze groep"
				# testen
				visit groep_path(volgende_groep)
				page.should have_link "Aanwezigheidslijst (volledig)"
				page.should have_link "Aanwezigheidslijst (week 1)"
				page.should have_link "Aanwezigheidslijst (week 2)"
				#all('a').select {|elt| elt.text == "Aanwezigheidslijst" }.first.click
				click_on "Aanwezigheidslijst (volledig)"
				page.status_code.should == 200
				visit groep_path(volgende_groep)
				click_on "Aanwezigheidslijst (week 1)"
				page.status_code.should == 200
				visit groep_path(volgende_groep)
				click_on "Aanwezigheidslijst (week 2)"
				page.status_code.should == 200
			end

			it "correctly returns 200 aanwezigheidslijst-pdf of a wit group with a zwemmer with extra and a non-wit zwemmer" do 
				groengroep = Groep.find(2)
				witgroep = Groep.find(1)
				groenzwemmer = groengroep.zwemmers.first
				witzwemmer = witgroep.zwemmers.first
				visit groep_path(2)
				find(:css, "#zwemmer_check_#{groenzwemmer.id}").set(true)
				click_on "Stuur naar wit"
				groenzwemmer.reload.groep.niveau.name.should == "wit"
				groenzwemmer.reload.groepvlag.should == 2
				visit zwemmer_path(witzwemmer)
				click_on "Wijzig deze zwemmer"
				fill_in "zwemmer[extra]", with: "latexallergie"
				click_on "Bewaar"
				witzwemmer.reload.extra.should == "latexallergie"
				visit groep_path(1)
				click_on "Aanwezigheidslijst (volledig)"
				page.status_code.should == 200
			end
			it "correctly returns 200 aanwezigheidslijst-pdf of a non-wit group with a zwemmer with extra and a groepzwemmer in wit" do 
				groengroep = Groep.find(2)
				witgroep = Groep.find(1)
				groenzwemmer = groengroep.zwemmers.first
				visit groep_path(2)
				find(:css, "#zwemmer_check_#{groenzwemmer.id}").set(true)
				click_on "Stuur naar wit"
				groenzwemmer.reload.groep.niveau.name.should == "wit"
				groenzwemmer.reload.groepvlag.should == 2
				visit groep_path(2)
				click_on "Aanwezigheidslijst (volledig)"
				page.status_code.should == 200
end
			it "should correctly return 200 for evaluatielijst-pdf's of tweeweek groep" do
				#2-week-klas: broeders 5b
				klas = Kla.find(86)
				klas.school.name.should == "Broeders"
				klas.name.should == "5b"
				groep = klas.zwemmers.first.groep
				visit groep_path(groep)
				page.should have_link "Evaluatielijst (week 1)"
				page.should have_link "Evaluatielijst (week 2)"
				click_on "Evaluatielijst (week 1)"
				page.status_code.should == 200
				visit groep_path(groep)
				click_on "Evaluatielijst (week 2)"
				page.status_code.should == 200
			end
			it "should correctly set start_year in get_year_dates in aanwezigheidslijst-pdf// timetravel" do
				current_month = Date.today.strftime("%m").to_i
				if current_month > 7 
					# timetravel to feb
  					t = Time.local(Time.now.year, 2, 1) 
					Timecop.freeze(t) do
						visit groep_path(2)
						click_on "Aanwezigheidslijst (volledig)"
						page.status_code.should == 200
					end
				else
					# timetravel to sep
					t = Time.local(Time.now.year, 9, 1) 
					Timecop.freeze(t) do
  						visit groep_path(2)
						click_on "Aanwezigheidslijst (volledig)"
						page.status_code.should == 200
					end
				end
			end
			it "should correctly show right notice when trying aanwezigheids-pdf for groep without lesgever" do
				g = Groep.first
				g.update_attributes(lesgever_id: nil)
				visit groep_path(g)
				click_on "Aanwezigheidslijst (volledig)"
				page.should have_content "Gelieve een lesgever aan te duiden voor deze groep."
			end
			it "should show 'Aanwezigheidslijst (wekelijks)' in groep show of mixed wekelijks/tweeweek groep" do
				school = School.where(name:"Klavertje 4").first
				klas_4 = Kla.where(name: "4", school_id: school.id).first
				# maak 4e wekelijks
				klas_4.update_attributes(tweeweek: false)
				visit groep_path(klas_4.zwemmers.first.groep)
				page.should have_content "Aanwezigheidslijst (wekelijks)"
			end
			it "correctly returns 200 evaluatielijst-pdf" do 
				visit groep_path(2)
				click_on "Evaluatielijst (volledig)"
				page.status_code.should == 200
			end
			it "should correctly return 200 for evaluatielijst-pdf of witte groep with niet-witte zwemmers" do
				# zet groepen en geel-witte zwemmer
				gele_groep = Groep.find(3)
				witte_groep = Groep.find(1)
				rode_groep = Groep.find(5)
				gele_zwemmer = gele_groep.zwemmers.first
				rode_zwemmer = rode_groep.zwemmers.first
				# stuur zwemmer nr wit
				visit groep_path(gele_groep)
				find(:css, "#zwemmer_check_#{gele_zwemmer.id}").set(true)
				click_on "Stuur naar wit"
				visit groep_path(rode_groep)
				find(:css, "#zwemmer_check_#{rode_zwemmer.id}").set(true)
				click_on "Stuur naar wit"
				# testen
				gele_zwemmer.reload.groep.niveau.name.should == "wit"
				gele_zwemmer.groepvlag.should == gele_groep.id
				gele_zwemmer.groep.should == witte_groep
				rode_zwemmer.reload.groep.niveau.name.should == "wit"
				rode_zwemmer.groepvlag.should == rode_groep.id
				rode_zwemmer.groep.should == witte_groep
				# evaluatielijst-pdf
				visit groep_path(witte_groep)
				click_on "Evaluatielijst (volledig)"
				# test
				page.status_code.should == 200
end
			it "correctly shows front index after logging in" do
				page.should have_content "Succesvol ingelogd"
				page.should have_content "mieke"
			end
			it "takes you correctly from front into Nieuwe groep" do
				click_on "Nieuwe groep"
				page.should have_content "Nieuwe groep"
				page.should have_content "Niveau"
			end
			it "should correctly redirect to groeps page of correct dag after deleting groep" do
				groep = FactoryGirl.create(:groep, lesgever_id: Lesgever.first.id, lesuur_id: Lesuur.first.id, niveau_id: Niveau.first.id, done_vlag: false)
				visit groep_path(groep)
				Timecop.freeze(Date.parse("29-09-2014")) do 
					click_on "Verwijder deze groep"
					page.should have_content "Groep werd verwijderd."
					page.current_url.should == "http://www.example.com/groeps?dag=1"
				end
			end
			it "should correctly change badmuts of zwemmer" do
				#eerste gele groep
				gele_groep = Groep.find(3)
				#neem derde zwemmer van deze groep
				gele_zwemmer = gele_groep.zwemmers[2]
				# verander zijn badmuts naar groen
				visit edit_zwemmer_path(gele_zwemmer)
				select "groen", from: "zwemmer[badmuts]"
				click_on "Bewaar"
				gele_zwemmer.reload.badmuts.should == "groen"
				# moet zwemmer show en groep show zonder fout laden
				visit zwemmer_path(gele_zwemmer)
				page.status_code.should == 200
				visit groep_path(gele_groep)
				page.status_code.should == 200
				# moet aanwezigheids-pdf zonder fout laden
				visit groep_path(gele_groep)
				click_on "Aanwezigheidslijst (volledig)"
				page.status_code.should == 200
				# verander badmuts terug naar leeg
				visit edit_zwemmer_path(gele_zwemmer)
				select "", from: "zwemmer[badmuts]"
				click_on "Bewaar"
				gele_zwemmer.reload.badmuts.should == ""
				# moet zwemmer show en groep show zonder fout laden
				visit zwemmer_path(gele_zwemmer)
				page.status_code.should == 200
				visit groep_path(gele_groep)
				page.status_code.should == 200
			end
			it "should correctly create a new groep" do
				click_on "Nieuwe groep"
				expect{
					select 'diederik', from: "groep[lesgever_id]"
					select '9u10', from: "groep[lesuur_id]"
					select 'groen', from: "groep[niveau_id]"
					click_on "Bewaar"
				}.to change(Groep, :count).by(1)
				page.should have_content "Groep werd succesvol aangemaakt."
			end
			it "groep new should show simple_form validation errors after invalid inputs" do
				click_on "Nieuwe groep"
				select 'diederik', from: "groep[lesgever_id]"
				select '9u10', from: "groep[lesuur_id]"
				select '', from: "groep[niveau_id]"
				click_on "Bewaar"
				page.should have_content "Gelieve volgende problemen"
				page.should have_content "mag niet leeg zijn"
			end
			it "takes you correctly from front into Nieuwe zwemmer" do
				click_on "Nieuwe zwemmer"
				page.should have_content "Nieuwe zwemmer"
				page.should have_content "Extra"
			end
			it "should correctly create a new zwemmer" do
				click_on "Nieuwe zwemmer"
				expect{
					fill_in 'zwemmer[name]', with: "roelandt diederik"
					fill_in 'zwemmer[extra]', with: "latexallergie"
					select "Broeders 2a", from: "zwemmer[kla_id]"
					select "woensdag 10u40 wit mieke", from: 'zwemmer[groep_id]'
					click_on "Bewaar"
				}.to change(Zwemmer, :count).by(1)
				page.should have_content "Zwemmer werd succesvol aangemaakt."
			end
			it "zwemmer new should show simple_form validation errors after invalid inputs" do
				click_on "Nieuwe zwemmer"
				fill_in 'zwemmer[name]', with: "roelandt diederik"
				fill_in 'zwemmer[extra]', with: "latexallergie"
				select "", from: "zwemmer[kla_id]"
				select "woensdag 10u40 wit mieke", from: 'zwemmer[groep_id]'
				click_on "Bewaar"
				page.should have_content "Gelieve volgende problemen"
				page.should have_content "mag niet leeg zijn"
			end

			it "zwemmer edit should correctly send zwemmer to other groep via zwemmers_edit" do
				#eerste zwemmer in groene groep 2
				zwemmer = Groep.find(2).zwemmers.first
				zwemmer.overgangs.count.should == 0
				visit edit_zwemmer_path(zwemmer)
				# controleer voor iets te doen
				page.should have_content "Wijzig zwemmer"
				find_field('zwemmer[name]').value.should == zwemmer.name
				find_field('zwemmer[groep_id]').value.should == "2"
				find_field('zwemmer[kla_id]').value.should == zwemmer.kla.id.to_s
				# selecteer oranje groep
				select "maandag 8u40 oranje frank", from: 'zwemmer[groep_id]'
				click_on "Bewaar"
				zwemmer.reload.groep.id.should == 4
				zwemmer.groep.niveau.name.should == "oranje"
				zwemmer.overgangs.count.should == 1
				overgang = Overgang.last
				overgang.zwemmer.id.should == zwemmer.id
				overgang.van.should == "groen"
				overgang.kleurcode_van.should == Niveau.where(name:"groen").first.kleurcode
				overgang.naar.should == "oranje"
				overgang.kleurcode_naar.should == Niveau.where(name:"oranje").first.kleurcode
				overgang.lesgever.should == "joke"
			end
			it "goes to and shows lesuren correctly" do
				click_on "Lesuren"
				page.should have_content "maandag"
				page.should have_content "8u40"
				page.should have_content "dinsdag"
			end

			it "goes to and show lesuurs new correctly" do
				click_on "Lesuren"
				click_on "Nieuw lesuur"
				page.should have_content "Naam"
				page.should have_content "Dag"
			end

			it "should correctly create a lesuur" do
				click_on "Lesuren"
				click_on "Nieuw lesuur"
				expect{
				fill_in "lesuur[name]", with: "11u50"
				select "maandag", from: "lesuur[dag_id]"
				click_on "Bewaar"
				}.to change(Lesuur, :count).by(1)
				page.should have_content "Lesuur werd succesvol aangemaakt."
			end

			it "lesuur new should show simple_form validation errors after invalid inputs" do
				click_on "Lesuren"
				click_on "Nieuw lesuur"
				fill_in "lesuur[name]", with: "11u50"
				select "", from: "lesuur[dag_id]"
				click_on "Bewaar"
				page.should have_content "Gelieve volgende problemen te bekijken"
				page.should have_content "mag niet leeg zijn"
			end

			it "follows link to schools correctly" do
				click_on "Scholen"
				page.should have_content "Broeders"
				page.should have_content "Klimop"
				page.should have_content "Nieuwe school"
				page.should have_content "Nieuwe klas"
			end

			it "shows correct stuff in school show" do
				visit school_path(8)
				page.should have_content "Broeders"
				page.body.should match(/<td>4a<\/td>\s*<td>\d*<\/td>\s*<td>x \(week 1\)<\/td>/)
				page.body.should match(/<td>5b<\/td>\s*<td>\d*<\/td>\s*<td>x \(week 2\)<\/td>/)
				page.body.should_not match(/<td>1a<\/td>\s*<td>\d*<\/td>\s*<td>x \(week \d\)<\/td>/)
			end

			it "should show both wekelijks and 2-wek rapporten link in school show for broeders" do
				visit school_path(8)
				# http://stackoverflow.com/questions/8613895/how-do-i-match-a-full-link-in-capybara
				page.html.should match('>\s*Rapporten\s*</a>')
				page.should have_link "Rapporten (2-wekelijks)"
			end

			it "should show only wekelijks rapporten link in school show for jongslag" do
				visit school_path(5)
				page.should have_link "Rapporten"
				page.should_not have_link "Rapporten (2-wekelijks)"
			end

			it "should show only 2-wekelijks rapporten link in school show for klavertje-4" do
				visit school_path(7)
				page.html.should_not match('>\s*Rapporten\s*</a>')
				page.should have_link "Rapporten (2-wekelijks)"
			end

			it "follows link to and shows nieuwe school correctly" do
				click_on "Scholen"
				click_on "Nieuwe school"
				page.should have_content "Nieuwe school"
				page.should have_content "Naam"
				page.should have_button "Bewaar"
			end

			it "should correctly create a school" do
				click_on "Scholen"
				click_on "Nieuwe school"
				expect{
					fill_in "school[name]", with: "SMI"
					click_on "Bewaar"
				}.to change(School, :count).by(1)
			end

			it "school new should show simple_form validation errors after invalid inputs" do
				click_on "Scholen"
				click_on "Nieuwe school"
				fill_in "school[name]", with: ""
				click_on "Bewaar"
				page.should have_content "Gelieve volgende problemen te bekijken"
				page.should have_content "mag niet leeg zijn"
			end

			it "should have school selected when going to nieuwe klas from specific school" do
				visit school_path(2)
				page.should have_content "RC"
				page.should have_content "Nieuwe klas"
				click_on "Nieuwe klas"
				find_field('kla[school_id]').find('option[selected]').text.should == "RC"
			end

			it "should return 200 succes when trying schoolrapporten-pdf" do
				visit school_path(3)
				click_on "Rapporten"
				page.status_code.should == 200
			end

			it "follows link to and shows nieuwe klas correctly" do
				click_on "Scholen"
				click_on "Nieuwe klas"
				page.should have_content "Nieuwe klas"
				page.should have_content "Naam"
				page.should have_content "School"
				page.should have_content "Lesuur"
				page.should have_content "2-wekelijks"
				page.should have_content "niet-dilbeeks"
				page.should have_button "Bewaar"
			end

			it "should correctly create a klas" do
				size = Kla.all.count
				click_on "Scholen"
				click_on "Nieuwe klas"
				select "2f", from: "kla[name]"
				select "Kriebel", from: "kla[school_id]"
				select "9u10", from: "kla[lesuur_id]"
				click_on "Bewaar"
				Kla.all.count.should == (size + 1)
			end

			it "klas new should show simple_form validation errors after invalid inputs" do
				click_on "Scholen"
				click_on "Nieuwe klas"
				select "", from: "kla[name]"
				select "", from: "kla[school_id]"
				select "", from: "kla[lesuur_id]"
				click_on "Bewaar"
				page.should have_content "Gelieve volgende problemen te bekijken"
				page.should have_content "mag niet leeg zijn"
			end

			it "should return 200 succes when trying klasrapporten-pdf in browser" do
				visit kla_path(40)
				click_on "Rapporten (in browser)"
				page.status_code.should == 200
			end
			it "should return 200 succes when trying klasrapporten-pdf opslag" do
				visit kla_path(40)
				click_on "Rapporten (opslaan)"
				page.status_code.should == 200
			end
			it "should return 200 succes when trying klaslijst-pdf of 2-wekelijkse klas" do
				# vindt eerste 2-wekelijkse klas
				tweewk_klas = Kla.all.detect{|k| k.tweeweek == true}
				visit kla_path(tweewk_klas)
				click_on "Klaslijst"
				page.status_code.should == 200
			end
			it "should correctly send all zwemmers in klas naar juiste groep wanneer lesuur_id van klas veranderd is bij klas_edit; met geen oranje groep in lesuur" do
				
				doel_lesuur = Lesuur.find(6)
				# gebruik 2a van keperke
				school = School.where('name = ?', "Keperke").first
				klas = Kla.where('name = ? and school_id = ?', "2a", school.id).first
				# maak oranje groep leeg en verwijder groep
				oranje_groep = Groep.where('lesuur_id = ? and niveau_id = ?', doel_lesuur.id, Niveau.find(4).id).first
				oranje_groep.niveau.name.should == "oranje"
				visit groep_path(oranje_groep)
				oranje_groep.zwemmers.each do |z|
					page.should have_content z.name
					find(:css, "#zwemmer_check_#{z.id}").set(true)
				end
				click_on "Niveau hoger"
				visit groep_path(oranje_groep)
				click_on "Verwijder deze groep"
				page.should have_content "Groep werd verwijderd"
				# sla niveaus van alle zwemmers van klas op
				zwemmers_niveaus = Hash.new
				klas.zwemmers.each{|z| zwemmers_niveaus[z.id] = z.groep.niveau.name}
				# verander lesuur van klas naar woensdag 9u05
				visit edit_kla_path(klas)
				select "9u05", from: "kla[lesuur_id]"
				click_on "Bewaar"
				page.should have_content "Klas werd succesvol gewijzigd"
				klas.reload.lesuur.should == doel_lesuur
				klas.zwemmers.each do |z|
					z.groep.niveau.name.should == zwemmers_niveaus[z.id]
					z.groep.lesuur.id.should == doel_lesuur.id
				end
			end
			it "follows link to and shows niveaus correctly" do
				click_on "Niveaus"	
				page.should have_content "Nieuw niveau"
				page.should have_content "groen"
				page.should have_content "Verwijder"
			end

			it "follows link to and shows nieuwe niveau correctly" do
				click_on "Niveaus"
				click_on "Nieuw niveau"
				page.should have_content "Naam"
				page.should have_content "Kleurcode"
				page.should have_content "Karakter"
				page.should have_button "Bewaar"
			end

			it "should correctly create a niveau" do
				click_on "Niveaus"
				click_on "Nieuw niveau"
				expect{
					fill_in "niveau[name]", with: "roze"
					fill_in "niveau[kleurcode]", with: "#FFF"
					fill_in "niveau[karakter]", with: "7"
					click_on "Bewaar"
				}.to change(Niveau, :count).by(1)
			end

			it "niveau new should show simple_form validation errors after invalid inputs" do
				click_on "Niveaus"
				click_on "Nieuw niveau"
				fill_in "niveau[name]", with: "groen"
				fill_in "niveau[kleurcode]", with: ""
				fill_in "niveau[karakter]", with: "7"
				click_on "Bewaar"
				page.should have_content "Gelieve volgende problemen te bekijken"
				page.should have_content "bestaat al"
				page.should have_content "mag niet leeg zijn"
			end

			it "follows link to and shows proefs correctly" do
				visit niveau_path(Niveau.find(2))
				page.should have_content "Niveau"
				page.should have_content "Rang"
				page.should have_content "Inhoud"
				page.should have_content "Invoertype"
				page.should have_content "Nieuwe test"
			end

			it "follows link to and shows nieuwe proef correctly" do
				visit niveau_path(Niveau.find(2))
				click_on "Nieuwe test"
				page.should have_content "Inhoud"
				page.should have_content "Niveau"
				page.should have_content "Scoretype"
				page.should have_button "Bewaar"
			end

			it "should correctly create a proef" do
				visit niveau_path(Niveau.find(2))
				click_on "Nieuwe test"
				expect{
					fill_in "proef[content]", with: "bubbelen"
					select "oranje", from: "proef[niveau_id]"
					select "score", from: "proef[scoretype]"
					click_on "Bewaar"
				}.to change(Proef, :count).by(1)
			end

			it "proef new should show simple_form validation errors after invalid inputs" do
				visit niveau_path(Niveau.find(2))
				click_on "Nieuwe test"
				fill_in "proef[content]", with: "beenbeweging schoolslag op de plank"
				select "groen", from: "proef[niveau_id]"
				select "", from: "proef[scoretype]"
				click_on "Bewaar"
				page.should have_content "Gelieve volgende problemen te bekijken"
				page.should have_content "bestaat al"
				page.should have_content "mag niet leeg zijn"
			end


			it "follows link to and shows lesgevers correctly" do
				click_on "Lesgevers"
				page.should have_content "Gebruikers"
				page.should have_content "diederik"
				page.should have_content "admin"
				page.should have_content "Verwijder"
				page.should have_content "Nieuwe lesgever"
			end

			it "follows link to and shows nieuwe lesgever correctly" do
				click_on "Lesgevers"
				click_on "Nieuwe lesgever"
				page.should have_content "Naam"
				page.should have_content "Email"
				page.should have_content "Wachtwoord"
				page.should have_content "Wachtwoord confirmatie"
				page.should have_content "Rollen"
				page.should have_button "Bewaar"
			end

			it "should correctly create a lesgever" do
				click_on "Lesgevers"
				click_on "Nieuwe lesgever"
				expect{
					fill_in "lesgever[name]", with: "silke"
					fill_in "lesgever[email]", with: "silke@yahoo.com"
					fill_in "lesgever[password]", with: "steekvoet"
					fill_in "lesgever[password_confirmation]", with: "steekvoet"
					find(:css, "#lesgever_role_ids_2").set(true)
					click_on "Bewaar"
				}.to change(Lesgever, :count).by(1)
			end

			it "lesgever new should show simple_form validation errors after invalid inputs" do
				click_on "Lesgevers"
				click_on "Nieuwe lesgever"
				fill_in "lesgever[name]", with: ""
				fill_in "lesgever[email]", with: "silke@yahoo.com"
				fill_in "lesgever[password]", with: "steekvoet"
				fill_in "lesgever[password_confirmation]", with: "voet"
				find(:css, "#lesgever_role_ids_2").set(true)
				click_on "Bewaar"
				page.should have_content "Gelieve volgende problemen te bekijken"
				page.should have_content "mag niet leeg zijn"
				page.should have_content "confirmatie komt niet overeen"
			end

			it "shows mijn profiel correctly" do
				click_on "Mijn profiel"
				page.should have_content "Naam"
				page.should have_content "diederik"
				page.should have_content "Email"
				page.should have_content "Wachtwoord"
				page.should have_content "Wachtwoord confirmatie"
				page.should have_content "Rollen"
				page.should have_button "Bewaar"
			end

			it "should correctly update lesgever from mijn profiel" do
				click_on "Mijn profiel"
				fill_in "lesgever[password]", with: "probeersel"
				fill_in "lesgever[password_confirmation]", with: "probeersel"
				click_on "Bewaar"
				page.should have_content "Wachtwoord"
				fill_in 'lesgever[name]', with: "diederik"
				fill_in 'lesgever[password]', with: "probeersel"
				click_on "Inloggen"
				page.should have_content "Succesvol ingelogd"
			end

			it "shows paneel correctly" do
				click_on "Paneel"
				page.should have_content "Start testperiode"
				page.should have_content "Reset importeren"
				page.should have_content "Totaal aantal zwemmers"
				page.should have_content Zwemmer.count.to_s
				page.should have_content "Totaal aantal klassen"
				page.should have_content Kla.count.to_s
				page.should have_content "Totaal aantal groepen"
				page.should have_content Groep.count.to_s
				page.should have_link "Niet-geüpdate zwemmers"
				page.should have_link "Niet-geüpdate zwemmers (pdf)"
			end

			it "changes start to stop testperiode when clicking it (and shows extra)" do
				click_on "Paneel"
				click_on "Start testperiode"
				page.should have_content "Stop testperiode"
				page.should have_content "Aantal zwemmers gestegen"
			end

			it "shows klas importeren correctly" do
				click_on "Klas importeren"
				page.should have_content "Klas:"
				page.should have_content "Basisniveau:"
				page.should have_button "Importeer"
			end

			it "adds the imported zwemmers correctly, with no (groen, oranje, rood) groep in lesuur of klas, and with 1 alrdy known zwemmer" do
				school = School.where('name = ?', "Keperke").first
				klas = Kla.where('name = ? and school_id = ?', "2a", school.id).first
				# maak groene groep leeg en verwijder groep
				groene_groep = Groep.where('lesuur_id = ? and niveau_id = ?', klas.lesuur.id, Niveau.find(2).id).first
				groene_groep.niveau.name.should == "groen"
				visit groep_path(groene_groep)
				groene_groep.zwemmers.each do |z|
					page.should have_content z.name
					find(:css, "#zwemmer_check_#{z.id}").set(true)
				end
				click_on "Niveau hoger"
				visit groep_path(groene_groep)
				click_on "Verwijder deze groep"
				# maak oranje groep leeg en verwijder groep
				oranje_groep = Groep.where('lesuur_id = ? and niveau_id = ?', klas.lesuur.id, Niveau.find(4).id).first
				oranje_groep.niveau.name.should == "oranje"
				visit groep_path(oranje_groep)
				oranje_groep.zwemmers.each do |z|
					page.should have_content z.name
					find(:css, "#zwemmer_check_#{z.id}").set(true)
				end
				click_on "Niveau hoger"
				visit groep_path(oranje_groep)
				click_on "Verwijder deze groep"
				# maak rode groep leeg en verwijder groep
				rode_groep = Groep.where('lesuur_id = ? and niveau_id = ?', klas.lesuur.id, Niveau.find(5).id).first
				rode_groep.niveau.name.should == "rood"
				visit groep_path(rode_groep)
				rode_groep.zwemmers.each do |z|
					page.should have_content z.name
					find(:css, "#zwemmer_check_#{z.id}").set(true)
				end
				click_on "Niveau hoger"
				visit groep_path(rode_groep)
				click_on "Verwijder deze groep"
				#vindt eerste zwemmer, niet in lesuur van keperke 2a, en in oranje
				gekende_zwemmer =  Zwemmer.find((1..1000).detect {|i| (Zwemmer.find(i).kla.lesuur.dag.name != klas.lesuur.dag.name) && (Zwemmer.find(i).kla.lesuur.name != klas.lesuur.name) && (Zwemmer.find(i).groep.niveau.name == "oranje")})
				# klas importeren
				click_on "Klas importeren"
				expect{
					select "Keperke 2a", from: "klas"
					select "groen", from: "niveau"
					fill_in "zwemmers", with: "bovie danny3\r\n#{gekende_zwemmer.name}\r\nverengst lowie \r\nmaryn zohra1\r\nblable boem5"
					click_on "Importeer"
				}.to change(Zwemmer, :count).by(4)
				page.should have_content "BOVIE DANNY"
				page.should have_content "VERENGST LOWIE"
				zwemmer1 = Zwemmer.where('name = ?', "BOVIE DANNY").first
				zwemmer2 = Zwemmer.where('name = ?', "VERENGST LOWIE").first
				zwemmer3 = Zwemmer.where('name = ?', "MARYN ZOHRA").first
				zwemmer4 = Zwemmer.where('name = ?', "BLABLE BOEM").first
				zwemmer1.groep.niveau.name.should == "geel"
				zwemmer2.groep.niveau.name.should == "groen"
				zwemmer3.groep.niveau.name.should == "wit"
				zwemmer4.groep.niveau.name.should == "rood"
				gekende_zwemmer.reload.groep.niveau.name.should == "oranje"
				gekende_zwemmer.reload.kla.should == klas
				Groep.where('lesuur_id = ? and niveau_id = ?', klas.lesuur.id, Niveau.find(3).id).first.should == zwemmer1.groep
				Groep.where('lesuur_id = ? and niveau_id = ?', klas.lesuur.id, Niveau.find(2).id).first.should == zwemmer2.groep
				Groep.where('lesuur_id = ? and niveau_id = ?', klas.lesuur.id, Niveau.find(1).id).first.should == zwemmer3.groep
				click_on "Paneel" 
				click_on "Reset importeren"
				page.should have_content "Reset importeren"
				zwemmer1.reload.importvlag.should == false
				zwemmer2.reload.importvlag.should == false
			end

			it "should correctly save extra as 'nieuw' for imported zwemmers, older then 1e leerjaar" do
				gekende_zwemmer = Zwemmer.all.first
				click_on "Klas importeren"
				expect{
					select "Keperke 3a", from: "klas"
					select "groen", from: "niveau"
					fill_in "zwemmers", with: "bovie danny\r\n#{gekende_zwemmer.name}\r\nverengst lowie5"
					check "nieuw"
					click_on "Importeer"
				}.to change(Zwemmer, :count).by(2)
				zwemmer = Zwemmer.where(name: "BOVIE DANNY").first
				zwemmer2 = Zwemmer.where(name: "VERENGST LOWIE").first
				zwemmer.groep.niveau.name.should == "groen"
				zwemmer.extra.should == "nieuw"
				zwemmer2.groep.niveau.name.should == "rood"
				zwemmer2.extra.should == "nieuw"
			end

			it "should not save 'nieuw' extra for nieuwe zwemmers, when 'nieuw' is not checked" do
				gekende_zwemmer = Zwemmer.all.first
				school = School.where('name = ?', "Keperke").first
				# maak kleuterklas
				Kla.create(name: "3ka", school_id: school.id, lesuur_id: Lesuur.all.first.id, tweeweek: false, nietdilbeeks: false, week: 0)
				click_on "Klas importeren"
				expect{
					select "Keperke 3ka", from: "klas"
					select "groen", from: "niveau"
					fill_in "zwemmers", with: "bovie danny\r\n#{gekende_zwemmer.name}\r\nverengst lowie5"
					uncheck "nieuw"
					click_on "Importeer"
				}.to change(Zwemmer, :count).by(2)
				zwemmer = Zwemmer.where(name: "BOVIE DANNY").first
				zwemmer2 = Zwemmer.where(name: "VERENGST LOWIE").first
				zwemmer.groep.niveau.name.should == "groen"
				zwemmer.extra.should == ""
				zwemmer2.groep.niveau.name.should == "rood"
				zwemmer2.extra.should == ""
			end

			it "should show all zwemmers, proefs, and fouts in tst page" do
				# https://github.com/jnicklas/capybara
				# http://rubydoc.info/github/jnicklas/capybara/Capybara/Node/Finders#all-instance_method
				click_on "Paneel"
				click_on "Start testperiode"
				visit(groep_path(2))
				click_link "Test deze groep"
				page.status_code.should == 200
				page.should have_button "Bewaar"
				grp = Groep.find(2)
				proeven = grp.niveau.proefs.where("nietdilbeeks = ?", false).order("position")
				page.all('.accordion-group').each_with_index do |el, eli|
					el.should have_content grp.zwemmers.sort_by{ |zw| [-zw.kla.name.to_i, zw.kla.name, zw.kla.school.name, zw.name]}[eli].name
    				el.all('fieldset').each_with_index do |fld, fldi|
    					fld.should have_content proeven[fldi].content
    					#fld.should have_content "Score"
    					fld.should have_field "groep[zwemmers_attributes][#{eli}][rapports_attributes][0][resultaats_attributes][#{fldi}][score]"
    					proeven[fldi].fouts.each do |f|
    						fld.should have_content f.name
    					end
    				end
    				el.should have_content "Extra commentaar"
    				el.should have_field("groep[zwemmers_attributes][#{eli}][rapports_attributes][0][extra]")
    				el.should have_content "Rapport klaar"
    				el.should have_field("groep[zwemmers_attributes][#{eli}][rapports_attributes][0][klaar]")
    				el.should have_content "Gaat over"
    				el.should have_field("groep[zwemmers_attributes][#{eli}][overvlag]")
				end
			end

			it "sends zwemmer to other groep of same niveau with groepshow buttons" do
				groepgroen = Groep.find(8)
				visit new_groep_path
				select "diederik", from: "groep[lesgever_id]"
				select "9u10", from: "groep[lesuur_id]"
				select "groen", from: "groep[niveau_id]"
				click_on "Bewaar"
				visit groep_path(groepgroen)  #groene groep van maandag 9u10
				page.should have_button "Stuur naar diederik"
				zwemmer1 = groepgroen.zwemmers.first
				zwemmer2 = groepgroen.zwemmers.last
				find(:css, "#zwemmer_check_#{zwemmer1.id}").set(true)
				find(:css, "#zwemmer_check_#{zwemmer2.id}").set(true)
				click_on "Stuur naar diederik"
				Groep.last.zwemmers.count.should == 2
				zwemmer1.reload.groep.should == Groep.last
				zwemmer2.reload.groep.should == Groep.last
			end

			it "sends zwemmer succesfully to wit with groepshow buttons, and also sends him back to original group" do
				gele_zwemmer =  Zwemmer.find((1..1000).detect {|i| Zwemmer.find(i).groep.niveau.position == 3})
				gele_zwemmer.groep.niveau.name.should == "geel"
				oude_groep_id = gele_zwemmer.groep.id
				visit(groep_path(gele_zwemmer.groep.id))
				#find("#zwemmer_check_#{gele_zwemmer.id}").check
				#page.check("#zwemmer_check_#{gele_zwemmer.id}")
				find(:css, "#zwemmer_check_#{gele_zwemmer.id}").set(true)
				click_on "Stuur naar wit"
				page.should have_content "Zwemmer succesvol naar wit gestuurd."
				gele_zwemmer.reload.groepvlag.should == oude_groep_id
				gele_zwemmer.reload.groep.niveau.name.should == "wit"
				visit groep_path(gele_zwemmer.reload.groep)
				find(:css, "#zwemmer_check_#{gele_zwemmer.id}").set(true)
				click_on("Stuur terug")
				page.should have_content "Zwemmer succesvol terug gestuurd."
				gele_zwemmer.reload.groepvlag.should == 0
				gele_zwemmer.reload.groep.niveau.name.should == "geel"
			end

			it "show correct notice when trying to do something with groepshow buttons without having zwemmers selected" do
				visit(groep_path(3))
				click_on "Niveau hoger"
				page.should have_content "Geen zwemmers aangevinkt."
			end

			it "sends oranje zwemmer succesfully to niveau hoger with groepshow buttons, with 2 groeps of rood niveau" do
				# vindt eerste oranje zwemmer
				oranje_zwemmer =  Zwemmer.find((1..1000).detect {|i| Zwemmer.find(i).groep.niveau.position == 4})
				oranje_zwemmer.groep.niveau.name.should == "oranje"
				oude_groep_id = oranje_zwemmer.groep.id
				# maak 2e rode groep
				FactoryGirl.create(:groep, lesgever_id: Lesgever.first.id, lesuur_id: oranje_zwemmer.kla.lesuur.id, niveau_id: Niveau.find(5).id, done_vlag: false)
				# stuur oranje zwemmer over
				visit(groep_path(oranje_zwemmer.groep.id))
				find(:css, "#zwemmer_check_#{oranje_zwemmer.id}").set(true)
				click_on "Niveau hoger"
				page.should have_content "Zwemmer succesvol over gestuurd."
				oranje_zwemmer.reload.groep.niveau.name.should == "rood"
				oranje_zwemmer.overgangs.last.kleurcode_van.should == Niveau.where(name:"oranje").first.kleurcode
				oranje_zwemmer.overgangs.last.kleurcode_naar.should == Niveau.where(name:"rood").first.kleurcode
			end
			it "sends oranje zwemmer succesfully to niveau hoger with groepshow buttons, with no groep of rood niveau" do
				# vindt eerste oranje zwemmer
				oranje_zwemmer =  Zwemmer.find((1..1000).detect {|i| Zwemmer.find(i).groep.niveau.position == 4})
				oranje_zwemmer.groep.niveau.name.should == "oranje"
				oude_groep_id = oranje_zwemmer.groep.id
				# maak rode groep leeg en verwijder groep
				rode_groep = Groep.find(oude_groep_id + 1)
				rode_groep.niveau.name.should == "rood"
				visit groep_path(rode_groep)
				rode_groep.zwemmers.each do |z|
					page.should have_content z.name
					find(:css, "#zwemmer_check_#{z.id}").set(true)
				end
				click_on "Niveau hoger"
				visit groep_path(rode_groep)
				click_on "Verwijder deze groep"
				# stuur oranje zwemmer over
				visit(groep_path(oude_groep_id))
				find(:css, "#zwemmer_check_#{oranje_zwemmer.id}").set(true)
				click_on "Niveau hoger"
				page.should have_content "Zwemmer succesvol over gestuurd."
				oranje_zwemmer.reload.groep.niveau.name.should == "rood"
			end
			it "sends zwemmer succesfully to niveau lager with groepshow buttons" do
				oranje_zwemmer =  Zwemmer.find((1..1000).detect {|i| Zwemmer.find(i).groep.niveau.position == 4})
				oranje_zwemmer.groep.niveau.name.should == "oranje"
				oude_groep_id = oranje_zwemmer.groep.id
				visit(groep_path(oranje_zwemmer.groep.id))
				find(:css, "#zwemmer_check_#{oranje_zwemmer.id}").set(true)
				click_on "Niveau lager"
				page.should have_content "Zwemmer succesvol over gestuurd."
				oranje_zwemmer.reload.groep.niveau.name.should == "geel"
			end
			it "should send niet-witte(groene) zwemmer in wit to geel (not groen) and witte zwemmer to groen with checkbox and groep-show buttons" do
				witte_groep = Groep.find(1)
				witte_zwemmer = witte_groep.zwemmers.first
				# send groene zwemmer to wit
				groene_groep = Groep.find(2)
				groene_zwemmer = groene_groep.zwemmers.first
				visit groep_path(groene_groep)
				find(:css, "#zwemmer_check_#{groene_zwemmer.id}").set(true)
				click_on "Stuur naar wit"
				groene_zwemmer.reload.groep.niveau.name.should == "wit"
				# stuur groene zwemmer en witte zwemmer in wit over
				visit groep_path(witte_groep)
				find(:css, "#zwemmer_check_#{groene_zwemmer.id}").set(true)
				find(:css, "#zwemmer_check_#{witte_zwemmer.id}").set(true)
				click_on "Niveau hoger"
				groene_zwemmer.reload.groep.should == Groep.find(3)
				groene_zwemmer.groep.niveau.name.should == "geel"
				groene_zwemmer.groepvlag.should == 0
				witte_zwemmer.reload.groep.should == groene_groep
				witte_zwemmer.groep.niveau.name.should == "groen"
				witte_zwemmer.groepvlag.should == 0
			end
			it "should keep groene(bij wit) zwemmer in wit when changing groene groep" do
				witte_groep = Groep.find(1)
				groene_groep = Groep.find(2)
				###
				groene_zwemmer = groene_groep.zwemmers.first
				### maak 2e groene groep
				tweede_groene_groep = Groep.create(lesuur_id: groene_groep.lesuur.id, niveau_id: groene_groep.niveau.id, lesgever_id: Lesgever.first.id)
				### stuur groene zwemmer naar wit
				visit groep_path(groene_groep)
				find(:css, "#zwemmer_check_#{groene_zwemmer.id}").set(true)
				click_on "Stuur naar wit"
				page.should have_content groene_zwemmer.name
				witte_groep.zwemmers.should include(groene_zwemmer)
				groene_zwemmer.reload.groep.should == witte_groep
				groene_zwemmer.groepvlag.should == groene_groep.id
				### stuur groene zwemmer naar 2e groene groep
				visit groep_path(groene_groep)
				page.should have_content "#{groene_zwemmer.name}(wit)"
				find(:css, "#zwemmer_check_#{groene_zwemmer.id}").set(true)
				click_on "Stuur naar #{Lesgever.first.name}"
				page.should have_content "#{groene_zwemmer.name}(wit)"
				groene_zwemmer.reload.groep.should == witte_groep
				groene_zwemmer.groepvlag.should == tweede_groene_groep.id
				visit groep_path(witte_groep)
				page.should have_content groene_zwemmer.name
			end
			it "should show correct proefs for gele in witte groep, and sends him to oranje(with 2 oranje groeps), and checks if Stop testperiode is carried out correctly" do
				visit(groep_path(3))
				gele_grp = Groep.find(3)
				gele_proeven = gele_grp.niveau.proefs.where("nietdilbeeks = ?", false).order("position")
				zwemmer = Groep.find(3).zwemmers.first
				find(:css, "#zwemmer_check_#{zwemmer.id}").set(true)
				click_on "Stuur naar wit"
				page.should have_content "Zwemmer succesvol naar wit gestuurd."
				click_on "Paneel"
				click_on "Start testperiode"
				visit(groep_path(1))
				page.should have_content zwemmer.name
				click_link "Test deze groep"
				page.should have_button "Bewaar"
				page.all('.accordion-group').each_with_index do |el, eli|
					if el.text.include? zwemmer.name
						el.should have_field("groep[zwemmers_attributes][#{eli}][overvlag]")
						find(:css, "#groep_zwemmers_attributes_#{eli}_overvlag").set(true)
						el.all('fieldset').each_with_index do |fld, fldi|
						fld.should have_content gele_proeven[fldi].content
						gele_proeven[fldi].fouts.each do |f|
    						fld.should have_content f.name
    					end
					end
					end
				end
				click_on "Bewaar"
				page.should have_content "Testresultaten succesvol opgeslagen"
				zwemmer.reload.overvlag.should == true
				page.should have_content "#{zwemmer.name}(+)"
				# maak 2e oranje groep
				FactoryGirl.create(:groep, lesgever_id: Lesgever.first.id, lesuur_id: zwemmer.kla.lesuur.id, niveau_id: Niveau.find(4).id, done_vlag: false)
				# markeer groep als 'testen gedaan', waardoor zwemmers over gestuurd worden
				click_on "Wijzig deze groep"
				find(:css, "#groep_done_vlag").set(true)
				click_on "Bewaar"
				zwemmer.reload.groep.niveau.name.should == "oranje"
				zwemmer.reload.netovervlag.should == true
				Groep.find(1).done_vlag.should == true
				click_on "Paneel"
				click_on "Stop testperiode"
				zwemmer.reload.netovervlag.should == false
				Groep.find(1).done_vlag.should == false
			end
			it "should correctly save rapport_niveaus in each rapport when saving in tst page" do
				groep = Groep.find(3)
				# start testperiode
				click_on "Paneel"
				click_on "Start testperiode"
				visit(groep_path(3))
				click_link "Test deze groep"
				click_on "Bewaar"
				groep.zwemmers.each do |z|
					z.rapports.last.niveaus.should == rapport_niveaus
				end
			end
			it "should correctly save klas and school in each rapport when saving in tst page" do
				groep = Groep.find(3)
				# start testperiode
				click_on "Paneel"
				click_on "Start testperiode"
				visit(groep_path(3))
				click_link "Test deze groep"
				click_on "Bewaar"
				groep.zwemmers.each do |z|
					z.rapports.last.school.should == z.kla.school.name
					z.rapports.last.klas.should == z.kla.name
				end
			end
			it "should send gele in wit to oranje(with no oranje groep), and checks if Stop testperiode is carried out correctly" do
				# stuur gele zwemmer naar wit
				visit(groep_path(3))
				zwemmer = Groep.find(3).zwemmers.first
				find(:css, "#zwemmer_check_#{zwemmer.id}").set(true)
				click_on "Stuur naar wit"
				page.should have_content "Zwemmer succesvol naar wit gestuurd."
				# verwijder oranje groep
				oranje_groep = Groep.find(4)
				oranje_groep.niveau.name.should == "oranje"
				visit groep_path(oranje_groep)
				oranje_groep.zwemmers.each do |z|
					page.should have_content z.name
					find(:css, "#zwemmer_check_#{z.id}").set(true)
				end
				click_on "Niveau hoger"
				visit groep_path(oranje_groep)
				click_on "Verwijder deze groep"
				# start testperiode
				click_on "Paneel"
				click_on "Start testperiode"
				# vul in rapport zwemmer
				visit(groep_path(1))
				page.should have_content zwemmer.name
				click_link "Test deze groep"
				page.should have_button "Bewaar"
				page.all('.accordion-group').each_with_index do |el, eli|
					if el.text.include? zwemmer.name
						find(:css, "#groep_zwemmers_attributes_#{eli}_overvlag").set(true)
					end
				end
				click_on "Bewaar"
				page.should have_content "Testresultaten succesvol opgeslagen"
				zwemmer.reload.overvlag.should == true
				page.should have_content "#{zwemmer.name}(+)"
				# markeer groep als 'testen gedaan', waardoor zwemmers over gestuurd worden
				click_on "Wijzig deze groep"
				find(:css, "#groep_done_vlag").set(true)
				click_on "Bewaar"
				zwemmer.reload.groep.niveau.name.should == "oranje"
				zwemmer.reload.netovervlag.should == true
				Groep.find(1).done_vlag.should == true
				click_on "Paneel"
				click_on "Stop testperiode"
				zwemmer.reload.netovervlag.should == false
				Groep.find(1).done_vlag.should == false
			end
			it "should correctly save a rapport for a groep of 2 zwemmers, and show correct saved results when testpage is opened again, and correctly load the rapporten- en schoollijst-pdf of a zwemmer's klas and school" do
				groen = Niveau.find(2)
				#maak nieuwe groene groep op maandag 9u10
				visit new_groep_path
				select "diederik", from: "groep[lesgever_id]"
				select "9u10", from: "groep[lesuur_id]"
				select "groen", from: "groep[niveau_id]"
				click_on "Bewaar"
				#stuur 2 witte van ma 9u10 naar nieuwe groene groep
				groen_groep1 = Groep.find(8)
				zwemmer = Array.new
				zwemmer[0] = groen_groep1.zwemmers.first
				zwemmer[1] = groen_groep1.zwemmers.last
				visit(groep_path(8))
				find(:css, "#zwemmer_check_#{zwemmer[0].id}").set(true)
				find(:css, "#zwemmer_check_#{zwemmer[1].id}").set(true)
				click_on "Stuur naar diederik"
				click_on "Paneel"
				click_on "Start testperiode"
				visit groep_path(Groep.last)
				click_on "Test deze groep"
				page.should have_content zwemmer[0].name
				# aantal proeven voor groen, juist ordenen zwemmers
				proefs =  Niveau.find(2).proefs.where("nietdilbeeks = ?", false)
				proef_count = proefs.count
				zwemmer = Groep.last.zwemmers.sort_by{ |zw| [-zw.kla.name.to_i, zw.kla.name, zw.kla.school.name, zw.name]}
				ar = ["A", "B", "C"]
				# array gevuld met aa, a, en b voor proef_count, en shuffle result_array dan door elkaar voor elk van de 2 zwemmers
				result_array = ar*(proef_count/ar.size) + ar.first(proef_count%ar.size)
				r = Hash.new
				r[zwemmer[0].name] = result_array.shuffle
				r[zwemmer[1].name] = result_array.shuffle
				page.all('.accordion-group').each_with_index do |el, eli|
    				el.all('fieldset').each_with_index do |fld, fldi|
    					# TODO TODO TODO
    					# current_zwemmer = zwemmer.detect {|z| el.text.include? z.name}
    					# volgende voor oude select methode voor score
						#select r[zwemmer[eli].name][fldi], from: "groep[zwemmers_attributes][#{eli}][rapports_attributes][0][resultaats_attributes][#{fldi}][score]"
						choose "groep_zwemmers_attributes_#{eli}_rapports_attributes_0_resultaats_attributes_#{fldi}_score_#{r[zwemmer[eli].name][fldi].downcase}"
						# vink telkens eerste fout aan 
						#save_and_open_page
						find(:css, "#groep_zwemmers_attributes_#{eli}_rapports_attributes_0_resultaats_attributes_#{fldi}_fout_ids_#{proefs[fldi].fouts.first.id}").set(true)
    				end
				end
				click_on "Bewaar"
				zwemmer[0].reload.rapports.last.resultaats.each_with_index do |res, resi|
					res.score.should == r[zwemmer[0].name][resi]
				end
				zwemmer[1].reload.rapports.last.resultaats.each_with_index do |res, resi|
					res.score.should == r[zwemmer[1].name][resi]
				end
				# open testpagina opnieuw en kijk of resultaten correct weergegeven worden
				click_on "Test deze groep"
				zwemmer.each_with_index do |z, zi|
					(0..proef_count-1).each do |i| 
						# volgende voor oude select methode voor score
						#find_field("groep[zwemmers_attributes][#{zi}][rapports_attributes][0][resultaats_attributes][#{i}][score]").value.should == r[z.name][i]
						find(:css,"input#groep_zwemmers_attributes_#{zi}_rapports_attributes_0_resultaats_attributes_#{i}_score_#{r[zwemmer[zi].name][i].downcase}").should be_checked
						
					end
				end
				
				# voor klas rapporten pdf:
				visit kla_path(zwemmer[0].kla)
				click_on "Rapporten (in browser)"
				page.status_code.should == 200
				visit kla_path(zwemmer[0].kla)
				click_on "Rapporten (opslaan)"
				page.status_code.should == 200
				# voor school rapporten pdf:
				visit school_path(zwemmer[0].kla.school)
				click_on "Rapporten"
				page.status_code.should == 200
			end
			it "should correctly save a rapport for a groep of 2 zwemmers (apart ingevuld), and show correct saved results when testpage is opened again" do
				### voor grote bug van januari 2014     ####
				groen = Niveau.where(name: "groen").first
				#maak nieuwe groene groep op maandag 9u10
				visit new_groep_path
				select "diederik", from: "groep[lesgever_id]"
				select "9u10", from: "groep[lesuur_id]"
				select "groen", from: "groep[niveau_id]"
				click_on "Bewaar"
				#stuur 2 witte van ma 9u10 naar nieuwe groene groep
				d = Dag.where(name:"maandag").first
				l = Lesuur.where(name: "9u10", dag_id: d.id).first
				groen_groep1 = Groep.where(niveau_id: groen.id, lesuur_id: l.id).first
				zwemmer = Array.new
				zwemmer[0] = groen_groep1.zwemmers.first
				zwemmer[1] = groen_groep1.zwemmers.last
				visit(groep_path(groen_groep1))
				find(:css, "#zwemmer_check_#{zwemmer[0].id}").set(true)
				find(:css, "#zwemmer_check_#{zwemmer[1].id}").set(true)
				click_on "Stuur naar diederik"
				click_on "Paneel"
				click_on "Start testperiode"
				visit groep_path(Groep.last)
				click_on "Test deze groep"
				#resultaten
				proefs =  groen.proefs.where("nietdilbeeks = ?", false)
				proef_count = proefs.count
				zwemmer = Groep.last.zwemmers.sort_by{ |zw| [-zw.kla.name.to_i, zw.kla.name, zw.kla.school.name, zw.name]}
				ar = ["", "A", "B", "C"]
						# schudt door elkaar
				result_array = ar*(proef_count/ar.size) + ar.first(proef_count%ar.size)
				r = Hash.new
				r[zwemmer[0].name] = result_array.shuffle
				r[zwemmer[1].name] = result_array.shuffle
				#vul in en bewaar resultaten van eerste
    			page.all('.accordion-group').first.all('fieldset').each_with_index do |fld, fldi|
					choose "groep_zwemmers_attributes_#{0}_rapports_attributes_0_resultaats_attributes_#{fldi}_score_#{r[zwemmer[0].name][fldi].downcase}"
					# vink telkens eerste fout aan
					find(:css, "#groep_zwemmers_attributes_#{0}_rapports_attributes_0_resultaats_attributes_#{fldi}_fout_ids_#{proefs[fldi].fouts.first.id}").set(true)
    				
				end
				click_on "Bewaar"
				# controleer resultaten eerste zwemmer
				zwemmer[0].reload.rapports.last.resultaats.each_with_index do |res, resi|
					res.score.should == r[zwemmer[0].name][resi]
				end
				click_on "Test deze groep"
				#vul in en bewaar resultaten van 2e
				page.all('.accordion-group').last.all('fieldset').each_with_index do |fld, fldi|
					choose "groep_zwemmers_attributes_#{1}_rapports_attributes_0_resultaats_attributes_#{fldi}_score_#{r[zwemmer[1].name][fldi].downcase}"
					# vink telkens eerste fout aan
					find(:css, "#groep_zwemmers_attributes_#{1}_rapports_attributes_0_resultaats_attributes_#{fldi}_fout_ids_#{proefs[fldi].fouts.first.id}").set(true)
    				
				end
				click_on "Bewaar"
				# controleer resultaten tweede zwemmer
				zwemmer[1].reload.rapports.last.resultaats.order("id ASC").each_with_index do |res, resi|
					res.score.should == r[zwemmer[1].name][resi]
				end
				# controleer in tst pagina resultaten zwemmers
				click_on "Test deze groep"
				zwemmer.each_with_index do |z, zi|
					(0..proef_count-1).each do |i| 
						find(:css,"input#groep_zwemmers_attributes_#{zi}_rapports_attributes_0_resultaats_attributes_#{i}_score_#{r[zwemmer[zi].name][i].downcase}").should be_checked
						
					end
				end
			end

			it "should send zwemmers correctly to higher niveau with rapport from witte groep with 1 real wit, and 1 non-wit(overgestuurd)" do
				oud_overgang_aantal = Overgang.count
				witzwemmer = Groep.find(1).zwemmers.first
				visit(groep_path(3))
				nonwitzwemmer = Groep.find(3).zwemmers.first
				find(:css, "#zwemmer_check_#{nonwitzwemmer.id}").set(true)
				click_on "Stuur naar wit"
				page.should have_content "Zwemmer succesvol naar wit gestuurd."
				click_on "Paneel"
				click_on "Start testperiode"
				visit(groep_path(1))
				page.should have_content witzwemmer.name
				page.should have_content nonwitzwemmer.name
				click_link "Test deze groep"
				page.should have_button "Bewaar"
				page.all('.accordion-group').each_with_index do |el, eli|
					if el.text.include? witzwemmer.name
						el.should have_field("groep[zwemmers_attributes][#{eli}][overvlag]")
						find(:css, "#groep_zwemmers_attributes_#{eli}_overvlag").set(true)
					end
					if el.text.include? nonwitzwemmer.name
						el.should have_field("groep[zwemmers_attributes][#{eli}][overvlag]")
						find(:css, "#groep_zwemmers_attributes_#{eli}_overvlag").set(true)
					end
				end
				click_on "Bewaar"
				page.should have_content "Testresultaten succesvol opgeslagen"
				witzwemmer.reload.overvlag.should == true
				nonwitzwemmer.reload.overvlag.should == true
				page.should have_content "#{witzwemmer.name}(+)"
				page.should have_content "#{nonwitzwemmer.name}(+)"
				click_on "Wijzig deze groep"
				find(:css, "#groep_done_vlag").set(true)
				click_on "Bewaar"
				witzwemmer.reload.groep.niveau.name.should == "groen"
				nonwitzwemmer.reload.groep.niveau.name.should == "oranje"
				(oud_overgang_aantal + 2).should == Overgang.count
				nonwitzwemmer.groepvlag.should == 0
			end
			it "should correctly implement various rapport-overvlag before-save actions" do
				# zoek eerste groep met meer dan 6 zwemmers op eerte lesuur op donderdag (geen 2-wekelijkse lesuren)
				donderdag = Dag.where(name: "maandag").first
				l = Lesuur.where(dag_id: donderdag.id).first
				groep = Groep.where(lesuur_id: l.id)
				groep = groep.detect{|g| g.zwemmers.count > 4}
				niveau = groep.niveau
				volgende_niveau = Niveau.where(position: niveau.position+1).first
				# 2 zwemmers uithalen
				zwemmer1 = groep.zwemmers[0]
				zwemmer2 = groep.zwemmers[2]
				andere_zwemmers = groep.zwemmers.collect{|z| z.id} - [zwemmer1.id, zwemmer2.id]
				# voor-testen
				zwemmer1.overvlag.should_not == true
				zwemmer2.overvlag.should_not == true
				# start testperiode
				click_on "Paneel"
				click_on "Start testperiode"
				# vul rapporten in, 2 zwemmers vlaggen om over te gaan
				visit groep_path(groep)
				click_on "Test deze groep"
				page.all('.accordion-group').each_with_index do |el, eli|
					if el.text.include? zwemmer1.name
						el.should have_field("groep[zwemmers_attributes][#{eli}][overvlag]")
						find(:css, "#groep_zwemmers_attributes_#{eli}_overvlag").set(true)
					end
					if el.text.include? zwemmer2.name
						el.should have_field("groep[zwemmers_attributes][#{eli}][overvlag]")
						find(:css, "#groep_zwemmers_attributes_#{eli}_overvlag").set(true)
					end
				end
				click_on "Bewaar"
				page.should have_content "Testresultaten succesvol opgeslagen"
				# testen
				zwemmer1.reload.overvlag.should == true
				zwemmer2.reload.overvlag.should == true
				zwemmer1.rapports.count.should == 1
				zwemmer2.rapports.count.should == 1
				zwemmer1.rapports.first.overvlag.should == true
				zwemmer2.rapports.first.overvlag.should == true
				andere_zwemmers.each do |a|
					z = Zwemmer.find(a)
					z.rapports.count.should == 1
					z.overvlag.should_not == true
					z.rapports.last.overvlag.should_not == true
				end
				# testen voltooien en testperiode eindigen
				click_on "Wijzig deze groep"
				find(:css, "#groep_done_vlag").set(true)
				click_on "Bewaar"
				zwemmer1.reload.groep.niveau.should == volgende_niveau
				zwemmer2.reload.groep.niveau.should == volgende_niveau
				zwemmer1.rapports.reload.last.overvlag.should == true
				zwemmer2.rapports.reload.last.overvlag.should == true
				click_on "Paneel"
				click_on "Stop testperiode"
				# test goed overgegaan
				zwemmer1.reload.groep.niveau.should == volgende_niveau
				zwemmer2.reload.groep.niveau.should == volgende_niveau
				# nieuwe testperiode en gewoon lege rapporten bewaren - test
				click_on "Start testperiode"
				visit groep_path(zwemmer1.groep)
				click_on "Test deze groep"
				click_on "Bewaar"
				# testen of overvlag van 1e rapport nog steeds true is
				zwemmer1.reload.overvlag.should == false
				zwemmer2.reload.overvlag.should == false
				zwemmer1.rapports.count.should == 2
				zwemmer2.rapports.count.should == 2
				zwemmer1.rapports.first.overvlag.should == true
				zwemmer2.rapports.first.overvlag.should == true
				zwemmer1.rapports.last.overvlag.should_not == true
				zwemmer2.rapports.last.overvlag.should_not == true
				# testen voltooien en 2e testperiode eindigen
				click_on "Wijzig deze groep"
				find(:css, "#groep_done_vlag").set(true)
				click_on "Bewaar"
				zwemmer1.reload.groep.niveau.should == volgende_niveau
				zwemmer2.reload.groep.niveau.should == volgende_niveau
				zwemmer1.rapports.reload.first.overvlag.should == true
				zwemmer2.rapports.reload.first.overvlag.should == true
				click_on "Paneel"
				click_on "Stop testperiode"
				# testen
				zwemmer1.reload.overvlag.should == false
				zwemmer2.reload.overvlag.should == false
				zwemmer1.rapports.count.should == 2
				zwemmer2.rapports.count.should == 2
				zwemmer1.rapports.first.overvlag.should == true
				zwemmer2.rapports.first.overvlag.should == true
				zwemmer1.rapports.last.overvlag.should_not == true
				zwemmer2.rapports.last.overvlag.should_not == true
			end
			it "should correctly put rapport overvlag back to false after being true before, in same testperiode" do
				# neem eerste zwemmer in eerste gele groep
				geel = Niveau.where(name: "geel").first
				oranje = Niveau.where(name: "oranje").first
				groep = Groep.where(niveau_id: geel.id).first
				gele_zwemmer = groep.zwemmers.first
				# start testperiode
				click_on "Paneel"
				click_on "Start testperiode"
				# vul rapporten in, zwemmer vlaggen om over te gaan
				visit groep_path(groep)
				click_on "Test deze groep"
				page.all('.accordion-group').each_with_index do |el, eli|
					if el.text.include? gele_zwemmer.name
						el.should have_field("groep[zwemmers_attributes][#{eli}][overvlag]")
						find(:css, "#groep_zwemmers_attributes_#{eli}_overvlag").set(true)
					end
				end
				click_on "Bewaar"
				page.should have_content "Testresultaten succesvol opgeslagen"
				# testen
				gele_zwemmer.reload.overvlag.should == true
				gele_zwemmer.rapports.reload.count.should == 1
				gele_zwemmer.rapports.last.overvlag.should == true
				# zet rapport overvlag naar false
				visit groep_path(groep)
				click_on "Test deze groep"
				page.all('.accordion-group').each_with_index do |el, eli|
					if el.text.include? gele_zwemmer.name
						el.should have_field("groep[zwemmers_attributes][#{eli}][overvlag]")
						find(:css, "#groep_zwemmers_attributes_#{eli}_overvlag").set(false)
					end
				end
				click_on "Bewaar"
				page.should have_content "Testresultaten succesvol opgeslagen"
				# testen
				gele_zwemmer.reload.overvlag.should == false
				gele_zwemmer.rapports.reload.count.should == 1
				gele_zwemmer.rapports.last.overvlag.should == false
				# zet rapport overvlag terug naar true
				visit groep_path(groep)
				click_on "Test deze groep"
				page.all('.accordion-group').each_with_index do |el, eli|
					if el.text.include? gele_zwemmer.name
						el.should have_field("groep[zwemmers_attributes][#{eli}][overvlag]")
						find(:css, "#groep_zwemmers_attributes_#{eli}_overvlag").set(true)
					end
				end
				click_on "Bewaar"
				page.should have_content "Testresultaten succesvol opgeslagen"
				# testen
				gele_zwemmer.reload.overvlag.should == true
				gele_zwemmer.rapports.reload.count.should == 1
				gele_zwemmer.rapports.last.overvlag.should == true
				# testen voltooien en testperiode eindigen
				click_on "Wijzig deze groep"
				find(:css, "#groep_done_vlag").set(true)
				click_on "Bewaar"
				gele_zwemmer.reload.groep.niveau.should == oranje
				click_on "Paneel"
				click_on "Stop testperiode"
				# testen
				gele_zwemmer.reload.groep.niveau.should == oranje
				gele_zwemmer.reload.overvlag.should == false
				gele_zwemmer.rapports.last.overvlag.should == true
				# stuur (nu oranje) zwemmer naar rood in groepshow
				visit groep_path(gele_zwemmer.groep)
				find(:css, "#zwemmer_check_#{gele_zwemmer.id}").set(true)
				click_on "Niveau hoger"
				# testen
				page.should have_content "Zwemmer succesvol over gestuurd."
				gele_zwemmer.reload.groep.niveau.name.should == "rood"
				gele_zwemmer.reload.overvlag.should == false
				gele_zwemmer.rapports.reload.count.should == 1
				gele_zwemmer.rapports.reload.last.overvlag.should == true
			end

			it "should correctly set rapport overvlag for niet-witte zwemmer in wit die over gaat" do
				# 1e zwemmer in 1e groene groep, witte groep
				witte_groep = Groep.find(1)
				groene_groep = Groep.find(2)
				gele_groep = Groep.find(3)
				zwemmer = groene_groep.zwemmers.first
				witte_zwemmer = witte_groep.zwemmers.first
				# stuur zwemmer naar wit
				visit groep_path(groene_groep)
				find(:css, "#zwemmer_check_#{zwemmer.id}").set(true)
				click_on "Stuur naar wit"
				# testen
				zwemmer.reload.groep.should == witte_groep
				zwemmer.groepvlag.should == groene_groep.id
				# start testperiode
				click_on "Paneel"
				click_on "Start testperiode"
				# vul rapport in van zwemmer, vlag om over te gaan
				visit groep_path(witte_groep)
				click_on "Test deze groep"
				page.should have_content zwemmer.name
				page.all('.accordion-group').each_with_index do |el, eli|
					if el.text.include? zwemmer.name
						el.should have_field("groep[zwemmers_attributes][#{eli}][overvlag]")
						find(:css, "#groep_zwemmers_attributes_#{eli}_overvlag").set(true)
					end
					if el.text.include? witte_zwemmer.name
						el.should have_field("groep[zwemmers_attributes][#{eli}][overvlag]")
						find(:css, "#groep_zwemmers_attributes_#{eli}_overvlag").set(true)
					end
				end
				click_on "Bewaar"
				page.should have_content "Testresultaten succesvol opgeslagen"
				# testen
				witte_zwemmer.reload.overvlag.should == true
				witte_zwemmer.rapports.reload.last.overvlag.should == true
				zwemmer.reload.overvlag.should == true
				zwemmer.rapports.reload.last.overvlag.should == true
				# voltooi testen voor witte groep
				click_on "Wijzig deze groep"
				find(:css, "#groep_done_vlag").set(true)
				click_on "Bewaar"
				# testen
				witte_zwemmer.reload.groep.should == groene_groep
				witte_zwemmer.rapports.reload.last.overvlag.should == true
				zwemmer.reload.groep.should == gele_groep
				zwemmer.groepvlag.should == 0
				zwemmer.rapports.reload.last.overvlag.should == true
			end

			it "should correctly save proef_id of resultaat from tst" do
				# neem eerste zwemmer in eerste gele groep
				geel = Niveau.where(name: "geel").first
				groep = Groep.where(niveau_id: geel.id).first
				gele_zwemmer = groep.zwemmers.first
				# start testperiode
				click_on "Paneel"
				click_on "Start testperiode"
				# vul rapporten in, zwemmer vlaggen om over te gaan
				visit groep_path(groep)
				click_on "Test deze groep"
				click_on "Bewaar"
				page.should have_content "Testresultaten succesvol opgeslagen"
				# testen
				gele_proeven = geel.proefs.where("nietdilbeeks = ?", false).order("position")
				resultaten = gele_zwemmer.rapports.last.resultaats
				resultaten.each_with_index do |r, ri|
					r.proef_id.should == gele_proeven[ri].id
				end
			end

			it "should correctly set rapport niveau of (niet-witte in wit) zwemmer to his own niveau" do
				# zet groepen en geel-witte zwemmer
				gele_groep = Groep.find(3)
				witte_groep = Groep.find(1)
				zwemmer = gele_groep.zwemmers.first
				# stuur zwemmer nr wit
				visit groep_path(gele_groep)
				find(:css, "#zwemmer_check_#{zwemmer.id}").set(true)
				click_on "Stuur naar wit"
				# testen
				zwemmer.reload.groep.niveau.name.should == "wit"
				zwemmer.groepvlag.should == gele_groep.id
				zwemmer.groep.should == witte_groep
				# start testperiode
				click_on "Paneel"
				click_on "Start testperiode"
				# bewaar lege rapporten voor witte groep
				visit groep_path(witte_groep)
				click_on "Test deze groep"
				# testen
				click_on "Bewaar"
				zwemmer.reload.rapports.count.should == 1
				zwemmer.rapports.first.niveau.should == "geel"
			end

			it "should correctly save zwemmer school en klas in rapport" do
				# zet groep
				groep = Groep.find(2)
				# start testperiode
				click_on "Paneel"
				click_on "Start testperiode"
				# bewaar lege rapporten voor witte groep
				visit groep_path(groep)
				click_on "Test deze groep"
				click_on "Bewaar"
				# testen
				groep.zwemmers.each do |z|
					z.rapports.last.school.should == z.kla.school.name
					z.rapports.last.klas.should == z.kla.name
				end
			end
			it "should correctly save extra in rapport in tst page when extra is very long" do
				# start testperiode
				click_on "Paneel"
				click_on "Start testperiode"
				# bewaar rapporten voor eerste groep met extra als lange text
				groep = Groep.first
				zwemmer = groep.zwemmers.sort_by{ |zw| [-zw.kla.name.to_i, zw.kla.name, zw.kla.school.name, zw.name]}.first
				text = "p"*300
				text.length.should == 300
				visit groep_path(groep)
				click_on "Test deze groep"
				fill_in "groep[zwemmers_attributes][0][rapports_attributes][0][extra]", with: text 
				click_on "Bewaar"
				# testen
				zwemmer.rapports.reload.first.extra.should == (text.capitalize+".")
			end

			it "should correctly load new rapport from in zwemmer show -> Vul rapport in" do
				groep = Groep.find(2)
				groen = Niveau.where(name:"groen").first
				proeven = groen.proefs.where("nietdilbeeks = ?", false).order("position")
				zwemmer = groep.zwemmers.first
				visit zwemmer_path(zwemmer)
				#click_on "Vul rapport in"
				find("#rapport_groen").click
				page.should have_content zwemmer.name
    			page.all('fieldset').each_with_index do |fld, fldi|
    				fld.should have_content proeven[fldi].content
    				fld.should have_content "Score"
    				fld.should have_field "zwemmer[rapports_attributes][0][resultaats_attributes][#{fldi}][score]"
    				proeven[fldi].fouts.each do |f|
    					fld.should have_content f.name
    				end
    			end
    			page.should have_content "Extra commentaar"
    			page.should have_field("zwemmer[rapports_attributes][0][extra]")
    			#page.should have_content "Gaat over"
    			#page.should have_field("zwemmer[overvlag]")
    			page.should have_button "Bewaar"
    			click_on "Bewaar"
    			page.should have_content "Rapport succesvol bewaard"
    			page.should have_content zwemmer.name
			end

			it "should correctly hide zwemmers of verborgen klas in groep show, load correctly a pdf of this groep" do
				# neem eerste groene groep
				groene_groep = Groep.find(2)
				# neem eerste klas in de groep
				klas = groene_groep.zwemmers.first.kla
				# aantal zwemmers van die klas in groene_groep
				klas_zwemmers = groene_groep.zwemmers.select{|z| z.kla == klas}
				aantal = klas_zwemmers.size
				# totaal aantal zwemmers in groep
				totaal = groene_groep.omvang
				# maak klas verborgen
				klas.update_attributes(verborgen: true)
				# zwemmers mogen niet meer in groepsshow staan
				visit groep_path(groene_groep)
				klas_zwemmers.each do |z|
					page.should_not have_content z.name
				end
				groene_groep.omvang[0].should == totaal[0] - aantal
				click_on "Aanwezigheidslijst"
				page.status_code.should == 200
				visit groep_path(groene_groep)
				click_on "Evaluatielijst (wekelijks)"
				page.status_code.should == 200
			end
			it "should correctly hide zwemmers of verborgen klas in groep tst" do
				# neem eerste groene groep
				groene_groep = Groep.find(2)
				# neem eerste klas in de groep
				klas = groene_groep.zwemmers.first.kla
				# aantal zwemmers van die klas in groene_groep
				klas_zwemmers = groene_groep.zwemmers.select{|z| z.kla == klas}
				aantal = klas_zwemmers.size
				# totaal aantal zwemmers in groep
				totaal = groene_groep.omvang
				# maak klas verborgen
				klas.update_attributes(verborgen: true)
				# zwemmers mogen niet meer in groeps-tst staan
				visit groep_tst_path(groene_groep, :tweeweek => "false")
				klas_zwemmers.each do |z|
					page.should_not have_content z.name
				end
			end
			it "should correctly change badmuts kleur of zwemmer when niveau-name is changed" do
				# initialiseren
				geel = Niveau.where(name:"geel").first
				zwemmer1 = Zwemmer.all[0]
				zwemmer2 = Zwemmer.all[2]
				zwemmer3 = Zwemmer.all[10]
				zwemmer1.update_attributes(badmuts: "geel")
				zwemmer2.update_attributes(badmuts: "oranje")
				zwemmer3.update_attributes(badmuts: "geel")
				# eerste gele groep
				Groep.where(niveau_id: geel.id).first
				# geel naar zilver hernoemen
				geel.update_attributes(name: "zilver")
				# zwemmers checken
				zwemmer1.reload.badmuts.should == "zilver"
				zwemmer2.reload.badmuts.should == "oranje"
				zwemmer3.reload.badmuts.should == "zilver"
			end
			#########################################
			#  										#
			# 			javascript testing			#
			#  										#
			#########################################
=begin
			it "should load singlestat without errors",:js => true do
				Capybara.current_driver = :webkit
				visit fronts_singlestat_path
				click_on "3"
				page.should have_content "Broeders 3es"
				click_on "1 tot 6"
				page.should have_content "Broeders 1 tot 6es"
			end

			it "should fetch and show the correct autoinfo in import_form", :js => true do
				# zoek eerste rode zwemmer
				visit fronts_import_form_path
				#sleep(1.0)
				find_field('zwemmers')[:disabled].should == "true"
				#sleep(1.0)
				select "Keperke 1a", from: "klas"
				find_field('zwemmers')[:disabled].should == nil
				rode_zwemmer = Zwemmer.find((1..1000).detect{|i| Zwemmer.find(i).groep.niveau.name == "rood"})
				fill_in "zwemmers", with: "vermoesen jeff\n#{rode_zwemmer.name}\nlaakdal ernie3"
				sleep(2.0)
				page.body.should match(/<tr style="background-color: #62c462"><td style="padding: 4px;"> <i class="icon-plus"><\/i><\/td><td style="padding: 4px; font-size: 9px;">VERMOESEN JEFF<\/td><\/tr>/)
				page.body.should match(/<tr style="background-color: #9d261d"><td style="padding: 4px;"> <i class="icon-ok"><\/i><\/td><td style="padding: 4px; font-size: 9px;">#{rode_zwemmer.name}<\/td><\/tr>/)
				page.body.should match(/<tr style="background-color: #ffc40d"><td style="padding: 4px;"> <i class="icon-plus"><\/i><\/td><td style="padding: 4px; font-size: 9px;">LAAKDAL ERNIE<\/td><\/tr>/)
			end

			it "should correctly show and hide 1,2-week-radiobuttons in klas-new", :js => true do
				visit new_kla_path
				page.should_not have_content "Week"
				#find(:css, 'kla_week_0').checked.should == "checked"
				find_field('kla_week_0')[:checked].should be_true
				find_field('kla_week_1')[:checked].should_not be_true
				find(:css, "#kla_tweeweek").set(true)
				find_field('kla_week_0')[:checked].should_not be_true
				find_field('kla_week_1')[:checked].should be_true
				page.should have_content "Week"
				find(:css, "#kla_tweeweek").set(false)
				find_field('kla_week_0')[:checked].should be_true
				find_field('kla_week_1')[:checked].should_not be_true
				find(:css, "#kla_tweeweek").set(true)
				find_field('kla_week_0')[:checked].should_not be_true
				find_field('kla_week_1')[:checked].should be_true
				choose('kla_week_2')
				find_field('kla_week_0')[:checked].should_not be_true
				find_field('kla_week_1')[:checked].should_not be_true
				find_field('kla_week_2')[:checked].should be_true
			end

			it "should have correct accordion behaviour in groep-tst", :js => true do
				visit groep_tst_path(2, :tweeweek => false)
				groen = Niveau.find(2)
				proefs = groen.proefs.where("nietdilbeeks = ?", false).order("position")
				page.should_not have_content proefs.first.content
				all(".accordion-heading")[0].click
				sleep(1.0)
				page.should have_content proefs.first.content
				page.should have_content "Rapport klaar"
				all(".accordion-heading")[0].click
				sleep(1.0)
				page.should_not have_content proefs.first.content
			end
 it "should correctly show vink when rapport-klaar is checked", :js => true do
				visit groep_tst_path(2, :tweeweek => false)
				sleep(2.0)
				all(".accordion-toggle")[1].click
				sleep(2.0)
				#find(".testsel1").find(:css, "#update1").set(true)
				#find(".testsel1").find(:css, "#update1").should be_checked
				find("//input[@id='update0']").click
				all(".accordion-toggle")[1].click
				#within(".testsel1") do
				#	page.should have_selector('#update1', visible: true)
				#	sleep(2.0)
				#	find(:css, "#update1").set(true)
				#	sleep(2.0)
				#	find(:css, "#update1").should be_checked
				#end
				#select "AA", from: "groep[zwemmers_attributes][0][rapports_attributes][0][resultaats_attributes][0][score]"
				sleep(6.0)
				#find("Klaar nth-child(1)").set(true)
				#all(:xpath, "//input[@value='1']")[0].click
				#sleep(2.0)
=end
			it "should visit fronts-single_stat without errors" do 
				visit fronts_singlestat_path
				page.status_code.should == 200
			end
			it "should correctly do several javascript implementations" do
				@driver = Selenium::WebDriver.for :firefox
				#@driver = Capybara::Selenium::Driver.new(Capybara.app).browser
				#@driver =  Capybara::Session.new(:selenium, Capybara.app).driver.browser
				#Capybara.current_driver = :selenium
				#@driver = Capybara.current_session.driver.browser
    			@base_url = "http://localhost:3000/"
    			@accept_next_alert = true
    			@driver.manage.timeouts.implicit_wait = 30
    			@driver.manage.window.maximize
    			@verification_errors = []
    			@driver.get "http://localhost:3000/"
    			@driver.find_element(:id, "lesgever_name").clear
	    		@driver.find_element(:id, "lesgever_name").send_keys "diederik"
	    		@driver.find_element(:id, "lesgever_password").clear
	    		@driver.find_element(:id, "lesgever_password").send_keys "steekvoet"
	    		@driver.find_element(:name, "commit").click
	    		@driver.find_element(:link, "diederik").click
	    		@driver.find_element(:link, "Paneel").click
	    		@driver.find_element(:link, "Reset importeren").click
	    		# bevestig 
	    		@driver.switch_to.alert.accept
	    		@driver.find_element(:link, "Meer").click
	    		@driver.find_element(:link, "Niet-geüpdate zwemmers").click
	    		@driver.all(:css, 'input[type=checkbox]:checked').size.should == 0
	    		@driver.find_element(:link, "Selecteer alles").click
	    		sleep(2)
	    		@driver.all(:css, 'input[type=checkbox]:checked').size.should > 1000
	    		@driver.find_element(:link, "Selecteer niets").click
	    		@driver.all(:css, 'input[type=checkbox]:checked').size.should == 0
	    		@driver.find_element(:link, "Selecteer 6es").click
	    		@driver.all(:xpath, 'input[@class="6"]').each do |checkbox|
    				checkbox.should be_checked
				end 
				@driver.all(:css, 'input[type=checkbox]:checked').size.should == 180
	    		@driver.find_element(:link, "diederik").click
	    		@driver.find_element(:link, "Statistieken").click
	    		# Warning: verifyTextPresent may require manual changes
	    		@driver.find_element(:css, "BODY").text.should =~ /^[\s\S]*Broeders 1e leerjaar[\s\S]*$/
	    		@driver.find_element(:xpath, "(//button[@name='chart_jaar1'])[5]").click
			    !60.times{ break if (@driver.find_element(:css, "tspan").text == "Broeders 4e leerjaar" rescue false); sleep 1 }
			    @driver.find_element(:css, "span.caret").click
			    # Warning: verifyTextPresent may require manual changes
			    @driver.find_element(:css, "BODY").text.should =~ /^[\s\S]*Broeders 4e leerjaar[\s\S]*$/ 
			    @driver.find_element(:xpath, "(//button[@name='chart_jaar1'])[3]").click
			    !60.times{ break if (@driver.find_element(:css, "tspan").text == "Broeders 2e leerjaar" rescue false); sleep 1 }
			    # Warning: verifyTextPresent may require manual changes
			    @driver.find_element(:css, "BODY").text.should =~ /^[\s\S]*Broeders 2e leerjaar[\s\S]*$/ 
			    @driver.find_element(:link, "diederik").click
			    @driver.find_element(:link, "Klas importeren").click
			    Selenium::WebDriver::Support::Select.new(@driver.find_element(:id, "klas")).select_by(:text, "Keperke 2a")
			    Selenium::WebDriver::Support::Select.new(@driver.find_element(:id, "niveau")).select_by(:text, "groen")
			    @driver.find_element(:id, "userinvoer").clear
			    @driver.find_element(:id, "userinvoer").send_keys "roelandt diederik\ndhaese silke"
			    !60.times{ break if (@driver.find_element(:css, "i.icon-plus").text == "" rescue false); sleep 1 }
			    sleep(4.0)
			    # Warning: verifyTextPresent may require manual changes
			    @driver.find_element(:css, "BODY").text.should =~ /^[\s\S]*ROELANDT DIEDERIK[\s\S]*$/ 
			    # Warning: verifyTextPresent may require manual changes
			    @driver.find_element(:css, "BODY").text.should =~ /^[\s\S]*DHAESE SILKE[\s\S]*$/ 
			    @driver.get "http://localhost:3000/zwemmers/new"
			    Selenium::WebDriver::Support::Select.new(@driver.find_element(:id, "zwemmer_kla_id")).select_by(:text, "Broeders 1a")
			    element_present?(:css, "#zwemmer_groep_id > option[value=\"49\"]").should be_true 
			    element_present?(:css, "#zwemmer_groep_id > option[value=\"51\"]").should be_true 
			    element_present?(:css, "#zwemmer_groep_id > option[value=\"53\"]").should be_true 
			    Selenium::WebDriver::Support::Select.new(@driver.find_element(:id, "zwemmer_kla_id")).select_by(:text, "Don Bosco 3b")
			    element_present?(:css, "#zwemmer_groep_id > option[value=\"73\"]").should be_true 
			    element_present?(:css, "#zwemmer_groep_id > option[value=\"76\"]").should be_true 
			    @driver.get "http://localhost:3000/groeps/2/tst?tweeweek=false"
			    @driver.find_element(:id, "update0").click
			    #sleep(2.0)
			    # volgende 3 voor testen: radiobutton-label wordt groen als radio aangevinkt wordt
			    !60.times{ break if (element_present?(:xpath, "//input[@id='groep_zwemmers_attributes_0_rapports_attributes_0_resultaats_attributes_0_score_a']") rescue false); sleep 1 }
			    @driver.find_element(:xpath, "//input[@id='groep_zwemmers_attributes_0_rapports_attributes_0_resultaats_attributes_0_score_a']").click
			    @driver.find_element(:xpath, "//label[text()='A']").attribute("style").include?('color: rgb(0, 128, 0)').should be_true

			    # Warning: verifyTextPresent may require manual changes
			    !60.times{ break if (element_present?(:xpath, "//input[@id='update0']") rescue false); sleep 1 }
			    @driver.find_element(:css, "BODY").text.should =~ /^[\s\S]*afduwen van de kant in pijl en zo ver mogelijk drijven[\s\S]*$/ 
			    # Warning: verifyTextPresent may require manual changes
			    @driver.find_element(:css, "BODY").text.should =~ /^[\s\S]*Rapport klaar:[\s\S]*$/ 
			    @driver.find_element(:xpath, "//input[@id='update0']").click
			    @driver.find_element(:xpath, "//input[@id='groep_zwemmers_attributes_0_overvlag']").click
			    @driver.find_element(:id, "update0").click
			    #sleep(2.0)
			    !60.times{ break if (@driver.find_element(:css, "i.icon-ok.icon").text == "" rescue false); sleep 1 }
			    element_present?(:css, "i.icon-ok.icon").should be_true 
			    !60.times{ break if (@driver.find_element(:css, "i.icon-plus.icon").text == "" rescue false); sleep 1 }
			    element_present?(:css, "i.icon-plus.icon").should be_true 
			    @driver.quit
			end
			 def element_present?(how, what)
    			@driver.find_element(how, what)
    			true
  				rescue Selenium::WebDriver::Error::NoSuchElementError
    				false
  			end
		end
	end
end