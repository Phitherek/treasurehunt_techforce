class Token < ActiveRecord::Base
    belongs_to :user
    validates :user_id, presence: true
    validates :token, presence: true, uniqueness: true
    before_validation :generate_token

    private

    def generate_token
        if self.token.nil?
            t = Forgery(:basic).text(exactly: 30)
            while(!Token.where(token: t).empty?)
                t = Forgery(:basic).text(exactly: 30)
            end
            self.token = t
        end
    end
end
