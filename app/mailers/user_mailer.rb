class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.reset_password_email.subject
  #

  def reset_password_email(user)
    @user = User.find user.id
    @url = "http://0.0.0.0:8888/path?id=" + @user.reset_password_token
    mail(:to => user.email,  :subject => "Your password has been reset")
  end
end
