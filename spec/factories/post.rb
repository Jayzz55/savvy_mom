FactoryGirl.define do
  factory :post do
    sequence(:description, 100) {|n| "Item product number #{n}"}
    catalogue
  end
end