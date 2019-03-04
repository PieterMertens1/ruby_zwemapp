# == Schema Information
#
# Table name: groeps
#
#  id             :integer          not null, primary key
#  lesgever_id    :integer
#  lesuur_id      :integer
#  niveau_id      :integer
#  groepsproef_id :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'test_helper'

class GroepTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
