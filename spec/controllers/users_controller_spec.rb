require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  let(:valid_attributes) {
    {email: 'duke@ggg.com', name: 'duketogo', password: 'golgo13', password_confirmation: 'golgo13'}
  }
  let(:invalid_attributes) {
    {email: 'duke@ggg.com', name: 'duketogo', password: 'x', password_confirmation: 'x'}
  }

  describe "POST #create" do
    context "with valid params" do
      it "creates a new User" do
        expect {
          post :create, {:user => valid_attributes}
        }.to change(User, :count).by(1)

        expect(response.status).to eq(201)
      end
    end

    context "with invalid params" do
      it "header should have bad request" do
        expect{
          post :create, {:user => invalid_attributes}
        }.to change(User, :count).by(0)

        expect(response.status).to eq(400)
      end
    end
  end

end
