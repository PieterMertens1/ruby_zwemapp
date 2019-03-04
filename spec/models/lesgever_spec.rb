require 'spec_helper'
describe Lesgever do
	it "has a valid factory" do
		FactoryGirl.create(:lesgever).should be_valid
	end

	it { should validate_presence_of(:name) }

	it { should validate_uniqueness_of(:name) }

	it "should correctly return role?" do
		roleids = [FactoryGirl.create(:role, name: "admin").id]
		lesgever = FactoryGirl.create(:lesgever, role_ids: roleids)
		back = lesgever.role? :admin
		back.should == true
	end
end