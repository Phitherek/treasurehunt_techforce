class CongratulationsMailer < ApplicationMailer
    default from: "congratulations-noreply@treasurehunt-techforce-ph.herokuapp.com"
    layout "mailer"

    def congratulations_email(user)
        @user = user
        @num = User.where(treasure: true).count
        @num = @num + 1
        mail(to: @user.email, subject: "Treasure Hunt: Congratulations!")
    end
end
