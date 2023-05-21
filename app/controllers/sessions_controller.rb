class SessionsController < ApplicationController
  def create
    if !params[:email].nil? && !params[:password].nil?
      user = User.new({email: params[:email]})
      user.clean_email
      user = User.find_by({email: user.email})
      if !user.nil?
        if user.verify_password(params[:password])
          access_token = generate_token(user, "access")
          refresh_token = generate_token(user, "refresh")
          cookies[:access_token] = {
            value: access_token,
            exp: 10.minutes.from_now,
            httponly: true
          }
          cookies[:refresh_token] = {
            value: refresh_token,
            exp: 30.days.from_now,
            httponly: true
          }
          render json: ({
            user: user,
            access_token: access_token,
            refresh_token: refresh_token
          })
        else
          render json: ({
            errors: ["Wrong credentials entered."]
          })
        end
      else
        render json: ({
          errors: ["User not found."]
        })
      end
    else
      errors = []
      if params[:email].nil?
        errors.push("Email is required.")
      end
      if params[:password].nil?
        errors.push("Password is required.")
      end
      render json: ({
        errors: errors
      })
    end
  end

  def refresh
    if cookies[:refresh_token] || params[:refresh_token]
      decoded_refresh_token = decode_token(cookies[:refresh_token])
      if !token_expired?(decoded_refresh_token)
        user = User.find(decoded_refresh_token[0]["id"])
        access_token = generate_token(user, "access")
        refresh_token = generate_token(user, "refresh")
        cookies[:access_token] = {
          value: access_token,
          exp: 10.minutes.from_now,
          httponly: true
        }
        cookies[:refresh_token] = {
          value: refresh_token,
          exp: 30.days.from_now,
          httponly: true
        }
        render json: ({
          access_token: access_token,
          refresh_token: refresh_token
        })
      else
        render json: ({
          errors: ["Refresh token has expired. Please generate a new one by logging in."]
        })
      end
    elsif cookies[:access_token] || params[:access_token]
      render json: ({
        errors: ["Refresh token not present but access token is present. Please generate a new refresh token by logging in."]
      })
    else
      render json: ({
        errors: ["Both access token and refresh token are not present. Please generate a new one by logging in."]
      })
    end
  end

  def destroy
    cookies.delete(:access_token)
    cookies.delete(:refresh_token)
    render json: ({
      messages: ["Logged out successfully."]
    })
  end
end
