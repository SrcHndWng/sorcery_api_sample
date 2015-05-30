require 'rails_helper'

RSpec.describe ApiKey, type: :model do
  let(:new_user_id) { 100 }

  before(:all) do
    @not_active_api_key = FactoryGirl.create(:api_key, { access_token: "xxxxx",
                                                         user_id: 1 })
    @not_active_api_key.active = false
    @not_active_api_key.save

    @expired_api_key = FactoryGirl.create(:api_key, { access_token: "xxxxx",
                                                      user_id: 2 })
    @expired_api_key.expires_at = DateTime.now - 1
    @expired_api_key.save
  end

  after(:all) do
    @not_active_api_key.delete
    @expired_api_key.delete
  end

  describe "activate" do
    it "ApiKey not exist." do
      ApiKey.activate(new_user_id)
      created = ApiKey.find_by_user_id(new_user_id)
      expect(created.access_token).not_to eq(nil)
      expect(created.active).to eq(true)
    end

    it "ApiKey exist, not active." do
      ApiKey.activate(@not_active_api_key.user_id)
      expect(ApiKey.where(user_id: @not_active_api_key.user_id).count).to eq(1)
      expect(ApiKey.find_by_user_id(@not_active_api_key.user_id).active).to eq(true)
      expect(ApiKey.find_by_user_id(@not_active_api_key.user_id).before_expired?).to eq(true)
    end

    it "ApiKey exist, expired." do
      ApiKey.activate(@expired_api_key.user_id)
      expect(ApiKey.where(user_id: @expired_api_key.user_id).count).to eq(1)
      expect(ApiKey.find_by_user_id(@expired_api_key.user_id).active).to eq(true)
      expect(ApiKey.find_by_user_id(@expired_api_key.user_id).before_expired?).to eq(true)
    end
  end

  describe "inactivate" do


  end
end
