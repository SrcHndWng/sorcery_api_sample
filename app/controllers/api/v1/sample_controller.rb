module Api
  module V1
    class SampleController < Api::V1::ApplicationBaseController
      skip_before_filter :require_valid_token, only: :public

      def public
        @message = 'public'
      end

      def restrict
        @message = 'authorized'
      end
    end
  end
end