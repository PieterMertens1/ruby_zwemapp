FactoryGirl.define do
  factory :foutwijzing do |f|
    f.association :resultaat
    f.association :fout
  end
end