require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  let(:valid_attributes) {
    {email: 'duke@ggg.com', name: 'duketogo', password: 'golgo13', password_confirmation: 'golgo13'}
  }
  let(:invalid_attributes) {
    {email: 'duke@ggg.com', name: 'duketogo', password: 'x', password_confirmation: 'x'}
  }

  before(:all) do
    @user_1 = FactoryGirl.create(:user, {email: 'user1@test.com', name: 'user1', password: 'password', password_confirmation: 'password'})
    @user_2 = FactoryGirl.create(:user, {email: 'user2@test.com', name: 'user2', password: 'password', password_confirmation: 'password'})
    @user_3 = FactoryGirl.create(:user, {email: 'user3@test.com', name: 'user3', password: 'password', password_confirmation: 'password'})

    @min_id = User.all[0]['id']
    @user_count = User.count
  end

  after(:all) do
    @user_1.delete
    @user_2.delete
    @user_3.delete
  end

  describe "GET #index" do
    context "get users" do
      it "returns users" do
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
        get :show, { id: @min_id, format: :json }
        expect(response.status).to eq(200)

        json = JSON.parse(response.body)
        expect(json['id']).to eq(@min_id)
        expect(json['email']).to eq('user1@test.com')
        expect(json['name']).to eq('user1')
      end
    end

    context "not exists user" do
      it "returns nothing" do
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
          post :create, {format: :json, user: valid_attributes}
        }.to change(User, :count).by(1)

        expect(response.status).to eq(201)
      end
    end

    context "with invalid params" do
      it "header should have bad request" do
        expect{
          post :create, {format: :json, user: invalid_attributes}
        }.to change(User, :count).by(0)

        expect(response.status).to eq(400)
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      it "update user" do
        put :update, { id: @min_id, format: :json, user: valid_attributes }
        expect(response.status).to eq(200)

        json = JSON.parse(response.body)
        expect(json['id']).to eq(@min_id)
        expect(json['email']).to eq('duke@ggg.com')
        expect(json['name']).to eq('duketogo')
      end
    end

    context "with invalid params" do
      it "returns error" do
        put :update, { id: @min_id, format: :json, user: invalid_attributes }
        expect(response.status).to eq(422)

        json = JSON.parse(response.body)
        expect(json).not_to eq(nil)
      end
    end
  end

  describe "DELETE #delete" do
    context "delete" do
      it "delete user" do
        delete :destroy, { id: @min_id, format: :json }
        expect(response.status).to eq(204)

        expect(User.count).to eq(@user_count - 1)
      end
    end
  end
end
