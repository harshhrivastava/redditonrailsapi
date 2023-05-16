class User < ApplicationRecord
    # Defining instance variables
    attr_accessor :password, :password_confirmation

    # Defining relationships with other tables
    has_many :subreddits, class_name: "Subreddit", dependent: :destroy
    has_many :comments, class_name: "Comment", through: :subreddits, dependent: :destroy

    # Creating validations
    validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: ConstantData::VALID_EMAIL_REGEX, message: "must be a valid email address" }
    validates :password, presence: true, confirmmation: {confirmation: true, message: "does not match"}
    before_save :encrypt_password
    before_update :update_author_name_in_subreddits

    # Defining methods
    def encrypt_password
        self.password_digest = BCrypt::Password.create(password)
    end

    def update_author_name_in_subreddits
        subreddits.update_all(author: username)
    end

    def verify_password(raw)
        BCrypt::Password.new(self.password_digest).is_password?(raw)
    end
end