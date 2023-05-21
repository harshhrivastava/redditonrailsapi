class UsersController < ApplicationController
    before_action :validate, except: [:create]

    def show
        render json: ({
            user: @user
        })
    end
    
    def create
        if !user_signed_in?
            user = User.new({email: params[:email]})
            user.clean_email
            user = User.find_by({email: user.email})
            if user.nil?
                user = User.new(get_user_params)
                if user.save
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
                        errors: ["Some error occured while creating your profile."]
                    })
                end
            else
                render json: ({
                    user: user,
                    errors: ["User already exists."]
                })
            end
        else
            render json: ({
                errors: ["You are signed in. Please logout in order to create a new account."]
            })
        end
    end

    # def update
    #     if @user.update(get_user_update_params)
    #         render json: ({
    #             user: @user
    #         })                
    #     else
    #         render json: ({
    #             errors: ["Some error occured while updating your profile."]
    #         })
    #     end
    # end

    def destroy
        if @user.destroy
            cookies.delete(:access_token)
            cookies.delete(:refresh_token)
            render json: ({
                messages: ["User deleted successfully"]
            })
        else
            render json: ({
                errors: ["Some error occured while deleting your profile."]
            })
        end
    end

    private

    def get_user_params
        params.permit(:username, :email, :password)
    end

    # def get_user_update_params
    #     params.permit(:username, :password)
    # end
end