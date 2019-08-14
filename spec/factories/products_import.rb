FactoryGirl.define do
  factory :products_import do
    association :user, factory: :spree_admin
  end
end
