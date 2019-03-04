FactoryGirl.define do
  factory :lesgever do |f|
    f.name {Faker::Name.name} # f.name {Faker::Name.last_name}
    f.email {Faker::Internet.email}
  	f.password "password"
  	f.password_confirmation "password"
  end
end