class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :dagen
  def dagen
    @dagen = %w(maandag woensdag donderdag vrijdag)
    @niveaus = Niveau.all
   end
  def get_freqs(klassen)
    freqs = Hash.new
    Niveau.order(:position).each do |n| 
      freqs[n.position] = 0
    end
    klassen.each do |klas|
      klas.zwemmers.each do |z|
        pos = (z.groepvlag > 0 ? Groep.find(z.groepvlag).niveau.position : z.groep.niveau.position)
        freqs[pos] += 1
      end
    end
    return freqs
  end
  def get_picture_freqs(picture_id, school_id, jaar, freqs)
    picture = Picture.find(picture_id)
    case school_id
      when ""
        return "", freqs.values
      when "wd"
        message = "#{picture.created_at.strftime("%d/%m/%y")} wekelijks dilbeeks #{jaar}es"
        if jaar == "1 tot 6"
          freqs = picture.totals["categories"]["cat_dilb_week"].values.collect{|e| e.values}.transpose.map {|x| x.reduce(:+)}
        else
          freqs = picture.totals["categories"]["cat_dilb_week"][jaar == "3k" ? 0 : jaar.to_i].values
        end
        return message, freqs
      when "2d"
        message = "#{picture.created_at.strftime("%d/%m/%y")} 2-wekelijks dilbeeks #{jaar}es"
        if jaar == "1 tot 6"
          freqs = picture.totals["categories"]["cat_dilb_tweeweek"].values.collect{|e| e.values}.transpose.map {|x| x.reduce(:+)}
        else
          freqs = picture.totals["categories"]["cat_dilb_tweeweek"][jaar == "3k" ? 0 : jaar.to_i].values
        end
        return message, freqs
      else
        school = School.find(school_id.to_i)
        message = "#{picture.created_at.strftime("%d/%m/%y")} #{school.name} #{jaar}es"
        if jaar == "1 tot 6"
          freqs = picture.totals["schools"][school_id.to_i].values.collect{|e| e.values}.transpose.map {|x| x.reduce(:+)}
        else
          freqs = picture.totals["schools"][school_id.to_i][jaar == "3k" ? 0 : jaar.to_i].values
        end
        return message, freqs
      end
  end
  def zwemmer_shift(actie, groep, zwemmerids, extra = 0)
    return result = case actie
      when :over
        doelniveau = Niveau.where("position = ?", groep.niveau.position + extra).first
        doelgroeps = Groep.where("lesuur_id = ? AND niveau_id = ?", groep.lesuur.id, doelniveau.id)
        if not doelgroeps.size==0
          if doelgroeps.size < 2 
            dlgroep = doelgroeps.first
            bam = "kleiner dan 2" + doelniveau.name + " " + doelgroeps.to_s
          else
            min = 7
            dlgroep = doelgroeps.first
            doelgroeps.each do |d|
              if d.gemiddelde < min 
                min = d.gemiddelde
                dlgroep = d
              end
            end
          end
          bam = "groter dan 1" + doelniveau.name + " " + doelgroeps.to_s
        else
          bam = "boeb" + doelniveau.name + " " + doelgroeps.to_s
          dlgroep = Groep.create(niveau_id: doelniveau.id, lesuur_id: groep.lesuur.id)
        end
        netovervlag = Applicatie.last.rapportperiode? ? true : false
        zwmrs = Zwemmer.where(:id => zwemmerids).update_all(:groep_id => dlgroep.id, :overvlag => false, :netovervlag => netovervlag)
        zwemmerids.each do |zid|
          Overgang.create(zwemmer_id: zid, van: groep.niveau.name, naar: dlgroep.niveau.name, kleurcode_van: groep.niveau.kleurcode, kleurcode_naar: dlgroep.niveau.kleurcode, lesgever: groep.lesgever.name)
        end
        return dlgroep, zwmrs
      when :inwit_zelfde_kleur
        dlgroep = Groep.find(extra)
        zwmrs = Zwemmer.where(:id => zwemmerids).update_all(:groepvlag => dlgroep.id)
      when :zelfde_kleur
        dlgroep = Groep.find(extra)
        zwmrs = Zwemmer.where(:id => zwemmerids).update_all(:groep_id => dlgroep.id)
        zwmrs
      when :inwitover
        zwmrs = Array.new
        zwemmerids.each do |z|
          zwemmer = Zwemmer.find(z)
          doelniveau = Niveau.where("position = ?", Groep.find(zwemmer.groepvlag).niveau.position + extra).first
          doelgroeps = Groep.where("lesuur_id = ? AND niveau_id = ?", groep.lesuur.id, doelniveau.id)
          if not doelgroeps.size==0
            if doelgroeps.size < 2 
              dlgroep = doelgroeps.first
              bam = "kleiner dan 2" + doelniveau.name + " " + doelgroeps.to_s
            else
              min = 7
              doelgroeps.each do |d|
                if d.gemiddelde < min 
                  min = d.gemiddelde
                  dlgroep = d
                end
              end
            end
          else
            dlgroep = Groep.create(niveau_id: doelniveau.id, lesuur_id: groep.lesuur.id)
          end
          grpvlag = zwemmer.groepvlag
          # aangezien inwitover zowel gebruikt wordt om vanuit de groep-show over te sturen als om met de testen over te sturen, moet eerst bepaald worden wat de waarde moet zijn van overvlag
          netovervlag = Applicatie.last.rapportperiode? ? true : false
          #zwmr = zwemmer.update_attributes(:groep_id => dlgroep.id, :overvlag => false, :netovervlag => netovervlag, groepvlag: 0)
          # hier wordt update_all gebruikt met altijd slechts 1 zwemmer. update_attributes (wat normaal is voor 1 record) kan niet gebruikt worden, omdat dan de after_update callback zou uitgevoerd worden (mag geen zet_rapport_overvlag uitgevoerd worden)
          zwmr = Zwemmer.where(:id => zwemmer.id).update_all(:groep_id => dlgroep.id, :overvlag => false, :netovervlag => netovervlag, groepvlag: 0)
          Overgang.create(zwemmer_id: z, van: Groep.find(grpvlag).niveau.name, naar: dlgroep.niveau.name, kleurcode_van: Groep.find(grpvlag).niveau.kleurcode, kleurcode_naar: dlgroep.niveau.kleurcode, lesgever: groep.lesgever.name)
          zwmrs.push(zwmr)
        end
        return dlgroep, zwmrs
    end
  end
   #https://github.com/ryanb/cancan/wiki/changing-defaults
   #http://starqle.com/articles/rails-3-authentication-and-authorization-with-devise-and-cancan-part-2/
   #http://zyphdesignco.com/blog/manage-users-with-devise-and-cancan
   #cancan gebruikt default een "current_user", volgende functie vervangt deze door "current_lesgever"
   #in elke actie in elke controller wordt bv "authorize! :index, Lesgever" gebruikt voor authorisation
  def current_ability
    @current_ability ||= Ability.new(current_lesgever)
  end
  rescue_from CanCan::AccessDenied do |exception|
    #redirect_to root_url, :alert => exception.message
    redirect_to root_url, :alert => "U bent niet bevoegd deze pagina te bekijken."
  end
  
end
