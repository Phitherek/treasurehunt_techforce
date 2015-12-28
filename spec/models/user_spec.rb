require 'rails_helper'

RSpec.describe User, type: :model do
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_uniqueness_of(:email) }
  it { is_expected.to allow_value("test@test2.xyz").for(:email) }
  it { is_expected.not_to allow_value("test").for(:email) }
  it { is_expected.not_to allow_value("test@test2").for(:email) }
  it { is_expected.to have_secure_password }
end
