module Api
  module V1
    class UserSessionsController < ApplicationController
      def create
        if @user = login(login_user[:email], login_user[:password])
          api_key = ApiKey.activate(@user.id)
          @access_token = api_key.access_token
        else
          respond_to do |format|
            format.json { render nothing: true, status: :not_found }
          end
        end
      end

      def destroy
      end

      private

        def login_user
          params[:user]
        end
    end
  end
end
