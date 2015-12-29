class EndpointController < ApplicationController

    before_filter :check_token, only: [:logout]

    def web
        render plain: t(:up_and_running)
    end

    def endpoint

    end

    def analytics

    end

    def register
        if params[:email].blank? || params[:password].blank? || params[:password_confirmation].blank?
            render json: {error: "missingparams"}
        else
            u = User.new
            u.email = params[:email]
            u.password = params[:password]
            u.password_confirmation = params[:password_confirmation]
            if u.save
                render json: {success: "success"}
            else
                render json: {error: "validation", messages: u.errors.full_messages}
            end
        end
    end

    def login
        if params[:email].blank? || params[:password].blank?
            render json: {error: "missingparams"}
        else
            user = User.find_by_email(params[:email])
            if user.nil?
                render json: {error: "unauthorized"}
            else
                if user.authenticate(params[:password]) == false
                    render json: {error: "unauthorized"}
                else
                    t = Token.create(user: user)
                    if t.new_record?
                        render json: {error: "validation", messages: t.errors.full_messages}
                    else
                        render json: {token: t.token}
                    end
                end
            end
        end
    end

    def logout
        if @token.destroy
            render json: {success: "success"}
        else
            render json: {error: "destroy"}
        end
    end

    private

    def check_token
        tkn_info = ActionController::HttpAuthentication::Token.token_and_options(request)
        if tkn_info.nil?
            render json: {error: "unauthorized"}
        else
            @token = Token.find_by_token(tkn_info[0])
            if @token.nil?
                render json: {error: "unauthorized"}
            end
        end
    end
end
