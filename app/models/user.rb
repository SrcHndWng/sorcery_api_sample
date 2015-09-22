class User < ActiveRecord::Base
  authenticates_with_sorcery!

  has_many :api_keys, dependent: :destroy
  has_one :user_department, dependent: :destroy

  validates :password, length: { minimum: 3 }
  validates :password, confirmation: true
  validates :password_confirmation, presence: true

  validates :email, uniqueness: true

  def self.login?(access_token)
    api_key = ApiKey.find_by_access_token(access_token)
    return false if !api_key || !api_key.before_expired? || !api_key.active
    return !self.find(api_key.user_id).nil?
  end

  def save_relation(department_params)
    if Department.exists?(department_params[:department_id]) && self.save
      user_department =  UserDepartment.new(user_id: self.id, department_id: department_params[:department_id])
      return user_department.save
    else
      false
    end
  end

  def update_relation(user_params, department_params)
    if Department.exists?(department_params[:department_id]) && self.update(user_params)
      return self.user_department.update(department_params)
    else
      false
    end
  end

  def activate
    if !api_key
      return ApiKey.create(user_id: self.id)
    else
      if !api_key.active
        api_key.set_active
        api_key.save
      end
      if !api_key.before_expired?
        api_key.set_expiration
        api_key.save
      end
      return api_key
    end
  end

  def inactivate
    api_key.active = false
    api_key.save
  end

  private

    def api_key
      @api_key ||= ApiKey.find_by_user_id(self.id)
    end
end
