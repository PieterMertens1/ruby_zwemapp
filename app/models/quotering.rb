class Quotering < ActiveRecord::Base
  attr_accessible :content, :proef_id
  belongs_to :proef
end
