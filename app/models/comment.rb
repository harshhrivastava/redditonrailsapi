class Comment < ApplicationRecord
    # Defining relationships with other tables
    has_many :comments, as: :commentable
    belongs_to :commentable, polymorphic: true

    # Creating validations
    validates :comment, presence: true

    # Defining methods
    def path
        if commentable_type == "Comment"
            parent = Comment.find(commentable_id)
            comment = Comment.find(id)
            [comment].unshift(parent.path).flatten
        elsif commentable_type == "Subreddit"
            parent = Subreddit.find(commentable_id)
            comment = Comment.find(id)
            [comment].unshift(parent).flatten
        end
    end

    def increment_replies
        replies = replies + 1
    end
end