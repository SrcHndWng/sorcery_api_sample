require 'rails_helper'

RSpec.describe SampleController, type: :controller do

  describe "GET #public" do
    it "returns http success" do
      get :public
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #restrict" do
    it "returns http success" do
      get :restrict
      expect(response).to have_http_status(:success)
    end
  end

end
