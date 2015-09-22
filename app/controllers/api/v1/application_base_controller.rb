module Api
  module V1
    class ApplicationBaseController < ApplicationController
      before_action :require_valid_token

      private

      def require_valid_token
        access_token = request.headers[:HTTP_ACCESS_TOKEN]
        if !User.login?(access_token)
          respond_to do |format|
            format.json { render nothing: true, status: :unauthorized }
          end
        end
      end

      def administrator_only
        access_token = request.headers[:HTTP_ACCESS_TOKEN]
        api_key = ApiKey.find_by_access_token(access_token)
        user = User.find(api_key.user_id)
        if user.user_department.department_id != Department::ADMINISTRATOR
          respond_to do |format|
            format.json { render nothing: true, status: :unauthorized }
          end
        end
      end
    end
  end
end