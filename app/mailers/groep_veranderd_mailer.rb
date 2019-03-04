# encoding: UTF-8
class GroepVeranderdMailer < ActionMailer::Base
  default 'Content-Transfer-Encoding' => '7bit', 
  			from: "diederikr@yahoo.com"

  def groep_veranderd(groep_van, groep_naar, zwemmer_ids)
  	@groep_van = groep_van
  	@groep_naar = groep_naar
  	@zwemmers = zwemmer_ids.collect{|id| Zwemmer.find(id)}
  	mail(to: groep_naar.lesgever.email, subject: "#{@zwemmers.size} zwemmer#{@zwemmers.size > 1 ? "s" : ""} werden in uw groep geplaatst.")
  end
end
