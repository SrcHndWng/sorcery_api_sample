class UserDepartment < ActiveRecord::Base
  belongs_to :user
  belongs_to :department
end
