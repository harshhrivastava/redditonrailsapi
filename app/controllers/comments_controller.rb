class CommentsController < ApplicationController
    before_action :validate, except: [:index, :show]
    before_action :, except: [:index, :show, :create]

    def index
        data = paginate("Subreddit","Comments")
        comment = Comment.find(params[:comment_id])
        if comment[:commentable_type] == "Subreddit"
            parent = Subreddit.find(comment[:commentable_id])
        elsif comment[:commentable_type] == "Comment"
            parent = Comment.find(comment[:commentable_id])
        end
        render json: ({
            parent: parent,
            replies: data[:obj],
            current_page: data[:current_page],
            total_pages: data[:total_pages],
            path: comment.path
        })
    end

    def show
        data = paginate("Subreddit","Comment")
        comment = Comment.find(params[:comment_id])
        render json: ({
            parent: comment,
            replies: data[:obj],
            current_page: data[:current_page],
            total_pages: data[:total_pages],
            path: comment.path
        })
    end

    def create
        if params[:commentable_type].strip.titleize == "Subreddit"
            parent = Subreddit.find(params[:commentable_id])
        elsif params[:commentable_type].strip.titleize == "Comment"
            parent = Comment.find(params[:commentable_id])
        else
            render json: ({
                errors: ["Invalid 'commentable_type'. Only 'Subreddit' and 'Comment' are valid."]
            })
        end
        if parent
            comment = parent.comments.build(get_comment_params)
            comment[:user_id] = @user[:id]
            comment[:author] = @user[:username]
            if comment.save
                render json: ({
                    comment: comment
                })
            else
                render json: ({
                    errors: ["Some error occured while saving the comment."]
                })
            end
        else
            render json: ({
                errors: ["Cannot find the #{params[:commentable_type].downcase} with id: #{params[:commentable_id]}."]
            })
        end
    end

    def update
        if original_author("Comment")
            if @comment.update(get_comment_params)
                render json: ({
                    comment: @comment
                })
            else
                render json: ({
                    errors: ["Some error occured while updating the comment."]
                })
            end
        end
    end

    def destroy
        if original_author("Comment")
            if @comment.destroy
                render json: ({
                    messages: ["Comment deleted successfully."]
                })
            else
                render json: ({
                    errors: ["Some error occured while updating the comment."]
                })
            end
        end
    end

    private

    def get_comment_params
        params.permit(:comment)
    end
end