# == Schema Information
#
# Table name: niveaus
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  kleurcode  :string(255)
#  rang       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class NiveauTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
