class Nieuw < ActiveRecord::Base
  attr_accessible :content, :datum, :soort
  validates_presence_of :content, :soort
end
