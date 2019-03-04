require 'spec_helper'
require 'cancan/matchers'

describe Ability do
	it "should give correct abilities to normal lesgever" do
		# https://github.com/ryanb/cancan/wiki/Testing-Abilities
		roleids = [FactoryGirl.create(:role, name: "normal").id]
		lesgever = FactoryGirl.create(:lesgever, role_ids: roleids)
		ability = Ability.new(lesgever)
		ability.should be_able_to(:manage, Groep)
		ability.should be_able_to(:manage, Zwemmer)
		ability.should_not be_able_to(:manage, School)
		ability.should_not be_able_to(:manage, Lesuur)
	end
end