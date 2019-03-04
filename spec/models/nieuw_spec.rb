require 'spec_helper'

describe Nieuw do
	
	it { should validate_presence_of(:content) }
	it { should validate_presence_of(:soort) }

end