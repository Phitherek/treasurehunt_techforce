require 'rails_helper'

RSpec.describe User, type: :model do
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_uniqueness_of(:email) }
  it { is_expected.to allow_value("test@test2.xyz").for(:email) }
  it { is_expected.not_to allow_value("test").for(:email) }
  it { is_expected.not_to allow_value("test@test2").for(:email) }
  it { is_expected.to have_secure_password }
  it "should not have found treasure on creation" do
      u = create(:user)
      expect(u.treasure?).to be false
  end
  it "should return valid treasure value" do
      u1 = create(:treasure_user)
      u2 = create(:user)
      expect(u1.treasure?).to be true
      expect(u2.treasure?).to be false
  end
end
