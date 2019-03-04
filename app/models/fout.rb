# == Schema Information
#
# Table name: fouts
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  proef_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Fout < ActiveRecord::Base
validates_presence_of :name, :proef_id
validates_uniqueness_of :name, :scope => :proef_id, :message => "Bestaat al"
has_many :foutwijzings
has_many :resultaats, through: :foutwijzings
belongs_to :proef
acts_as_list :scope => :proef
end
