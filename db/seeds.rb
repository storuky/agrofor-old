# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

puts "Создание категории"
Category::CATEGORY.each do |title|
  FactoryGirl.create(:category, :title => title)
end

puts "Создание валют"
Currency::CURRENCY.each do |currency|
  FactoryGirl.create(:currency, {:name => currency[:name]})
end

puts "Создание размерностей"
WeightDimension::DIMENSIONS.each do |weight_dimension|
  FactoryGirl.create(:weight_dimension, {:name => weight_dimension[:name], :convert => weight_dimension[:convert]})
end

puts "Создание пользователя"
20.times do |i|
  FactoryGirl.create(:user)
  puts "Пользователь #{i}:"
end