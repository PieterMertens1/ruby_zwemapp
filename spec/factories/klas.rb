FactoryGirl.define do
  factory :kla do |f|
    f.name "4a"
    f.tweeweek false
    f.nietdilbeeks false
    f.association :lesuur
    f.association :school
  end
end