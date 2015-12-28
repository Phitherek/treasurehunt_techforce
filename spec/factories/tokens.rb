require 'forgery'

FactoryGirl.define do
  factory :token do
      token { Forgery(:basic).text(exactly: 30)}
  end

  factory :empty_token do
      token nil
  end
end
