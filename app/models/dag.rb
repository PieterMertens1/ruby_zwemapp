# == Schema Information
#
# Table name: dags
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Dag < ActiveRecord::Base
  has_many :lesuurs
  validates_presence_of :name
  def lesuurssorted
    lesuurs.sort_by{ |l| [l.sorthelper]}
  end
end
