require 'spec_helper'
describe Dag do
	it "has a valid factory" do
		FactoryGirl.build(:dag).should be_valid
	end
	
	it "validates presence of name correctly" do
		FactoryGirl.build(:dag, name: "").should_not be_valid
	end

	it "sorts lesuurs of dag correctly with lessuurssorted" do
		dag = FactoryGirl.create(:dag)
		lesu1 = FactoryGirl.create(:lesuur, name: "9u20", dag_id: dag.id)
		lesu2 = FactoryGirl.create(:lesuur, name: "8u40", dag_id: dag.id)
		dag.lesuurs.count.should == 2
		dag.lesuurssorted.should == [lesu2, lesu1]
	end
end