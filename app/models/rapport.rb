# == Schema Information
#
# Table name: rapports
#
#  id         :integer          not null, primary key
#  zwemmer_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Rapport < ActiveRecord::Base
	belongs_to :zwemmer
	has_many :resultaats, :dependent => :destroy
	accepts_nested_attributes_for :resultaats
	before_save :cap_extra
	def cap_extra
		# http://stackoverflow.com/questions/2646709/capitalize-only-first-character-of-string-and-leave-others-alone-rails
		if self.extra != ""
			self.extra = self.extra.to_s.slice(0,1).capitalize + self.extra.to_s.slice(1..-1)
			self.extra = self.extra + "." if (self.extra != "" && ![".","?","!"].include?(self.extra[-1]))
		end
	end
	def fout_count
		acc = 0
		self.resultaats.each{|r| acc += r.fouts.count}
		return acc
	end
end
