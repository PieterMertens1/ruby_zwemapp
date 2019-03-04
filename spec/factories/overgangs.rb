FactoryGirl.define do
  factory :overgang do |f|
    f.lesgever "diederik"
    f.association :zwemmer
    f.van "geel"
    f.naar "oranje"
  end
end