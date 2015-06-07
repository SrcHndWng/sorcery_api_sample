module Api
  module V1
    class UsersController < Api::V1::ApplicationBaseController
      before_action :set_user, only: [:show, :edit, :update, :destroy]
      skip_before_filter :require_valid_token, only: :create

      # GET /users.json
      def index
        @users = User.all
      end

      # GET /users/1.json
      def show
        if !@user
          respond_to do |format|
            format.json { render nothing: true, status: :not_found }
          end
        end
      end

      # POST /users.json
      def create
        respond_to do |format|
          @user = User.new(user_params)

          if @user.save
            format.json { render nothing: true, status: :created }
          else
            format.json { render nothing: true, status: :bad_request }
          end
        end
      end

      # PATCH/PUT /users/1.json
      def update
        respond_to do |format|
          if @user.update(user_params)
            format.json { render json: @user }
          else
            format.json { render json: @user.errors, status: :unprocessable_entity }
          end
        end
      end

      # DELETE /users/1.json
      def destroy
        @user.destroy
        respond_to do |format|
          format.json { head :no_content }
        end
      end

      private
        # Use callbacks to share common setup or constraints between actions.
        def set_user
          @user = User.find_by_id(params[:id])
        end

        # Never trust parameters from the scary internet, only allow the white list through.
        def user_params
          params.require(:user).permit(:email, :name, :password, :password_confirmation)
        end
    end
  end
end