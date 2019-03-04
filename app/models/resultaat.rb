# == Schema Information
#
# Table name: resultaats
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  rapport_id :integer
#  score      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Resultaat < ActiveRecord::Base
belongs_to :rapport
has_many :foutwijzings, :dependent => :destroy
has_many :fouts, through: :foutwijzings
accepts_nested_attributes_for :foutwijzings
end
