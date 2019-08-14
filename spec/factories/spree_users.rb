FactoryGirl.define do
  factory :spree_admin, class: Spree::User do
    email 'admin@admin.com'
    password 'fakepass'
  end
end
