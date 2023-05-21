class SubredditsController < ApplicationController
    before_action :validate, except: [:index, :show]

    def index
        data = paginate("Subreddit","Subreddit")
        render json: ({
            subreddits: data[:obj],
            current_page: data[:current_page],
            total_pages: data[:total_pages]
        })
    end

    def show
        if !Subreddit.where({id: params[:subreddit_id]}).empty?
            subreddit = Subreddit.find(params[:subreddit_id])
            data = paginate("Comment","Subreddit")
            render json: ({
                subreddit: subreddit,
                comments: data[:obj],
                current_page: data[:current_page],
                total_pages: data[:total_pages]
            })
            return
        else
            render json: ({
                errors: ["Couldn't find the subreddit with id #{params[:subreddit_id]}."]
            })
            return
        end
    end

    def create
        subreddit = @user.subreddits.build(get_subreddit_params)
        subreddit[:author] = @user.username
        if subreddit.save
            render json: ({
                subreddit: subreddit
            })
        else
            render json: ({
                errors: ["Some error occured while saving the subreddit."]
            })
        end
    end

    def update
        subreddit = original_author("Subreddit")
        if subreddit
            if subreddit.update(get_subreddit_params)
                render json: ({
                    subreddit: subreddit
                })
            else
                render json: ({
                    errors: ["Some error occured while updating the subreddit."]
                })
            end
        end
    end

    def destroy
        subreddit = original_author("Subreddit")
        if subreddit
            if subreddit.destroy
                render json: ({
                    messages: ["Subreddit deleted successfully."]
                })
            else
                render json: ({
                    errors: ["Some error occured while updating the subreddit."]
                })
            end
        end
    end

    private

    def get_subreddit_params
        params.permit(:title, :body)
    end
end