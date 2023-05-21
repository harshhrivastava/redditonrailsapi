class ApplicationController < ActionController::Base
  # protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token
  helper_method :generate_token, :decode_token, :token_expired?, :validate, :user_signed_in?, :original_author, :paginate

  private

    def paginate(type, origin)
        if origin == "Subreddit"
            if type == "Subreddit"
                all_object = Subreddit.all
            elsif type == "Comment"
                subreddit = Subreddit.find(params[:subreddit_id])
                all_object = subreddit.comments
            end
        elsif origin == "Comment"
            comment = Comment.find(params[:comment_id])
            if type == "Comments"
                if comment[:commentable_type] == "Subreddit"
                    parent = Subreddit.find(comment[:commentable_id])
                elsif comment[:commentable_type] == "Comment"
                    parent = Comment.find(comment[:commentable_id])
                end
                all_object = parent.comments
                page = all_object.find_index(comment) / 5
            elsif type == "Comment"
                all_object = comment.comments
            end
        end
        page ||= 0
        if !params[:page].nil?
            page = params[:page].to_i - 1
        end
        total = all_object.size / 5
        if page > total
            render json: ({
                errors: ["Page number exceeded maximum number of pages."]
            })
            return
        end
        start_ind = page * 5
        end_ind = start_ind + 4
        obj = all_object[start_ind..end_ind]
        {
          obj: obj,
          current_page: page + 1,
          total_pages: total + 1
        }
    end

  def original_author(type)
      if type == "Subreddit"
          object = Subreddit.find(params[:subreddit_id])
      elsif type == "Comment"
          object = Comment.find(params[:comment_id])
      end
      if object[:user_id] != @user[:id]
        render json: ({
            errors: ["You cannot perform operations on the #{object.class.downcase} as you are not the original author."]
        })
        return
      else
        object
      end
  end

  def validate
      if cookies[:access_token] || params[:access_token]
          decoded_access_token = decode_token(cookies[:access_token])
          if !token_expired?(decoded_access_token)
              @user = User.find(decoded_access_token[0]["id"])
          else
              render json: ({
                  errors: ["Access token has expired. Please generate a new one by refreshing."]
              })
              return
          end
      elsif cookies[:refresh_token] || params[:refresh_token]
          render json: ({
              errors: ["Access token not present. Please generate a new one using refresh token."]
          })
          return
      else
          render json: ({
              errors: ["Both access token and refresh token are not present. Please generate a new one by logging in."]
          })
          return
      end
  end

  def generate_token(user, type)
    payload = {id: user[:id]}
    if type == "access"
      exp = 10.minutes.from_now.to_i
    elsif type == "refresh"
      exp = 30.days.from_now.to_i
    end
    JWT.encode(payload, Rails.application.secrets.secret_key_base, "HS256", {expiry: exp})
  end

  def decode_token(token)
    begin
      JWT.decode(token, Rails.application.secrets.secret_key_base, true, {algorithm: "HS256"})
    rescue JWT::DecodeError
      render json: ({
        errors: ["Error occured while decoding the token."]
      })
      return
    rescue JWT::ExpiredSignature
      render json: ({
        errors: ["Signature has expired."]
      })
      return
    end
  end

  def token_expired?(token)
    if !token[1]["expiry"].nil?
        Time.at(token[1]["expiry"]) < Time.now
    else
        true
    end
  end

  def user_signed_in?
    !cookies[:access_token].nil? || !params[:access_token].nil?
  end
end
