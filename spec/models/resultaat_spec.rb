require 'spec_helper'
describe Resultaat do
	it "has a valid factory" do
		FactoryGirl.build(:resultaat).should be_valid
	end

	it { should have_many(:foutwijzings).dependent(:destroy) }
	it { should have_many(:fouts).through(:foutwijzings) }
end