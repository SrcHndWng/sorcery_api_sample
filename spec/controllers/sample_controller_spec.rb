require 'rails_helper'

RSpec.describe Api::V1::SampleController, type: :controller do
  let(:public_message) { 'public' }
  let(:restrict_message) { 'authorized' }
  let(:admin_message) { 'admin' }

  before(:all) do
    @administration = FactoryGirl.create(:Administration)
    @purchase = FactoryGirl.create(:Purchase)

    @user_admin = FactoryGirl.create(:user, {email: 'admin@test.com', name: 'admin', password: 'password', password_confirmation: 'password'})
    @user_purchase = FactoryGirl.create(:user, {email: 'purchase@test.com', name: 'purchase', password: 'password', password_confirmation: 'password'})

    @user_admin_api_key = FactoryGirl.create(:api_key, { user_id: @user_admin.id })
    @user_purchase_api_key = FactoryGirl.create(:api_key, { user_id: @user_purchase.id })

    @user_admin_department = FactoryGirl.create(
        :user_department,
        { user_id: @user_admin.id, department_id: @administration.id })
    @user_purchase_department = FactoryGirl.create(
        :user_department,
        { user_id: @user_purchase.id, department_id: @purchase.id })
  end

  after(:all) do
    @administration.delete
    @purchase.delete

    @user_admin.delete
    @user_purchase.delete

    @user_admin_api_key.delete
    @user_purchase_api_key.delete

    @user_admin_department_department.delete
  end

  describe "GET #public" do
    context "all user should success" do
      it "not login user" do
        get :public, { format: :json }
        expect(response.status).to eq(200)

        json = JSON.parse(response.body)
        expect(json['message']).to eq(public_message)
      end

      it "admin user" do
        request.env['HTTP_ACCESS_TOKEN'] = @user_admin_api_key.access_token
        get :public, { format: :json }
        expect(response.status).to eq(200)

        json = JSON.parse(response.body)
        expect(json['message']).to eq(public_message)
      end

      it "purchase user" do
        request.env['HTTP_ACCESS_TOKEN'] = @user_purchase_api_key.access_token
        get :public, { format: :json }
        expect(response.status).to eq(200)

        json = JSON.parse(response.body)
        expect(json['message']).to eq(public_message)
      end
    end
  end

  describe "GET #restrict" do
    context "not login user cannot acccess" do
      it "not login user" do
        get :restrict, { format: :json }
        expect(response.status).to eq(401)
        expect(response.body.empty?).to eq(true)
      end
    end

    context "login user success" do
      it "admin user" do
        request.env['HTTP_ACCESS_TOKEN'] = @user_admin_api_key.access_token
        get :restrict, { format: :json }
        expect(response.status).to eq(200)

        json = JSON.parse(response.body)
        expect(json['message']).to eq(restrict_message)
      end

      it "purchase user" do
        request.env['HTTP_ACCESS_TOKEN'] = @user_purchase_api_key.access_token
        get :restrict, { format: :json }
        expect(response.status).to eq(200)

        json = JSON.parse(response.body)
        expect(json['message']).to eq(restrict_message)
      end
    end
  end

  describe "GET #admin" do
    context "not login user cannot acccess" do
      it "not login user" do
        get :admin, { format: :json }
        expect(response.status).to eq(401)
        expect(response.body.empty?).to eq(true)
      end
    end

    context "purchase user cannnot access" do
      it "not admin user" do
        request.env['HTTP_ACCESS_TOKEN'] = @user_purchase_api_key.access_token
        get :admin, { format: :json }
        expect(response.status).to eq(401)
        expect(response.body.empty?).to eq(true)
      end
    end

    context "admin user should success" do
      it "admin user" do
        request.env['HTTP_ACCESS_TOKEN'] = @user_admin_api_key.access_token
        get :admin, { format: :json }
        expect(response.status).to eq(200)

        json = JSON.parse(response.body)
        expect(json['message']).to eq(admin_message)
      end
    end
  end
end