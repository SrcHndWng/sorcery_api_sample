require 'rails_helper'

RSpec.describe Api::V1::PasswordResetsController, type: :controller do
  let(:valid_email) { ENV['MAIL_ADDRESS'] }
  let(:non_exist_email) { 'xxx@xxx.com' }

  let(:valid_password_reset_token) { '6pmRCqobTkgrgWAkcQJt' }
  let(:non_exist_password_reset_token) { 'xxxxxxxxxx' }

  let(:valid_input) {
    {password: 'password', password_confirmation: 'password'}
  }
  let(:invalid_input) {
    {password: 'password', password_confirmation: 'xxxxx'}
  }

  before(:all) do
    @valid_user = FactoryGirl.create(:user, {email: ENV['MAIL_ADDRESS'], name: 'user1', password: 'password', password_confirmation: 'password'})
    @password_reset_user = FactoryGirl.create(:user, {email: 'password@reset.co.jp', name: 'user2', password: 'password', password_confirmation: 'password', reset_password_token: '6pmRCqobTkgrgWAkcQJt'})
  end

  after(:all) do
    @valid_user.delete
    @password_reset_user.delete
  end

  describe "POST #create" do
    it "returns http success" do
      post :create, {format: :json, email: valid_email}

      expect(response.status).to eq(201)
    end

    it "non exist email" do
      post :create, {format: :json, email: non_exist_email}
      expect(response.status).to eq(404)
    end
  end

  describe "GET #edit" do
    it "returns http success" do
      get :edit, {format: :json, id: valid_password_reset_token}
      expect(response).to have_http_status(200)
    end

    it "non exist passoword_reset_token" do
      get :edit, {format: :json, id: non_exist_password_reset_token}
      expect(response.status).to eq(404)
    end
  end

  describe "PUT #update" do
    it "returns http success" do
      put :update, {format: :json, id: valid_password_reset_token, user: valid_input}
      expect(response.status).to eq(200)
    end

    it "unmatch password, password confirmation" do
      put :update, {format: :json, id: valid_password_reset_token, user: invalid_input}
      expect(response.status).to eq(406)
    end

    it "non exist passoword_reset_token" do
      put :update, {format: :json, id: non_exist_password_reset_token, user: valid_input}
      expect(response.status).to eq(404)
    end
  end

end
