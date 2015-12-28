FactoryGirl.define do
  factory :user do
    email { Forgery(:internet).email_address }
    after(:build) do |user|
      p = Forgery(:basic).text(exactly: 10)
      user.password = p
      user.password_confirmation = p
      user.save!
    end
  end

end
