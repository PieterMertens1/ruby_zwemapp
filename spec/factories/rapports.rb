FactoryGirl.define do
  factory :rapport do |f|
    f.association :zwemmer
    f.lesgever "diederik"
    f.extra "goed gedaan!"
    f.niveau "groen"
  end
end