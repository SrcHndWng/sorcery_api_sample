require 'rails_helper'

RSpec.describe Api::V1::UserSessionsController, type: :controller do
  let(:valid_login_user) {
    {email: 'user1@test.com', password: 'password' }
  }
  let(:not_exist_login_user) {
    {email: 'duke@ggg.com', name: 'duketogo', password: 'x', password_confirmation: 'x'}
  }
  let(:not_exist_access_token) { 'xxxxx' }

  before(:all) do
    @user_1 = FactoryGirl.create(:user, {email: 'user1@test.com', name: 'user1', password: 'password', password_confirmation: 'password'})
    @user_2 = FactoryGirl.create(:user, {email: 'user2@test.com', name: 'user2', password: 'password', password_confirmation: 'password'})
    @user_3 = FactoryGirl.create(:user, {email: 'user3@test.com', name: 'user3', password: 'password', password_confirmation: 'password'})

    @min_id = User.all[0]['id']
  end

  after(:all) do
    @user_1.delete
    @user_2.delete
    @user_3.delete
  end

  describe "POST #create" do
    it "login success" do
      post :create, {format: :json, user: valid_login_user}
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      user = json['user']
      access_token = json['access_token']
      expect(user['id']).to eq(@min_id)
      expect(user['email']).to eq('user1@test.com')
      expect(user['name']).to eq('user1')
      expect(access_token).not_to eq(nil)
    end

    it "already login" do
      post :create, {format: :json, user: valid_login_user}
      expect(response.status).to eq(200)

      post :create, {format: :json, user: valid_login_user}
      expect(response.status).to eq(200)
      expect(ApiKey.count).to eq(1)
    end

    it "api key expired" do
      api_key = ApiKey.create(user_id: @min_id)
      api_key.expires_at = DateTime.now - 1
      api_key.save
      expect(api_key.before_expired?).to eq(false)

      post :create, {format: :json, user: valid_login_user}
      expect(response.status).to eq(200)
      expect(ApiKey.count).to eq(1)
      expect(ApiKey.find_by_user_id(@min_id).before_expired?).to eq(true)
    end

    it "not exist user" do
      post :create, {format: :json, user: not_exist_login_user}
      expect(response.status).to eq(404)
    end
  end

  describe "POST #destroy" do
    it "active user" do
      post :create, {format: :json, user: valid_login_user}
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      user = json['user']
      access_token = json['access_token']
      expect(ApiKey.find_by_user_id(user['id']).active).to eq(true)

      request.env['HTTP_ACCESS_TOKEN'] = access_token
      post :destroy
      expect(response).to have_http_status(200)
      expect(ApiKey.find_by_user_id(user['id']).active).to eq(false)
    end

    it "not exist access token" do
      request.env['HTTP_ACCESS_TOKEN'] = not_exist_access_token
      post :destroy, {format: :json}
      expect(response).to have_http_status(404)
    end
  end

end
