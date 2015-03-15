FactoryGirl.define do
  factory :catalogue do
    sequence(:catalogue_num, 100) {|n| "#{n}"}

    factory :catalogue_with_post do
      after :create do |catalogue|
        create(:post, catalogue: catalogue)
      end
    end
  end
end