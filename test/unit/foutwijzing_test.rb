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

require 'test_helper'

class FoutwijzingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
