require 'spec_helper'

describe Opmerking do
  	it "has a valid factory" do
		FactoryGirl.build(:opmerking).should be_valid
	end
	it { should validate_presence_of(:name) }
	it { should validate_uniqueness_of(:name).with_message(/bestaat al/) } 

	it "is invalid without content" do
		FactoryGirl.build(:proef, :content => nil).should_not be_valid
	end
end
