class Department < ActiveRecord::Base
  has_many :user_departments

  ADMINISTRATOR = 10
  PURCHASE = 20
end
