class User < ActiveRecord::Base
    validates :email, presence: true, uniqueness: true, email: true
    has_many :tokens
    has_secure_password
end
