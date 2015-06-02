require 'rails_helper'

RSpec.describe User, type: :model do

  before(:all) do
    @no_api_key_user = FactoryGirl.create(:user, {email: 'no_api_key@test.com', name: 'no_api_key', password: 'password', password_confirmation: 'password'})

    @not_activate_user = FactoryGirl.create(:user, {email: 'no_activate_user@test.com', name: 'no_activate_user', password: 'password', password_confirmation: 'password'})
    @not_active_api_key = FactoryGirl.create(:api_key, { user_id: @not_activate_user.id })
    @not_active_api_key.active = false
    @not_active_api_key.save

    @expired_user = FactoryGirl.create(:user, {email: 'expired@test.com', name: 'expired', password: 'password', password_confirmation: 'password'})
    @expired_api_key = FactoryGirl.create(:api_key, { user_id: @expired_user.id })
    @expired_api_key.expires_at = DateTime.now - 1
    @expired_api_key.save

    @active_user = FactoryGirl.create(:user, {email: 'active_user@test.com', name: 'active_user', password: 'password', password_confirmation: 'password'})
    @active_api_key = FactoryGirl.create(:api_key, { user_id: @active_user.id })
  end

  after(:all) do
    @no_api_key_user.delete
    @not_activate_user.delete
    @not_active_api_key.delete
    @expired_user.delete
    @expired_api_key.delete
    @active_user.delete
    @active_api_key.delete
  end

  describe "activate" do
    it "ApiKey not exist." do
      api_key = @no_api_key_user.activate
      expect(api_key).not_to eq(nil)
      created = ApiKey.find_by_user_id(@no_api_key_user.id)
      expect(created.access_token).not_to eq(nil)
      expect(created.active).to eq(true)
    end

    it "ApiKey exist, not active." do
      api_key = @not_activate_user.activate
      expect(api_key).not_to eq(nil)
      expect(ApiKey.where(user_id: @not_activate_user.id).count).to eq(1)
      expect(ApiKey.find_by_user_id(@not_activate_user.id).active).to eq(true)
      expect(ApiKey.find_by_user_id(@not_activate_user.id).before_expired?).to eq(true)
    end

    it "ApiKey exist, expired." do
      api_key = @expired_user.activate
      expect(api_key).not_to eq(nil)
      expect(ApiKey.where(user_id: @expired_user.id).count).to eq(1)
      expect(ApiKey.find_by_user_id(@expired_user.id).active).to eq(true)
      expect(ApiKey.find_by_user_id(@expired_user.id).before_expired?).to eq(true)
    end
  end

  describe "inactivate" do
    it "active api key" do
      expect(ApiKey.find_by_user_id(@active_user.id).active).to eq(true)
      @active_user.inactivate
      expect(ApiKey.find_by_user_id(@active_user.id).active).to eq(false)
    end
  end

  describe "login?" do
    it "active user" do
      result = User.login?(@active_api_key.access_token)
      expect(result).to be(true)
    end

    it "not exist access token" do
      result = User.login?('9999999999')
      expect(result).to be(false)
    end

    it "expired user" do
      result = User.login?(@expired_api_key.access_token)
      expect(result).to be(false)
    end

    it "not active user" do
      result = User.login?(@not_active_api_key.access_token)
      expect(result).to be(false)
    end
  end
end
