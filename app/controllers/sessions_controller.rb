class SessionsController < ApplicationController
  def create
    if User.exists({email: params[:email]})
      user = User.find({email: params[:email]})
      if user.verify_password(params[:password])
        # access_token = generate_token(user, "access")
        # refresh_token = generate_token(user, "refresh")
        # render json: ({
        #   user: user,
        #   access_token: access_token,
        #   refresh_token: refresh_token
        # })
        render json: ({
          success: true
        })
      else
        render json: ({
          error: "Wrong credentials entered."
        })
      end
    else
      render json: ({
        error: "User not found."
      })
    end
  end

  def refresh
    if params[:refresh_token].present?
      decoded_refresh_token = decode_token(params[:refresh_token])
      if !token_expired?(decoded_refresh_token)
        user = User.find(decoded_refresh_token[:id])
        access_token = generate_token(user, "access")
        refresh_token = generate_token(user, "refresh")
        render json: ({
          access_token: access_token,
          refresh_token: refresh_token
        })
      else
        render json: ({
          error: "Refresh token has expired. Please generate a new one by logging in."
        })
      end
    elsif params[:access_token].present?
      render json: ({
        error: "Refresh token not present but access token is present. Please generate a new refresh token by logging in."
      })
    else
      render json: ({
        error: "Both access token and refresh token are not present. Please generate a new one by logging in."
      })
    end
  end

  private

  def generate_token(user, type)
    payload = {id: user[:id]}
    if type == "access"
      exp = 10.minutes.from_now.to_i
    elsif type == "refresh"
      exp = 30.days.from_now.to_i
    end
    JWT.encode(payload, Rails.application.secrets.secret_key_base, "HS256", {exp: exp})
  end

  def decode_token(token)
    begin
      JWT.decode(token, Rails.application.secrets.secret_key_base, true, {algorithm: "HS256"}).first
    rescue JWT::DecodeError
      render json: ({
        error: "Error occured while decoding the token."
      })
      return
    rescue JWT::ExpiredSignature
      render json: ({
        error: "Signature has expired."
      })
      return
    end
  end

  def token_expired?(token)
    Time.at(token[:exp]) < Time.now
  end
end
