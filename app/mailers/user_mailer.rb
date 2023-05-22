class UserMailer < ApplicationMailer
    def confirmation_mail(user)
        @user = user
        mail(to: @user.email, subject: "Hi #{@user.username}, please confirm your email address.")
    end
end