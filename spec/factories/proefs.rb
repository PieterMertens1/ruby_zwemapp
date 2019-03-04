FactoryGirl.define do
  factory :proef do |f|
    f.content "breedte schoolslag"
    f.association :niveau
    f.scoretype "score"
    f.nietdilbeeks false
  end
end