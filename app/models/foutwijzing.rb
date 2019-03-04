# == Schema Information
#
# Table name: foutwijzings
#
#  id           :integer          not null, primary key
#  resultaat_id :integer
#  fout_id      :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Foutwijzing < ActiveRecord::Base
belongs_to :resultaat
belongs_to :fout
end
