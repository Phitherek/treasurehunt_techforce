require 'forgery'

FactoryGirl.define do
  factory :token do
      token { Forgery(:basic).text(exactly: 30)}
      user
  end
end
