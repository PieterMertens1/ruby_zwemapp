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

require 'test_helper'

class KlaTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
