FactoryGirl.define do
  factory :resultaat do |f|
    f.association :rapport
    f.name "25m crawl"
    f.score "A"
  end
end