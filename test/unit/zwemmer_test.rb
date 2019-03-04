# == Schema Information
#
# Table name: zwemmers
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  kla_id     :integer
#  groep_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class ZwemmerTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
 
end
