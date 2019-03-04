require 'spec_helper'
describe Overgang do
	it "has a valid factory" do
		FactoryGirl.build(:overgang).should be_valid
	end

	it { should belong_to(:zwemmer) }
end