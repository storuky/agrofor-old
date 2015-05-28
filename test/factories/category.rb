#users.rb
require 'faker'

FactoryGirl.define do
  factory :category do
    title ""

    after(:create) do |category|
      Option::OPTIONS[category.title].each do |option|
        create(:option, :category => category, :title => option)
      end
    end
  end

  factory :option do
    association     :category, factory: :category
    title           ""
  end
end