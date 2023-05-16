class ApplicationController < ActionController::Base
    # protect_from_forgery with: :exception
    # helper_method :authenticate_user!, :current_user, :token_payload

    # private

    # def authenticate_user!
    #     # Check whether the current user exists
    #     # If not exists, return error
    # end

    # def current_user
    #     # Check whether payload exists in token
    #     # If exists, find and send current user
    #     # If not exists, return error
    # end

    # def token_payload
    #     # Check whether token is already present or not
    #     # If not present
    #         # Check whether access token cookie is present or not
    #         # If present
    #             # Decode access token and return the token payload
    #         # If not present, return error
    #     # If present, return token payload
    # end
end
