require "rails_helper"

RSpec.describe CongratulationsMailer, type: :mailer do
  describe "confirmation_email" do
    describe "with first user" do
      before(:each) do
        @user = create(:user)
        @mail = CongratulationsMailer.congratulations_email(@user)
      end
      it "should render the subject" do
        expect(@mail.subject).to eq "Treasure Hunt: Congratulations!"
      end
      it "should render the receiver email" do
        expect(@mail.to).to eq([@user.email])
      end
      it "should render the sender email" do
        expect(@mail.from).to eq(["congratulations-noreply@treasurehunt-techforce-ph.herokuapp.com"])
      end
      it "should render proper body" do
        expect(@mail.parts[0].body.decoded).to eq("Hey, you’ve found a treasure, congratulations!

You are 1 treasure hunter who has found the treasure.
")
      end
    end
    describe "with another user" do
      before(:each) do
        @user1 = create(:treasure_user)
        @user2 = create(:user)
        @mail = CongratulationsMailer.congratulations_email(@user2)
      end
      it "should render the subject" do
        expect(@mail.subject).to eq "Treasure Hunt: Congratulations!"
      end
      it "should render the receiver email" do
        expect(@mail.to).to eq([@user2.email])
      end
      it "should render the sender email" do
        expect(@mail.from).to eq(["congratulations-noreply@treasurehunt-techforce-ph.herokuapp.com"])
      end
      it "should render proper body" do
        expect(@mail.parts[0].body.decoded).to eq("Hey, you’ve found a treasure, congratulations!

You are 2 treasure hunter who has found the treasure.
")
      end
    end
  end
end
