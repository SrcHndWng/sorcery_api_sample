require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  let(:valid_attributes) {
    {email: 'duke@ggg.com', name: 'duketogo', password: 'golgo13', password_confirmation: 'golgo13'}
  }
  let(:invalid_attributes) {
    {email: 'duke@ggg.com', name: 'duketogo', password: 'x', password_confirmation: 'x'}
  }
  let(:administration_department) {
    {department_id: 10}
  }
  let(:purchase_department) {
    {department_id: 20}
  }
  let(:invalid_department) {
    {department_id: 13}
  }

  before(:all) do
    @administration = FactoryGirl.create(:Administration)
    @purchase = FactoryGirl.create(:Purchase)

    @user_1 = FactoryGirl.create(:user, {email: 'user1@test.com', name: 'user1', password: 'password', password_confirmation: 'password'})
    @user_2 = FactoryGirl.create(:user, {email: 'user2@test.com', name: 'user2', password: 'password', password_confirmation: 'password'})
    @user_3 = FactoryGirl.create(:user, {email: 'user3@test.com', name: 'user3', password: 'password', password_confirmation: 'password'})

    @user_1_api_key = FactoryGirl.create(:api_key, { user_id: @user_1.id })
    @user_2_api_key = FactoryGirl.create(:api_key, { user_id: @user_2.id })
    @user_3_api_key = FactoryGirl.create(:api_key, { user_id: @user_3.id })

    @user_1_department = FactoryGirl.create(
                          :user_department,
                          { user_id: @user_1.id, department_id: @administration.id })

    @user_2_department = FactoryGirl.create(
                          :user_department,
                          { user_id: @user_2.id, department_id: @administration.id })

    @user_3_department = FactoryGirl.create(
                          :user_department,
                          { user_id: @user_3.id, department_id: @purchase.id })

    @min_id = User.all[0]['id']
    @user_count = User.count
  end

  after(:all) do
    @administration.delete
    @purchase.delete

    @user_1.delete
    @user_2.delete
    @user_3.delete

    @user_1_api_key.delete
    @user_2_api_key.delete
    @user_3_api_key.delete

    @user_1_department.delete
    @user_2_department.delete
    @user_3_department.delete
  end

  describe "GET #index" do
    context "get users" do
      it "returns users" do
        request.env['HTTP_ACCESS_TOKEN'] = @user_1_api_key.access_token
        get :index, { format: :json }
        expect(response.status).to eq(200)

        json = JSON.parse(response.body)
        expect(json.count).to eq(3)
        expect(json[0]['id']).to be > 0
        expect(json[0]['email']).to eq('user1@test.com')
        expect(json[0]['name']).to eq('user1')
      end
    end
  end

  describe "GET #show" do
    context "get user" do
      it "returns user" do
        request.env['HTTP_ACCESS_TOKEN'] = @user_1_api_key.access_token
        get :show, { id: @min_id, format: :json }
        expect(response.status).to eq(200)

        json = JSON.parse(response.body)
        expect(json['id']).to eq(@min_id)
        expect(json['email']).to eq('user1@test.com')
        expect(json['name']).to eq('user1')
        expect(json['department']['id']).to eq(@administration.id)
        expect(json['department']['name']).to eq(@administration.name)
      end
    end

    context "not exists user" do
      it "returns nothing" do
        request.env['HTTP_ACCESS_TOKEN'] = @user_1_api_key.access_token
        not_exist_id = 0
        get :show, { id: not_exist_id, format: :json }
        expect(response.status).to eq(404)
        expect(response.body).to eq("")
      end
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new User" do
        expect {
          post :create, {format: :json, user: valid_attributes, department: administration_department}
        }.to change(User, :count).by(1)

        expect(response.status).to eq(201)

        department = User.all[3].user_department
        expect(department[:department_id]).to eq(administration_department[:department_id])
      end
    end

    context "with invalid params" do
      it "header should have bad request" do
        expect{
          post :create, {format: :json, user: invalid_attributes, department: administration_department}
        }.to change(User, :count).by(0)

        expect(response.status).to eq(400)
      end
    end

    context "with invalid user department" do
      it "header should have bad request" do
        expect{
          post :create, {format: :json, user: valid_attributes, department: invalid_department}
        }.to change(User, :count).by(0)

        expect(response.status).to eq(400)
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      it "update user" do
        request.env['HTTP_ACCESS_TOKEN'] = @user_1_api_key.access_token
        put :update, { id: @min_id, format: :json, user: valid_attributes, department: purchase_department }
        expect(response.status).to eq(200)

        json = JSON.parse(response.body)
        expect(json['id']).to eq(@min_id)
        expect(json['email']).to eq('duke@ggg.com')
        expect(json['name']).to eq('duketogo')
        expect(json['department']['id']).to eq(@purchase.id)
        expect(json['department']['name']).to eq(@purchase.name)
      end
    end

    context "with invalid params" do
      it "returns error" do
        request.env['HTTP_ACCESS_TOKEN'] = @user_1_api_key.access_token
        put :update, { id: @min_id, format: :json, user: invalid_attributes, department: purchase_department }
        expect(response.status).to eq(422)

        json = JSON.parse(response.body)
        expect(json).not_to eq(nil)
      end
    end

    context "with invalid user department" do
      it "header should have bad request" do
        request.env['HTTP_ACCESS_TOKEN'] = @user_1_api_key.access_token
        put :update, { id: @min_id, format: :json, user: valid_attributes, department: invalid_department }
        expect(response.status).to eq(422)

        json = JSON.parse(response.body)
        expect(json).not_to eq(nil)
      end
    end
  end

  describe "DELETE #delete" do
    context "delete" do
      it "delete user" do
        request.env['HTTP_ACCESS_TOKEN'] = @user_1_api_key.access_token
        delete :destroy, { id: @min_id, format: :json }
        expect(response.status).to eq(204)

        expect(User.count).to eq(@user_count - 1)
      end
    end
  end
end
