class ApiKey < ActiveRecord::Base
  before_create :generate_access_token, :set_expiration, :set_active
  belongs_to :user

  def before_expired?
    DateTime.now < self.expires_at
  end

  def set_active
    self.active = true
  end

  def set_expiration
    self.expires_at = DateTime.now + 1
  end

  private

    def generate_access_token
      begin
        self.access_token = SecureRandom.hex
      end while self.class.exists?(access_token: access_token)
    end
end
