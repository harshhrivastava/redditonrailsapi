class User < ApplicationRecord
    # Defining instance variables
    attr_accessor :password, :password_confirmation

    # Defining relationships with other tables
    has_many :subreddits, class_name: "Subreddit", dependent: :destroy
    has_many :comments, class_name: "Comment", through: :subreddits, dependent: :destroy

    # Creating validations
    validates :email, presence: true, uniqueness: true, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, message: "must be a valid email address" }
    validates :password, presence: true, confirmation: {confirmation: true, message: "does not match"}
    before_save :clean_email
    before_save :encrypt_password
    before_update :update_author_name_in_subreddits
    before_create :generate_confirmation_token
    after_create :send_confirmation_email

    # Defining methods
    def clean_email
        if email.include?("+")
            self.email = email.split("+").first + "@" + email.split("@").last
            self.email.downcase
        end
    end

    def generate_confirmation_token
        self.email_confirmation_token = SecureRandom.urlsafe_base64
    end

    def send_confirmation_email
        UserMailer.confirmation_mail(self).deliver_now
    end

    def encrypt_password
        self.password_digest = BCrypt::Password.create(password)
    end

    def verify_password(raw)
        BCrypt::Password.new(self.password_digest).is_password?(raw)
    end
end