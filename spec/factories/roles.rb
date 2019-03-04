FactoryGirl.define do
  factory :role do |f|
    f.name "admin"
  end
    #f.lesgever { |a| [a.association(:lesgever)] }
end