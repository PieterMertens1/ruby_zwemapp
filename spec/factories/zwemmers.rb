FactoryGirl.define do
  factory :zwemmer do |f|
    f.name { Faker::Name.last_name }
    f.extra "latexallergie"
    f.association :groep
    f.association :kla
  end
end