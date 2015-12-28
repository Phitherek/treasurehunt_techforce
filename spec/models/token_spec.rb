require 'rails_helper'

RSpec.describe Token, type: :model do
  it { is_expected.to validate_uniqueness_of(:token) }
  it "should generate a unique token on create" do
      u = create(:user)
      t = Token.create(user: u)
      expect(t).not_to be_new_record
      expect(t.token).not_to be_blank
  end
  it "should generate a unique token on save" do
      u = create(:user)
      t = Token.new
      t.user = u
      t.save!
      expect(t.token).not_to be_blank
  end
end
