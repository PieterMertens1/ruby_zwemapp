FactoryGirl.define do
  factory :groep do |f|
  	f.done_vlag true
  	f.association :lesuur
  	f.association :niveau
  	f.association :lesgever
  end
end