# encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
    #delete alles##################################""
toonputs = Rails.env != "test" ? true : false
seedzwemmers = true
Zwemmer.delete_all
Lesgever.delete_all
Dag.delete_all
School.delete_all
Lesuur.delete_all
Kla.delete_all
Niveau.delete_all
Groep.delete_all
Proef.delete_all
Role.delete_all
Tijd.create(aantal: 5)
@roles = %w(admin master normal)
puts "roles seeding..." if toonputs
@roles.each do |r|
  Role.create(name:r)
end
@mensen = Hash.new
@mensen = {"mieke" => [2],"joke" => [2],"wesley" => [2], "frank" => [2],"ellen" => [2],"diederik" => [1],"fabi" => [2],"katia" => [2],"stef" => [2]}
 #seed lesgevers#########################################
 puts "lesgevers seeding..." if toonputs
@lesgeversids = Array.new
ActiveRecord::Base.transaction do
  @mensen.each do |naam, roleids|
    lesgever = Lesgever.new
    lesgever.name = naam
    lesgever.email = naam+"@yahoo.com"
    lesgever.password = "steekvoet"
    lesgever.password_confirmation = "steekvoet"
    lesgever.role_ids = roleids
    lesgever.save!
    @lesgeversids.push(lesgever.id)
  end
end
#seed niveaus ######################################################
puts "niveaus seeding..." if toonputs
@niveausids = Array.new
@niveaus = Hash.new
cntr=0
#rood = #ab4c3f
@niveaus = {"wit" => ["#FAF0BE", "1", {"waterbelletjes blazen"=>[[false, "score"], ["rustig blazen", "kinnetje tegen je keel houden, en belletjes recht naar beneden sturen", "oogjes rustig openen als je boven water komt", "niet in de oogjes wrijven als je boven water komt"]],
                                  "voorwerpje ophalen v/d bodem" => [[false, "score"], ["altijd belletjes blazen als je onder water gaat", "de ringetjes rustig ophalen van de bodem", "verschillende ringetjes tegelijkertijd bovenhalen"]],
                                  "vanop zwembadrand met hulp in het water springen" => [[true, "score"], ["niet vallen in het water, maar springen", "hoger en verder springen"]],
                                  "vanop zwembadrand alleen in het water springen  " => [[true, "score"], ["niet vallen in het water, maar springen", "hoger en verder springen"]],
                                  "sterretje buik + buisje met hulp" => [[false, "score"], ["gezichtje dieper in het water, kinnetje tegen je keel", "hoofdje niet tè diep in het water", "armpjes en beentjes lang en sterk", "rustig belletjes blazen"]],
                                  "sterretje buik + buisje zonder hulp" => [[false, "score"], ["gezichtje dieper in het water, kinnetje tegen je keel", "hoofdje niet tè diep in het water", "armpjes en beentjes lang en sterk", "rustig belletjes blazen"]],
                                  "sterretje buik zonder drijfmiddel" => [[false, "score"], ["gezichtje dieper in het water, kinnetje tegen je keel", "hoofdje niet tè diep in het water", "armpjes en beentjes lang en sterk", "rustig belletjes blazen"]],
                                  "sterretje rug + buisje met hulp" => [[true, "score"], ["hoofdje rustig neerleggen op het water", "rustig ademen", "buikje omhoog duwen", "armpjes en beentjes lang en sterk"]],
                                  "sterretje rug + buisje zonder hulp" => [[true, "score"], ["hoofdje rustig neerleggen op het water", "rustig ademen", "buikje omhoog duwen", "armpjes en beentjes lang en sterk"]],
                                  "sterretje rug zonder drijfmiddel" => [[true, "score"], ["hoofdje rustig neerleggen op het water", "rustig ademen", "buikje omhoog duwen", "armpjes en beentjes lang en sterk"]],
                                  "pijlen buik met plankje gezichtje in het water" => [[false, "score"], ["gezichtje dieper in het water, kinnetje tegen je keel", "pletsen met lange beentjes", "belletjes blazen tijdens het pijlen"]],
                                  "pijlglijden" => [[false, "score"], ["armpjes mooi gestrekt achter de oortjes houden (zo ben je net een zwaardvisje)", "gezichtje dieper in het water, kinnetje tegen je keel", "belletjes blazen tijdens het pijlen"]],
                                  "pijlen buik zonder drijfmiddel" => [[false, "score"], ["armpjes mooi gestrekt achter de oortjes houden (zo ben je net een zwaardvisje)", "gezichtje dieper in het water, kinnetje tegen je keel", "belletjes blazen tijdens het pijlen", "pletsen met lange beentjes"]],
                                  "pijlen rug op plankje of buisje" => [[true, "score"], ["naar boven kijken, kinnetje in de lucht steken", "buikje omhoog duwen", "pletsen met lange beentjes", "rustig ademen"]],
                                  "pijlen rug zonder drijfmiddel" => [[true, "score"], ["armpjes mooi gestrekt achter de oortjes houden (zo ben je net een zwaardvisje)", "naar boven kijken, kinnetje in de lucht steken", "buikje omhoog duwen", "pletsen met lange beentjes", "rustig ademen"]]}], 
            "groen" => ["#62c462", "2", {"afduwen van de kant in pijl en zo ver mogelijk drijven" => [[false, "score"], ["probeer met 2 benen af te duwen tegen de muur", "armen zijn niet gestrekt tegen het hoofd (pijltje maken)", "hoofd ligt niet diep genoeg in het water (armen achter de oren houden)", "benen zijn niet gestrekt", "benen gestrekt tegen elkaar houden", "probeer wat meer te blazen in het water"]],
                                   "vijf tellen pijlen op de buik met beenbeweging crawl" => [[true, "score"], ["armen zijn niet gestrekt tegen het hoofd (pijltje maken)", "hoofd ligt niet diep genoeg in het water (armen achter de oren houden)", "met gestrekte benen pletsen", "de voetjes goed gestrekt houden", "probeer wat meer te blazen in het water"]],
                                   "vijf tellen pijlen op de rug met beenbeweging crawl" => [[true, "score"], ["probeer wat meer naar het plafond te kijken", "armen in pijl achter de oren houden met de handen in het water", "buik goed naar boven blijven duwen", "met gestrekte benen pletsen", "de voetjes goed gestrekt houden"]],
                                   "draaien van buiklig naar ruglig, armen naast het lichaam" => [[false, "score"], ["hoofd niet uit het water heffen bij het draaien", "wat meer blazen bij het draaien naar de rug", "onmiddellijk naar het plafond kijken bij het draaien naar de rug", "met gestrekte benen pletsen", "de voetjes goed gestrekt houden", "op de rug de buik goed naar boven blijven duwen"]],
                                   "beenbeweging schoolslag op de plank" => [[false, "score"], ["voetjes goed blijven hoeken", "probeer wat harder te duwen op je benen", "bij het plooien niet de knieën onder de buik brengen", "benen goed sluiten op het einde"]],
                                   "beenbeweging schoolslag + ademhaling met buisje en plankje (ogen geopend boven water)" => [[false, "score"], ["voetjes goed blijven hoeken", "benen goed sluiten op het einde", "je hoofd niet te hoog uit het water brengen bij de ademhaling,de kin moet juist boven het water blijven", "probeer wat meer te blazen in het water", "eerst hoofd in het water leggen, dan de beenbeweging schoolslag uitvoeren", "denk aan het liedje: ademen-benen-blaas-blaas-blaas"]],
                                   "arm- en beenbeweging schoolslag + ademhaling met buisje (ogen geopend boven water)" => [[false, "score"], ["voetjes goed blijven hoeken", "benen goed sluiten op het einde", "je hoofd niet te hoog uit het water brengen bij de ademhaling,de kin moet juist boven het water blijven", "probeer wat meer te blazen in het water", "eerst hoofd in het water leggen, dan de beenbeweging schoolslag uitvoeren", "denk aan het liedje: ademen-benen-blaas-blaas-blaas", "armbeweging niet te groot maken", "komen ademen samen met de armbeweging", "vergeet na de ademhaling niet een mooi pijltje te maken"]],
                                   "arm- en beenbeweging schoolslag + ademhaling  in het instructiebad" => [[false, "score"], ["voetjes goed blijven hoeken", "benen goed sluiten op het einde", "je hoofd niet te hoog uit het water brengen bij de ademhaling,de kin moet juist boven het water blijven", "probeer wat meer te blazen in het water", "eerst hoofd in het water leggen, dan de beenbeweging schoolslag uitvoeren", "denk aan het liedje: ademen-benen-blaas-blaas-blaas", "armbeweging niet te groot maken", "komen ademen samen met de armbeweging", "vergeet na de ademhaling niet een mooi pijltje te maken"]],
                                   "Drie  arm- en beenbewegingen schoolslag + ademhaling  in het ondiep gedeelte van het sportbad" => [[true, "score"], ["voetjes goed blijven hoeken", "benen goed sluiten op het einde", "je hoofd niet te hoog uit het water brengen bij de ademhaling,de kin moet juist boven het water blijven", "probeer wat meer te blazen in het water", "eerst hoofd in het water leggen, dan de beenbeweging schoolslag uitvoeren", "denk aan het liedje: ademen-benen-blaas-blaas-blaas", "armbeweging niet te groot maken", "komen ademen samen met de armbeweging", "vergeet na de ademhaling niet een mooi pijltje te maken"]]}], 
            "geel" => ["#ffc40d", "3", {"pijlen met correcte  beenbeweging crawl op de buik" => [[false, "score"],["armen zijn niet gestrekt tegen het hoofd (pijltje maken)", "hoofd ligt niet diep genoeg in het water (armen achter de oren houden)", "je benen plooien teveel bij het pletsen", "de voetjes goed gestrekt houden bij het pletsen ", "probeer wat sneller te pletsen", "probeer wat meer te blazen in het water"]],
                                   "pijlen met correcte beenbeweging crawl op de rug" => [[false, "score"], ["probeer wat meer naar het plafond te kijken", "armen in pijl achter de oren houden met de handen in het water", "buik goed naar boven blijven duwen", "je benen plooien teveel bij het pletsen", "de voetjes goed gestrekt houden bij het pletsen", "probeer wat sneller te pletsen"]],
                                   "draaien van buiklig naar ruglig, armen pijl" => [[false, "score"], ["hoofd niet uit het water heffen bij het draaien", "wat meer blazen bij het draaien naar de rug", "onmiddellijk naar het plafond kijken bij het draaien naar de rug", "je benen plooien teveel bij het pletsen", "de voetjes goed gestrekt houden bij het pletsen", "probeer wat sneller te pletsen", "op de rug de buik goed naar boven blijven duwen"]],
                                   "correcte beenbeweging schoolslag + ademhaling met buisje en plankje (ogen geopend boven water)" => [[false, "score"], ["voetjes goed blijven hoeken", "benen goed sluiten op het einde", "je hoofd niet te hoog uit het water brengen bij de ademhaling,de kin moet juist boven het water blijven", "probeer wat meer te blazen in het water", "eerst hoofd in het water leggen, dan de beenbeweging schoolslag uitvoeren", "denk aan het liedje: ademen-benen-blaas-blaas-blaas"]],
                                   "correcte armbeweging schoolslag + ademhaling met buisje" => [[false, "score"], ["je hoofd niet te hoog uit het water brengen bij de ademhaling,de kin moet juist boven het water blijven", "probeer wat meer te blazen in het water", "armbeweging niet te groot maken", "komen ademen samen met de armbeweging", "vergeet niet na de ademhaling een mooi pijltje te maken"]],
                                   "breedte schoolslag met correcte arm- en beenbeweging + ademhaling + ogen geopend boven water" => [[true, "score"], ["voetjes goed blijven hoeken", "benen goed sluiten op het einde", "je hoofd niet te hoog uit het water brengen bij de ademhaling,de kin moet juist boven het water blijven", "probeer wat meer te blazen in het water", "eerst hoofd in het water leggen, dan de beenbeweging schoolslag uitvoeren", "coördinatie is nog niet juist,denk aan het liedje: ademen-benen-blaas-blaas-blaas", "armbeweging niet te groot maken", "komen ademen samen met de armbeweging", "vergeet niet na de ademhaling een mooi pijltje te maken"]],
                                   "beenbeweging crawl met zijwaartse ademhaling" => [[true, "score"], ["je benen plooien teveel bij het pletsen", "de voetjes goed gestrekt houden bij het pletsen", "probeer wat sneller te pletsen", "je hoofd draaien en niet opheffen bij de ademhaling", "je hoofd meer op het water laten liggen bij de ademhaling", "je draait teveel op je rug bij de ademhaling", "je blijft te lang liggen op de zijkant bij de ademhaling, probeer wat korter in te ademen", "probeer onderwater wat meer uit te blazen"]],
                                   "duiken vanuit kniezit  +  pijlen" => [[false, "score"], ["hoofd meer tussen de armen klemmen, mooi pijltje maken", "niet naar voor kijken maar naar beneden", "probeer wat harder af te duwen, je laat je teveel vallen", "het bekken moet hoog blijven bij het afduwen", "je duikt te diep", "probeer iets dieper te duiken", "onderwater langer blijven pijlen"]],
                                   "springen in het diepe gedeelte van het sportbad en minimum 10 m schoolslag zwemmen" =>[[true, "score"], ["voetjes goed blijven hoeken", "benen goed sluiten op het einde", "je hoofd niet te hoog uit het water brengen bij de ademhaling,de kin moet juist boven het water blijven", "probeer wat meer te blazen in het water", "eerst hoofd in het water leggen, dan de beenbeweging schoolslag uitvoeren", "coördinatie is nog niet juist,denk aan het liedje: ademen-benen-blaas-blaas-blaas", "armbeweging niet te groot maken", "komen ademen samen met de armbeweging", "vergeet niet na de ademhaling een mooi pijltje te maken", "nog bang in het diepe"]]}], 
            "oranje" =>["#f89406", "4", {"duiken vanuit kniezit" => [[false, "score"], ["hoofd meer tussen de armen klemmen, mooi pijltje maken", "niet naar voor kijken maar naar beneden", "probeer wat harder af te duwen, je laat je teveel vallen", "het bekken moet hoog blijven bij het afduwen", "je duikt te diep", "probeer iets dieper te duiken", "onderwater langer blijven pijlen"]],
                                    "duiken vanuit stand" => [[false, "score"], ["hoofd meer tussen de armen klemmen, mooi pijltje maken", "niet naar voor kijken maar naar beneden", "probeer wat harder af te duwen, je laat je teveel vallen", "het bekken moet hoog blijven bij het afduwen", "je duikt te diep", "probeer iets dieper te duiken", "onderwater langer blijven pijlen"]],
                                    "25 m correcte schoolslag" => [[false, "score"], ["denk aan je hoekjes", "benen goed sluiten op het einde", "je hoofd niet te hoog uit het water brengen bij de ademhaling,de kin moet juist boven het water blijven", "probeer wat meer te blazen in het water", "coördinatie is nog niet juist,denk aan het liedje: ademen-benen-blaas-blaas-blaas", "armbeweging niet te groot maken", "komen ademen samen met de armbeweging", "vergeet niet na de ademhaling een mooi pijltje te maken en drie tellen te blazen", "nog bang in het diepe"]],
                                    "uithouding: 100 m schoolslag" => [[true, "score"], ["denk aan je hoekjes", "benen goed sluiten op het einde", "je hoofd niet te hoog uit het water brengen bij de ademhaling,de kin moet juist boven het water blijven", "probeer wat meer te blazen in het water", "coördinatie is nog niet juist,denk aan het liedje: ademen-benen-blaas-blaas-blaas", "armbeweging niet te groot maken", "komen ademen samen met de armbeweging", "vergeet niet na de ademhaling een mooi pijltje te maken en drie tellen te blazen", "uithouding verder inoefenen", "nog bang in het diepe"]],
                                    "beenbeweging crawl met zijwaartse ademhaling" => [[false, "score"], ["je benen plooien teveel bij het pletsen", "de voeten gestrekt houden bij het pletsen", "probeer wat sneller te pletsen", "je hoofd draaien en niet opheffen bij de ademhaling", "je hoofd meer op het water laten liggen bij de ademhaling", "je draait teveel op je rug bij de ademhaling", "je blijft te lang liggen op de zijkant bij de ademhaling, probeer wat korter in te ademen", "probeer onderwater wat meer uit te blazen"]],
                                    "\"afslag-crawl\" met correcte ademhaling" => [[true, "score"], ["je benen plooien teveel bij het pletsen", "de voeten gestrekt houden bij het pletsen", "probeer wat sneller te pletsen", "je hoofd draaien en niet opheffen bij de ademhaling", "je hoofd meer op het water laten liggen bij de ademhaling", "je draait teveel op je rug bij de ademhaling", "je blijft te lang liggen op de zijkant bij de ademhaling, probeer wat korter in te ademen", "probeer onderwater wat meer uit te blazen", "handen meer insteken in het water en niet pletsen op het water", "je zwemt geen afslag,vooraan je hand tikken en dan pas met de andere arm draaien", "probeer met je armen wat verder uit te duwen tot aan de dij en dan pas met de hand uit het water te komen"]],
                                    "basis rugcrawl" => [[true, "score"], ["je benen plooien teveel bij het pletsen", "de voeten gestrekt houden bij het pletsen", "je benen liggen te diep, probeer wat meer aan de oppervlakte te pletsen", "probeer wat sneller te pletsen", "je hoofd genoeg in het water laten liggen zodat je lichaam wat meer horizontaal in het water blijft liggen", "je armbeweging is te wild, probeer je armen wat rustiger in het water te leggen", "probeer bij het insteken je hand te draaien zodat je pink eerst in het water komt"]],
                                    "op verschillende manieren van startblok springen: streksprong, halve draai, hurksprong, spreidsprong" => [[false, "score"], ["je lichaam wat meer gestrekt houden in de lucht", "probeer je benen meer te sluiten voor je in het water komt"]],
                                    "30 sec. watertrappen, handen boven water" => [[false, "score"], ["nog wat oefenen op uithouding", "probeer je ademhaling rustig te controleren"]]}], 
            "rood" => ["#9d261d", "5", {"duiken van op de startblok" => [[false, "score"], ["probeer je hoofd meer tussen de armen te klemmen en een pijl te maken", "niet naar voor kijken maar naar beneden", "probeer wat harder af te duwen, je laat je teveel vallen", "het bekken moet hoog blijven bij het afduwen", "je duikt te diep", "probeer iets dieper te duiken", "onderwater langer blijven pijlen"]],
                                  "1 min watertrappen, handen boven water" => [[false, "score"], ["nog wat oefenen op uithouding", "probeer je ademhaling rustig te controleren"]],
                                  "100 m correcte schoolslag" => [[true, "score"], ["vergeet je voeten niet te blijven hoeken bij de beenbeweging", "benen goed sluiten op het einde", "je hoofd niet te hoog uit het water brengen bij de ademhaling,de kin moet juist boven het water blijven", "probeer wat meer te blazen in het water", "je coördinatie is nog niet helemaal juist", "probeer je armbeweging niet te groot maken", "vergeet niet na de ademhaling een pijl te maken en ongeveer drie tellen te blazen en te drijven", "uithouding nog wat verder inoefenen"]],
                                  "aantal lengtes schoolslag in 15 minuten" => [[false, "aantal"], []],
                                  "25  m correcte crawl" => [[false, "score"], ["je benen plooien teveel bij het pletsen", "de voeten gestrekt houden bij het pletsen", "probeer wat sneller te pletsen", "je hoofd draaien en niet opheffen bij de ademhaling", "je hoofd meer op het water laten liggen bij de ademhaling", "je draait teveel op je rug bij de ademhaling", "je blijft te lang liggen op de zijkant bij de ademhaling, probeer wat korter in te ademen", "probeer onderwater wat meer uit te blazen", "handen meer insteken in het water en niet pletsen op het water", "je zwemt teveel afslag,vooraan je handen niet samen laten komen, probeer iets sneller te wisselen", "probeer met je armen wat verder uit te duwen tot aan de dij en dan pas met de hand uit het water te komen"]],
                                  "uithouding: 100 m crawl" => [[true, "score"], ["je benen plooien teveel bij het pletsen", "de voeten gestrekt houden bij het pletsen", "probeer wat sneller te pletsen", "je hoofd draaien en niet opheffen bij de ademhaling", "je hoofd meer op het water laten liggen bij de ademhaling", "je draait teveel op je rug bij de ademhaling", "je blijft te lang liggen op de zijkant bij de ademhaling, probeer wat korter in te ademen", "probeer onderwater wat meer uit te blazen", "handen meer insteken in het water en niet pletsen op het water", "je zwemt teveel afslag,vooraan je handen niet samen laten komen, probeer iets sneller te wisselen", "probeer met je armen wat verder uit te duwen tot aan de dij en dan pas met de hand uit het water te komen", "nog wat verder oefenen op uithouding"]],
                                  "beenbeweging rugslag" => [[false, "score"], ["je benen plooien teveel bij het pletsen", "de voeten gestrekt houden bij het pletsen", "probeer wat sneller te pletsen", "je benen liggen te diep, probeer wat meer aan de oppervlakte te pletsen"]],
                                  "armbeweging rugslag" => [[false, "score"], ["je armbeweging is te wild, probeer je armen wat rustiger in het water te leggen", "probeer bij het insteken je hand te draaien zodat je pink eerst in het water komt", "probeer je hand wat meer in te steken op schouderbreedte", "je zwemt teveel afslag, probeer met je twee armen gekruist rond te draaien"]],
                                  "25 m correcte rugslag" => [[true, "score"], ["je hoofd genoeg in het water laten liggen zodat je lichaam wat meer horizontaal in het water blijft liggen"]],
                                  "door een snorkel ademen, beenbeweging crawl" => [[false, "score"], []]}], 
            "blauw" => ["#049cdb", "6", {"aant. lengtes crawl in 15 min." => [[false, "aantal"], []],
                                  "50 m correcte rugcrawl" => [[false, "score"], ["je benen plooien teveel bij het pletsen", "de voeten gestrekt houden bij het pletsen", "probeer wat sneller te pletsen", "je benen liggen te diep, probeer wat meer aan de oppervlakte te pletsen", "je armbeweging is te wild, probeer je armen wat rustiger in het water te leggen", "probeer bij het insteken je hand te draaien zodat je pink eerst in het water komt", "probeer je hand wat meer in te steken op schouderbreedte", "je zwemt teveel afslag, probeer met je twee armen gekruist rond te draaien", "je hoofd genoeg in het water laten liggen zodat je lichaam wat meer horizontaal in het water blijft liggen"]],
                                  "startduik" => [[false, "score"], ["probeer je hoofd meer tussen de armen te klemmen en een pijl te maken", "niet naar voor kijken maar naar beneden", "probeer wat harder af te duwen, je laat je teveel vallen", "het bekken moet hoog blijven bij het afduwen", "je duikt te diep", "probeer iets dieper te duiken", "onderwater langer blijven pijlen"]],
                                  "10 m onder water zwemmen" => [[false, "score"], []],
                                  "koprol en afduwen van de kant" => [[false, "score"], ["probeer een klein bolletje te maken tijdens de koprol", "je tuimelt schuin", "probeer met je twee benen af te duwen", "probeer in pijl af te duwen"]],
                                  "reddersprong" => [[false, "score"], ["probeer wat verder te springen en niet in de hoogte", "een grote stap voorwaarts zetten en niet je benen zijwaarts spreiden als je in het water springt", "je armen goed spreiden als je in het water springt", "de romp wat meer voorwaarts buigen als je in het water komt", "je hoofd mag niet onder water gaan"]],
                                  "eendenduik" => [[false, "score"], []],
                                  "25 m schoolslag op de rug met polsen boven water" => [[false, "score"], ["knieën meer onder water houden bij de beenbeweging schoolslag"]],
                                  "in het water kledij uitdoen, luchtzak maken en met dit drijfmiddel 2 min. drijven" => [[false, "score"], []],
                                  "15 min. gekleed zwemmen" => [[false, "score"], []],
                                  "met verschillende vervoersgrepen mekaar vervoeren over 25 m" => [[false, "score"], []]}]}
ActiveRecord::Base.transaction do
  @niveaus.each do |niv, code|
    cntr += 1
    niveau = Niveau.create(name:niv, kleurcode: code[0], position:cntr, karakter:code[1])
    code[2].each do |cntnt,vldn|
      if niv != "blabla"
        proef = Proef.create(content: cntnt, niveau_id: niveau.id,belangrijk: vldn[0][0], scoretype: vldn[0][1], nietdilbeeks: false)
        vldn[1].each do |f|
          fout = Fout.create(name:f, proef_id: proef.id)
        end
        proef = Proef.create(content: cntnt + "_niet-dilbeeks", niveau_id: niveau.id,belangrijk: vldn[0][0], scoretype: vldn[0][1], nietdilbeeks: true)
        vldn[1].each do |f|
          fout = Fout.create(name:f, proef_id: proef.id)
        end
      else 
        proef = Proef.create(content: cntnt, niveau_id: niveau.id,belangrijk: vldn[0], scoretype: vldn[1])
        fout = Fout.create(name:niveau.id.to_s+proef.id.to_s+"fout1", proef_id: proef.id)
        fout = Fout.create(name:niveau.id.to_s+proef.id.to_s+"fout2", proef_id: proef.id)
      end
    end
    @niveausids.push(niveau.id)
  end
end
## opmerkingen ############################
@opmerkingen = ["Goed zo.","Prima.","Heel goed.","Doe zo verder.","Je bent er bijna, doe zo verder.","Prima inzet.","Prima gezwommen.","Prima zwemmer/ster.","Prima, naar GROEN.","Prima, naar GEEL.","Prima, naar ORANJE.","Prima, naar ROOD.","Prima, naar BLAUW.","Je speelt teveel tijdens de les.","Probeer wat meer op te letten tijdens de les.","Afwezig op testjes.", "Te jong voor het volgende niveau.", "Je hebt al keiveel bijgeleerd, goed zo!", "Je kan meer dan je denkt, durf te proberen.", "Doen, je kàn het!", "Ook al ben je bang, toch maar proberen.", "Vaak gaan zwemmen en spelen in het water.", "Niet vergeten wat je reeds geleerd hebt.", "Vaak gaan zwemmen tijdens de vakantie! Spelen in het water, maar ook oefenen wat je geleerd hebt.", "Hopelijk kan je snel terug komen zwemmen."]
puts "opmerkingen seeding..." if toonputs
ActiveRecord::Base.transaction do
  @opmerkingen.each do |op|
    Opmerking.create(name: op)
  end
end
##lesverdeling#########################################################
puts "lesverdeling seeding..." if toonputs
@lesverdeling = Hash.new
@lesverdeling["maandag"] = [[1,2,3,4,5,6], [1,2,3,4,5,6], [1,2,3,4,5,6], [1,6,2,3,4,5], [1,6,2,3,4,5]]
@lesverdeling["woensdag"] = [[1,5,6,2,3,4], [1,5,6,2,3,4], [1,5,6,2,3,4], [1,4,5,6,2,3], [1,4,5,6,2,3]]
@lesverdeling["donderdag"] = [[1,3,4,5,6,2],[1,3,4,5,6,2],[1,3,4,5,6,2],[1,2,3,4,5,6],[1,2,3,4,5,6],[1,2,3,4,5,6]]
@lesverdeling["vrijdag"] = [[1,6,2,3,4,5],[1,6,2,3,4,5],[1,6,2,3,4,5],[1,5,6,2,3,4],[1,5,6,2,3,4],[1,5,6,2,3,4],[1,4,5,6,2,3],[1,4,5,6,2,3],[1,3,4,5,6,2],[1,3,4,5,6,2]]
#klassen#####################################################

@klassen = Hash.new
@klassen["Keperke"] = {"maandag" => {"9u10" => %w(1b 2a 4a 5)}, 
                        "woensdag" => {"9u35" => %w(2b 3a 4b 6b)}, 
                        "donderdag" => {"9u20" => %w(1a 3b 6a)}}
@klassen["RC"] = {"maandag" => {"8u40" => %w(1b 3a 4a 6a), "10u50" => %w(5c), "11u20" => %w(2c 2d 4d 6d)}, 
                  "woensdag" => {"9u05" => %w(1a 6c 6e)}, 
                  "donderdag" => {"8u40" => %w(1c 3c 4c 5b 5d), "9u20" => %w(5d), "10u50" => %w(1d 3a 5a 5e), "11u20" => %w(2a 2b 3d 6b)}, 
                  "vrijdag" => {"10u00" => %w(4b)}}
@klassen["Kriebel"] = {"maandag" => {"10u50" => %w(2 4 6)}, 
                        "vrijdag" => {"10u00"=>%w(1 3 5)}}
@klassen["Sint-Alena"] = {"woensdag" => {"9u05" => %w(3)},
                          "vrijdag" => {"13u15" => %w(1a 2a 4 6a), "13u45" => %w(1b 2b 5 6b)}}
@klassen["Jongslag"] = {"woensdag" => {"11u10" => %w(3b 4a 5a 5b)},
                        "vrijdag" => {"8u55" => %w(1a 2b 6a 6b), "10u30" => %w(1b 2a 3a 4b)}}
@klassen["Don Bosco"] = {"donderdag" => {"9u50" => %w(1a 3a 3b 5a), "10u20" => %w(1b 4a 4b 6b)},
                        "vrijdag" => {"9u30" => %w(2b 2a 5b 6a)}}
@klassen["Klavertje 4"] = {"maandag" => {"9u50" => %w(1&2 2&1 3&1 4&2 5&1 6&2)}}
@klassen["Broeders"] = {"woensdag" => {"10u05" => %w(1b 2b 3a 4b&1 5b&2), "10u40" => %w(1a 2a 3b 4a&1 5a&2)}}                                               
@klassen["Vlinder"] = {"vrijdag" => {"11u40" => %w(1&1 2&2 3&1 4&2 5&1 6&2)}}
@klassen["Klimop"] = {"vrijdag" => {"11u10" => %w(3a 5a 5b 6b), "14u20" => %w(1b 2b 3b 4a), "14u50" => %w(1a 2a 4b 6a)}}
#seed dagen en lesuren###################################
puts "dagen en lesuren seeding..." if toonputs
@lesuren = {"maandag"=> %w(8u40 9u10 9u50 10u50 11u20), "dinsdag" => [], "woensdag"=> %w(9u05 9u35 10u05 10u40 11u10), "donderdag"=>%w(8u40 9u20 9u50 10u20 10u50 11u20), "vrijdag"=>%w(8u55 9u30 10u00 10u30 11u10 11u40 13u15 13u45 14u20 14u50), "zaterdag" => [], "zondag" => []}
@dagen = %w(maandag dinsdag woensdag donderdag vrijdag zaterdag zondag)
ActiveRecord::Base.transaction do
  @dagen.each do |d|
    lesuurcounter = 0
    @uren = @lesuren[d]
    dag = Dag.create(name: d)
    @uren.each do |u|
      lesuurcounter = lesuurcounter + 1
      lesuur = Lesuur.create(name: u, dag_id: dag.id)
      locmensen = @lesgeversids
      groepcounter = 0
      6.times do |ip|
        groepcounter = groepcounter + 1
        #lesgever = locmensen[rand(locmensen.size-3)]
        #locmensen = locmensen - [lesgever]
        lesgever = @lesgeversids[@lesverdeling[d][lesuurcounter-1][groepcounter-1]-1]
        Groep.create(lesgever_id: lesgever, lesuur_id:lesuur.id, niveau_id:@niveausids[ip])
      end
    end
  end
end
@dag = Hash.new
@dag['maandag'] = Dag.where("name = 'maandag'")[0].id
@dag['woensdag'] = Dag.where("name = 'woensdag'")[0].id
@dag['donderdag'] = Dag.where("name = 'donderdag'")[0].id
@dag['vrijdag'] = Dag.where("name = 'vrijdag'")[0].id

    #seed scholen#########################################
puts "scholen seeding..." if toonputs
@scholen = %w(Keperke RC Kriebel Sint-Alena Jongslag Don\ Bosco Klavertje\ 4 Broeders Vlinder Klimop)
ActiveRecord::Base.transaction do
  @scholen.each do |s|
    school = School.create(name:s)
  end
end
@lastnames = Array.new
@voornamen = Array.new
@counter = 0
def self.achternamen(lajn)   #317
  @lastnames << lajn.split(" ",2).last.strip
end
def self.voornamen(lajn)   #2944
  @voornamen << lajn.strip
end

filecontent = File.new("namen.txt", "r")
filecontent.each {|line| achternamen(line)}
filecontent.close
filecontent = File.new("voornamen.txt", "r")
filecontent.each {|line| voornamen(line)}
filecontent.close   
def self.process(klsid,lsrid)
  volnaam = @lastnames[rand(316)] + " " + @voornamen[rand(2943)].upcase
  groepid = Groep.where("lesuur_id= '#{lsrid}' and niveau_id='#{@niveausids[rand(@niveausids.size)]}'").first.id
  Zwemmer.create(name:volnaam, kla_id:klsid, groep_id:groepid)
  #puts volnaam
end
puts "klassen, zwemmers seeding..." if toonputs
ActiveRecord::Base.transaction do
  @klassen.each do |sc, dgn|
    dgn.each do |dg, urn|
      urn.each do |ur, klsn|
        klsn.each do |kls|
          #puts sc.to_s + " " + dg.to_s + " " + ur.to_s + " " +kls.to_s
          klas = kls.sub(/&/,"")
          bolean = kls[-2] == "&" ? true : false
          week = 0
          if bolean
            week = klas[-1]
            klas = klas.chop
          end
          schoolid = School.where("name = '#{sc.to_s}'").first.id
          lesuurid = Lesuur.where("dag_id='#{@dag[dg.to_s]}' and name='#{ur.to_s}'").first.id
          klas = Kla.create(name: klas.to_s, school_id: schoolid, lesuur_id: lesuurid, tweeweek: bolean, nietdilbeeks: false, week: week)
          if seedzwemmers
            10.times {|n| process(klas.id, lesuurid)}
          end
        end
       end
     end 
  end
end
puts Kla.count if toonputs
puts "done!"  if toonputs
if seedzwemmers
    #seed voor 3 rapporten van de de eerste gevonden oranje zwemmer; werkt met de standaard 2 fouten per proef. enkel voor demonstratie
  oranje_zwemmer =  Zwemmer.find((1..1000).detect {|i| Zwemmer.find(i).groep.niveau.position == 4})
  rapport_niveaus = Niveau.order("position").pluck(:name).join(":")
  ActiveRecord::Base.transaction do
    3.times do |i|
      n = Niveau.find(i+1)
      r = Rapport.create(zwemmer_id: oranje_zwemmer.id, lesgever: Lesgever.find(i+1).name, niveau: n.name, extra: "goed gedaan!", niveaus: rapport_niveaus)
      Overgang.create(zwemmer_id: oranje_zwemmer.id, lesgever: Lesgever.find(i+1).name, van: n.name, naar: Niveau.find(i+2).name)
      n.proefs.all.each do |p|
        res = Resultaat.create(rapport_id: r.id, name: p.content, score: "A")
        [0,1].sample.times do 
          Foutwijzing.create(resultaat_id: res.id, fout_id: p.fouts[[0,1].sample].id)
        end
      end
    end
  end
end
#500.times {|n| process(n)}
#puts @lesuren['vrijdag'][9]
Applicatie.create(rapportperiode: false)
news = [["goed", "25/12/12", ["Extra commentaar per zwemmer kan toegevoegd worden, zwemmer krijgt (*) achter naam", "Overgangsvlag"]],
        ["goed", "27/12/12", ["Rapport wordt nu getoond in zwemmerspagina", "Begin van statistieken", "Begin paneel voor algemene testreset"]],
        ["goed", "5/01/13", ["Naar wit sturen", "Achternaam staat voortaan vooraan"]], 
        ["goed", "8/01/13", ["Bladeren door rapporten in zwemmerspagina"]], 
        ["goed", "9/01/13", ["Klas importeren, met bijhorende speciale tekens per niveau; namen(niet in de database) zonder teken worden bij groen geplaatst", "Afzonderlijke testpagina voor 2-wekelijkse klassen"]],
        ["goed", "10/01/13", ["Niveau dalen toegevoegd", "Slide-animatie bij rapport verwijderd"]], 
        ["goed", "17/01/13", ["Vinkje toegevoegd voor ingevuld rapport in testvelden", "Rangschikking namen in groepspagina, evaluatielijst, en aanwezigheidslijst gebeurt nu volgens: aflopende klasnaam-schoolnaam-naam zwemmer", "Meer opties in schoolpagina's"]],
        ["minder", "17/01/13", ["Geen ondersteuning voor huidige vinkjes en Scrolltop in internet explorer"]],
        ["goed", "17/01/13", ["Nieuws-log toegevoegd"]],
        ["goed", "22/01/13", ["Ondersteuning voor vinkjes en scrolltop opgelost", "Herwerking niveau-, test-, en foutpagina's"]],
        ["minder", "22/01/13", ["laatste kolom op frontpagina wordt te smal weergegeven in internet explorer"]],
        ["goed", "23/01/13", ["Overgangen toegevoegd", "Verbeteringen in zwemmer pagina"]],
        ["goed", "24/01/13", ["Rapporten kunnen nu afzonderlijk per zwemmer aangemaakt en gewijzigd worden", "Testsysteem verbeterd. Bij aanvinken en bewaren van 'Testen voltooid' in 'wijzig deze groep' worden alle zwemmers die bij het invullen van de rapporten gevlagd werden om over te gaan automatisch doorgestuurd"]],
        ["minder", "24/01/13", ["Het kunnen wijzigen van een rapport zal wellicht moeten beperkt worden in de tijd, aangezien het onthouden van de verschillende testen (en bijhorende fouten) op elk moment dat een rapport wordt aangemaakt te veel zou vragen van de DB" ]],
        ["goed", "31/01/13", ["Probleem bij wit opgelost. Rapporten van zwemmers van verschillend niveau bij wit kunnen nu samen ingevuld worden, zoals in de andere groepen", "De volgorde van testen en fouten kan nu gewijzigd worden door ze te verslepen (geen bewaar-knop, wordt automatisch opgeslagen)", "Eerste versie van rapporten beschikbaar in klas bij 'Meer'-'Rapporten'", "Periodes ingevoerd. Tijdens een rapportperiode wordt de 'Test deze groep'-knop beschikbaar, maar verdwijnen de 'Stuur naar wit'-'Niveau lager'..-knoppen. De inhoud van testen en fouten (en hun volgorde) kan alleen gewijzigd worden tussen rapportperiodes", "Zoekpagina verbeterd"]],
        ["goed", "06/02/13", ["'+, +-, -'-score vervangen door letterscore (AA, A, B, C, D)", "Extra opmerkingen over zwemmers worden nu onderaan op de aanwezigheidslijst(pdf) als voetnoot weergegeven", "Er wordt nu onderaan links op het rapportblad een legende weergegeven om de letterscore te verduidelijken", "Op het paneel worden nu ook afzonderlijke aantallen voor wekelijkse-tweewekelijkse zwemmers getoond", "Bij het invullen van de rapporten wordt nu een vinkje weergegeven als 'rapport klaar' aangevinkt is, niet meer als er extra commentaar ingegeven is", "Bij het wijzigen van de klas van een zwemmer wordt die nu ook automatisch in een groep van het juiste niveau en lesuur geplaatst", "Importeersysteem vervolledigd. Wanneer alle klassen geïmporteerd zijn, worden de zwemmers die niet geüpdatet zijn weergegeven in Paneel-Meer-Niet-geüpdate zwemmers. Deze lijst kan ook als pdf uitgeprint worden zodat de namen kunnen voorgelegd worden aan de juffen en meesters voor verwijdering"]],
        ["goed", "15/02/13", ["Indentatie van fout-• op rapport-pdf toegevoegd", "Duidelijkere weergave van lesuren", "Betere validatie voor lesuurinvoer([cijfer]u[cijfer])", "Om de kans op onopzettelijke wijzigingen te verminderen gebeuren sorteerverschuivingen nu met de pijl aan de linkerkant van de tabelrij, niet meer door heel de rij", "Niveaus kunnen nu ook verschoven worden", "Gebruikers kunnen nu hun naam, email, en wachtwoord wijzigen via 'Mijn profiel'"]],
        ["goed", "20/02/13", ["Er kan nu op de frontpagina gewisseld worden tussen dilbeekse en niet-dilbeeks groepen", "'Nieuwe groep' en 'Nieuwe zwemmer' bevinden zich nu bovenaan de frontpagina onder het 'Meer'-menu", "Op het 'Nieuwe fout'-formulier wordt de test nu automatisch geselecteerd. Het selecteermenu is ook breder gemaakt voor betere leesbaarheid", "De 'testen voltooid'-checkbox in 'Wijzig deze groep' is niet meer zichtbaar tussen testperiodes", "Na het verwijderen van een lesuur wordt er nu doorverwezen naar het juiste overzicht", "Foutanalyses toegevoegd voor alle niveaus", "Het niveau van een zwemmer kan nu ook gewijzigd worden via zijn 'wijzig'-knop", "Importeren gebeurt niet meer binnen een periode, maar wordt nu gewoon gereset voor een nieuwe schooljaar. Hierdoor is is het in principe mogelijk om het hele jaar door klassen te importeren, en kunnen er geen problemen ontstaan wanneer een klas vergeten wordt"]],
        ["goed", "27/02/13", ["Wachtwoord kan nu correct gereset worden via 'wachtwoord vergeten?' op inlogpagina", "Op zwemmer-pagina wordt de niveaukleur niet meer weergegeven als achtergrond van de naam, maar als blokje naast de naam", "Er is nu ook een rapporten-pdf beschikbaar in (specifieke school)-Meer-Rapporten voor de hele school, zodat er geen pdf meer moet worden opgeslagen per klas voor het afdrukken", "Bij (specifieke school)-Meer-Nieuwe klas wordt de school nu automatisch geselecteerd", "Op het rapport wordt het niveau van een zwemmer die tijdelijk in wit zit niet meer als 'wit' weergegeven, maar als zijn correcte niveau", "Wanneer men van in het groeptest-formulier probeert terug te navigeren/een link te volgen/te herladen/het venster te sluiten verschijnt nu een waarschuwing", "In een klaspagina wordt nu per zwemmer weergegeven wanneer het laatste rapport werd aangemaakt en of het voltooid is (bv: '27/02(klaar)')"]],
        ["goed", "28/03/13", ["Klas importeren: bij het invullen van de namen verschijnt nu een 'preview' zodat nog voor het bewaren gecontroleerd kan worden of alles correct is ingegeven", "Niet-witte zwemmers in wit worden bij de testen nu over gestuurd naar het correcte niveau, niet naar groen", "De namen van verwerkte zwemmers na het importeren van een klas zijn nu klikbare links naar de zwemmers", "Zwemmers kunnen nu ook via 'wijzig' van groep veranderen, voor in het geval een zwemmer meerdere niveaus ineens moet stijgen", "Bij 'Meer'-'Statistieken' zijn nu staaf- en taartdiagrammen te bekijken met verdeling per niveau per klasjaar", "Bij het ingeven van een tweewekelijkse klas moet nu aangeduid worden in welke week ze komt(1-2)", "Op de frontpagina worden groepsgroottes voor tweewekelijkse lesuren nu per weektype gescheiden weergegeven", "In het paneel worden zwemmersaantallen nu dilbeeks/niet-dilbeeks en wekelijks/tweewekelijks gescheiden, er worden ook gemiddelde groepsgroottes weergegeven"]],
        ["goed", "18/04/13", ["Er kunnen nu afzonderlijke niet-dilbeekse testen toegevoegd worden", "Er is een handleiding toegevoegd voor het importeren van klassen en invullen van testresultaten"]],
        ["goed", "2/05/13", ["'afwezig' is toegevoegd als testresultaat", "Het is nu mogelijk om bij het invullen van de rapporten een standaardcommentaar te selecteren. Dit wordt automatisch voor de zelf in te vullen commentaar geplakt"]]]
ActiveRecord::Base.transaction do
  news.each do |n|
    Nieuw.create(soort: n[0], datum: n[1], content: n[2].join("$"))
  end
end