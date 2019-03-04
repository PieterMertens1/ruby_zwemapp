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

require 'test_helper'

class ResultaatTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
