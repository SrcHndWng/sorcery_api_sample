class Api::V1::PasswordResetsController < Api::V1::ApplicationBaseController
  skip_before_filter :require_valid_token

  def create
    @user = User.find_by_email(params[:email])

    if @user
      respond_to do |format|
        @user.deliver_reset_password_instructions!
        format.json { render nothing: true, status: :created }
      end
    else
      respond_to do |format|
        format.json { render nothing: true, status: :not_found }
      end
    end
  end

  def edit
    if set_token_user_from_params?
      respond_to do |format|
        format.json { render nothing: true, status: :ok }
      end
    else
      respond_to do |format|
        format.json { render nothing: true, status: :not_found }
      end
    end
  end

  def update
    if set_token_user_from_params?
      @user.password_confirmation = params[:user][:password_confirmation]

      if @user.change_password!(params[:user][:password])
        respond_to do |format|
          format.json { render nothing: true, status: :ok }
        end
      else
        respond_to do |format|
          format.json { render nothing: true, status: :not_acceptable }
        end
      end
    else
      respond_to do |format|
        format.json { render nothing: true, status: :not_found }
      end
    end
  end

  private
    def set_token_user_from_params?
      @token = params[:id]
      @user = User.load_from_reset_password_token(params[:id])
      return !@user.blank?
    end
end
