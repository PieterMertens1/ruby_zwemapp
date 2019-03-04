# == Schema Information
#
# Table name: proefs
#
#  id         :integer          not null, primary key
#  niveau_id  :integer
#  belangrijk :boolean
#  scoreveld  :boolean
#  tekstveld  :boolean
#  nummerveld :boolean
#  content    :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Proef < ActiveRecord::Base
belongs_to :niveau
validates_presence_of :content, :niveau_id, :scoretype
validates_uniqueness_of :content, :scope => [:niveau_id, :nietdilbeeks], :message => "bestaat al"
has_many :fouts
has_many :quoterings
acts_as_list :scope => [:niveau_id, :nietdilbeeks]
end
