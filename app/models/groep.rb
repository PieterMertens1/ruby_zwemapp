# == Schema Information
#
# Table name: groeps
#
#  id             :integer          not null, primary key
#  lesgever_id    :integer
#  lesuur_id      :integer
#  niveau_id      :integer
#  groepsproef_id :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Groep < ActiveRecord::Base
  require_dependency 'foo.rb'
  include Foo
  belongs_to :lesuur
  belongs_to :lesgever
  belongs_to :niveau
  has_many :zwemmers
  validates_presence_of :lesuur_id, :niveau_id
  accepts_nested_attributes_for :zwemmers

  def descriptive_name
    lesgevernaam = lesgever ? lesgever.name : ""
    "#{lesuur.dag.name} #{lesuur.name} #{niveau.name} #{lesgevernaam}"
  end
  def gemiddelde
    waarden = zicht_zwemmers.collect{|z| z.kla.name[0].to_i}
    gemiddelde = waarden.inject{|sum, el| sum + el}.to_f / waarden.size
  end
  def grootte
    #verborgen_klassen = Kla.where(verborgen: true).pluck(:id)
    #if niveau.name != "wit"
    #   #wits = Zwemmer.where("groep_id IN (?) AND witvlag = ?", lesuur.groeps.collect{|g| g.id}, true)
    #  wits = []
    #  witgroep = Groep.where('lesuur_id = ? AND niveau_id = ?', lesuur.id, Niveau.where('name = ?', "wit").first.id).first
    #  if witgroep
    #    if verborgen_klassen.empty?
    #      wits = Zwemmer.where('groep_id = ? AND groepvlag = ?', witgroep.id, id).count
    #    else
    #      wits = Zwemmer.where('groep_id = ? AND groepvlag = ? and kla_id not in (?)', witgroep.id, id, verborgen_klassen).count
    #    end
    #  end
    #   return (zicht_zwemmers_count + wits)
    #else
      return zicht_zwemmers_count
    #end
  end

  def omvang
      if n_tweeweek_in_zichtzwemmers != 0
      #if zicht_zwemmers.each.detect{|z| z.kla.tweeweek}
        #if niveau.name != "wit"
        #  wits = []
        #  witgroep = Groep.where('lesuur_id = ? AND niveau_id = ?', lesuur.id, Niveau.where('name = ?', "wit").first.id).first
        #  if witgroep
        #    wits = Zwemmer.where('groep_id = ? AND groepvlag = ?', witgroep.id, id)
        #  end
        #  # http://stackoverflow.com/questions/2682411/ruby-sum-corresponding-members-of-two-arrays
        #  result = [week_split(zicht_zwemmers),week_split(wits)].transpose.map {|x| x.reduce(:+)}
        #  return [result[0] + result[1], result[0] + result[2]]
        #else
          result = week_split_light(self)
          #result = week_split(zicht_zwemmers)
          return [result[0] + result[1], result[0] + result[2]]
        #end
      else
        return [grootte]
      end
  end
  def zicht_zwemmers
    verborgen_klassen = Kla.where(verborgen: true).pluck(:id)
    if verborgen_klassen.empty?
      return zwemmers.includes(:kla)
    else
      return self.zwemmers.where('kla_id not in (?)', verborgen_klassen).includes(:kla)
    end
  end
  def zicht_zwemmers_count
    verborgen_klassen = Kla.where(verborgen: true).pluck(:id)
    if verborgen_klassen.empty?
      return zwemmers.count
    else
      return self.zwemmers.where('kla_id not in (?)', verborgen_klassen).count
    end
  end
  def n_tweeweek_in_zichtzwemmers
    verborgen_klassen = Kla.where(verborgen: true).pluck(:id)
    tweeweek_klassen = Kla.where(tweeweek: true).pluck(:id)
    if verborgen_klassen.empty?
      return zwemmers.where('kla_id in (?)', tweeweek_klassen).count
    else
      return self.zwemmers.where('kla_id not in (?) and kla_id in (?)', verborgen_klassen, tweeweek_klassen).count
    end
  end
end