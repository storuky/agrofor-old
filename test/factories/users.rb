#users.rb
require 'faker'

FactoryGirl.define do
  factory :user do
    remote_avatar_url     {Faker::Avatar.image}
    name                  {Faker::Name.name}
    avatar                {File.open("#{Rails.root}/test/fixtures/files/#{Random.rand(1..10)}.jpeg")}
    phone                 {[Faker::PhoneNumber.cell_phone]}
    address               {Faker::Address.street_address}
    city                  {Faker::Address.city}
    lat                   {Faker::Address.latitude}
    lng                   {Faker::Address.longitude}
    company               {Faker::Company.name}
    email                 {Faker::Internet.free_email}
    password              "123123123"
    password_confirmation "123123123"
    additional            {Faker::Lorem.paragraph}
    currency              {Currency.all.sample}

    after(:create) do |user|
      10.times do |t|
        option = Random.rand(1..327)
        weight = Random.rand(10..1000)
        currency_id = user.currency_id

        photos = []
        5.times do
            photo = Photo.new
            photo.photo = File.open("#{Rails.root}/test/fixtures/files/#{Random.rand(1..10)}.jpeg")
            photos << photo
        end

        params = {
            option_id: option,
            weight: weight,
            weight_min: Random.rand(9..weight),
            weight_dimension_id: WeightDimension.all.sample.id,
            price: Faker::Commerce.price,
            user: user,
            photos: photos,
            currency_id: currency_id
        }
        create(:position, params)
      end
    end
  end

  factory :position do
    user
    title                   {Faker::Commerce.product_name}    
    description             {Faker::Lorem.paragraph}
    option_id               ""
    trade_type              {Random.rand(1..2)}
    price                   ""
    price_discount          {Random.rand(0.0..100.0)}
    weight                  ""
    weight_min              ""
    weight_dimension        ""
    address                 {Faker::Address.street_address}
    city                    {Faker::Address.city}
    lat                     {Faker::Address.latitude.to_f.round(4)}
    lng                     {Faker::Address.longitude.to_f.round(4)}
  end
end