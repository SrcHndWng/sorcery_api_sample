FactoryGirl.define do
  factory :department do
    factory :Administration do
      id 10
      name "Administration"
    end
    factory :Purchase do
      id 20
      name "Purchase"
    end
  end
end