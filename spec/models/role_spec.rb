require 'spec_helper'
describe Role do
	it "has a valid factory" do
		FactoryGirl.build(:role).should be_valid
	end
end