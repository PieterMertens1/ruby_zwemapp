# == Schema Information
#
# Table name: lesuurs
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  dag_id     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Lesuur < ActiveRecord::Base
  belongs_to :dag
  has_many :klas
  has_many :groeps
  validates_presence_of :name, :dag_id
  validates :name, :format => { :with => /^\d+u\d*$/, :message => 'Geef een lesuur in van volgend formaat: [cijfer]u[cijfer]'}
  def klassen_label
  	self.klas.collect{|k| k.school.name + " " + k.name + "-"}.join
  end

  def sorthelper
    hm = name.split('u')
    return ((hm[0].to_i*60) + hm[1].to_i)
  end

  def groepssorted
    self.groeps.sort_by{|g| g.niveau.position}
  end

  def nietdilbeeks
    back = self.klas.each.detect{|k| k.nietdilbeeks}
    return back ? true : false
  end
end
