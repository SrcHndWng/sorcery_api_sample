module Api
  module V1
    class UserSessionsController < Api::V1::ApplicationBaseController
      skip_before_filter :require_valid_token, only: :create

      def create
        if @user = login(login_user[:email], login_user[:password])
          api_key = @user.activate
          @access_token = api_key.access_token
        else
          respond_to do |format|
            format.json { render nothing: true, status: :not_found }
          end
        end
      end

      def destroy
        access_token = request.headers[:HTTP_ACCESS_TOKEN]
        api_key = ApiKey.find_by_access_token(access_token)
        if api_key
          user = User.find(api_key.user_id)
          user.inactivate
          respond_to do |format|
            format.json { render nothing: true, status: :ok }
          end
        end
      end

      private

        def login_user
          params[:user]
        end
    end
  end
end
