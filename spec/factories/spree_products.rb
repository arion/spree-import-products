FactoryGirl.define do
  factory :spree_product, class: Spree::Product do
    name "MyProduct"
    price { rand(100) }
    association :shipping_category, factory: :spree_shipping_category
  end
end
