class ApiKey < ActiveRecord::Base
  before_create :generate_access_token, :set_expiration, :set_active
  belongs_to :user

  def before_expired?
    DateTime.now < self.expires_at
  end

  def self.activate(user_id)
    api_key = self.find_by_user_id(user_id)
    if !api_key
      api_key = self.create(user_id: user_id) if !api_key
    else
      api_key.send(:set_active) if !api_key.active
      api_key.send(:set_expiration) if !api_key.before_expired?
      api_key.save
    end
    return api_key
  end



  private

    def generate_access_token
      begin
        self.access_token = SecureRandom.hex
      end while self.class.exists?(access_token: access_token)
    end

    def set_expiration
      self.expires_at = DateTime.now + 1
    end

  def set_active
      self.active = true
    end
end
