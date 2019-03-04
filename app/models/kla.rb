# == Schema Information
#
# Table name: klas
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  school_id  :integer
#  lesuur_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Kla < ActiveRecord::Base
  belongs_to :lesuur
  belongs_to :school
  has_many :zwemmers
  validates_uniqueness_of :name, scope: :school_id, :message => "bestaat al"
  validates_presence_of :name, :school_id, :lesuur_id
  # http://stackoverflow.com/questions/808547/fully-custom-validation-error-message-with-rails
  # http://stackoverflow.com/questions/14814966/is-it-possible-to-sort-a-list-of-objects-depending-on-if-the-individual-objects
  #validates :name, :uniqueness => { :scope => :school_id, :message => "Deze klas bestaat al in deze school." }

  def all_rapports_klaar
  	self.zwemmers.each do |z|
  		rap = z.rapports.where("created_at > ?", Tijd.last.created_at).last
  		if rap && rap.klaar 
  			next
  		else
  			return false
  		end
  	end
  	return true
  end

  # maakt van kleuterklasnaam zoals 3ka => 0ka, waardoor ze vooraan in sort komen
  def sort_name
    if self.name.include? "k"
      return "0" + self.name.last
    else
      return self.name
    end
  end
end
