class Subreddit < ApplicationRecord
    # Defining relationships with other tables
    has_many :comments, as: :commentable, dependent: :destroy
    belongs_to :user, class_name: "User", foreign_key: "user_id"
    
    # Creating validations
    # validates :title, presence :true
    # validates :body, presence :true

    # Defining methods
    def increment_replies
        replies = replies + 1
    end
end