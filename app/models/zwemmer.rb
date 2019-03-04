# encoding: UTF-8
# == Schema Information
#
# Table name: zwemmers
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  kla_id     :integer
#  groep_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Zwemmer < ActiveRecord::Base
  require 'data'
  include Datums

  belongs_to :groep
  belongs_to :kla
  has_many :rapports, :dependent => :destroy
  has_many :overgangs
  validates_presence_of :name, :kla_id, :groep_id
  accepts_nested_attributes_for :rapports
  before_save :hoofdletters 
  after_update :zet_rapport_overvlag
  #before_update :hoofdletters
 def self.search(search)
  if search != ""
    zoekstring = search.strip.upcase
    zoekstring.gsub!(/[ëéêâàäçïíüöôèû]/,"ë" => "Ë", "é" => "É", "ê" => "Ê", "â" => "Â","à" => "À", "ä" => "Ä","ç" => "Ç", "ï" => "Ï", "í" => "Í", "ü" => "Ü", "ö" => "Ö", "ô" => "Ô","è" => "È", "û" => "Û")
    where('name LIKE ?', "%#{zoekstring}%").order(:name)
  else
    #scoped
    return []
  end
 end
 # http://stackoverflow.com/questions/5083084/rails-force-field-uppercase-and-validate-uniquely
 # http://api.rubyonrails.org/classes/ActiveRecord/Callbacks.html
 # http://stackoverflow.com/questions/3916931/rails-3-invalid-multibyte-char-us-ascii
 # http://www.ruby-doc.org/core-1.9.3/String.html#method-i-gsub
 def hoofdletters
  self.name.upcase!
  self.name.gsub!(/[ëéêâàäçïíüöôèû]/,"ë" => "Ë", "é" => "É", "ê" => "Ê", "â" => "Â","à" => "À", "ä" => "Ä","ç" => "Ç", "ï" => "Ï", "í" => "Í", "ü" => "Ü", "ö" => "Ö", "ô" => "Ô","è" => "È", "û" => "Û")
  end

  def zet_rapport_overvlag
    if self.rapports.count > 0 && self.overvlag_changed?
      self.rapports.last.update_attributes(overvlag: self.overvlag) if !self.overvlag.nil?
    end
    return true
  end
  def overgangen_since_september
    ret_array = []
    array_voor_dubbel = []
    laatste_rapport = rapports.last
    niveau_laatste_rapport = Niveau.where(name: laatste_rapport.niveau).first
    overgangs.sort_by(&:created_at).select{|o| o.created_at > vorige_september}.each do |overgang|
      van = Niveau.where(name: overgang.van).first.position
      naar = Niveau.where(name: overgang.naar).first
      if naar 
        naar = naar.position
        if (van < naar) && !array_voor_dubbel.include?([van,naar])# && (naar <= niveau_laatste_rapport.position)
          array_voor_dubbel.push([van,naar])
          previous = [overgang.created_at.strftime("%d-%m-%Y"), overgang.van, overgang.naar]
          ret_array.push(previous)
        end
      end
    end
    return fill_up(ret_array)
  end
  def fill_up(array)
    niveaus = {}
    niveaus_reverse = {}
    Niveau.all.each do |n| 
      niveaus[n.position] = n.name
      niveaus_reverse[n.name] = n.position
    end
    new_array = []
    for i in 0..(array.length-1)
      new_array.push(array[i])
      if array[i+1]
        naar_huidig = niveaus_reverse[array[i][2]]
        van_next = niveaus_reverse[array[i+1][1]]
        Rails::logger.debug "niveaus: #{niveaus.inspect}"
        Rails::logger.debug "niveaus reverse: #{niveaus_reverse.inspect}"
        Rails::logger.debug "array i: #{array[i].inspect}"
        Rails::logger.debug "array + i: #{array[i+1].inspect}"
        Rails::logger.debug "naar huidig: #{naar_huidig}"
        Rails::logger.debug "van_next: #{van_next}"
        if van_next != naar_huidig
          (naar_huidig..(van_next-1)).each do |n|
            new_array.push([array[i+1][0], niveaus[n], niveaus[n+1]])
          end
        end
      end
    end
    return new_array
  end
end