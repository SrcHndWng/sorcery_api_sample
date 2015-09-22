module Api
  module V1
    class SampleController < Api::V1::ApplicationBaseController
      skip_before_filter :require_valid_token, only: :public
      before_filter :administrator_only, only: :admin

      def public
        @message = 'public'
      end

      def restrict
        @message = 'authorized'
      end

      def admin
        @message = 'admin'
      end
    end
  end
end