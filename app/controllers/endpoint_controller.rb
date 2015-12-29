require 'time'
class EndpointController < ApplicationController

    before_filter :check_token, only: [:logout]

    def web
        render plain: t(:up_and_running)
    end

    def endpoint
        tkn_info = ActionController::HttpAuthentication::Token.token_and_options(request)
        if tkn_info.nil?
            render json: {status: "error", distance: -1, error: "unauthorized"} and return
        else
            @token = Token.find_by_token(tkn_info[0])
            if @token.nil?
                render json: {status: "error", distance: -1, error: "unauthorized"} and return
            end
        end
        if params[:current_location].blank? || params[:current_location].count < 2 || params[:email].blank?
            render json: {status: "error", distance: -1, error: "missingparams"} and return
        end
        if @token.user.email != params[:email]
            render json: {status: "error", distance: -1, error: "unauthorized"} and return
        end
        if @token.user.locations.where(created_at: Time.now-1.hour...Time.now).count >= 20
            render json: {status: "error", distance: -1, error: "requestquota"} and return
        end
        @location = Location.create(latitude: params[:current_location][0], longitude: params[:current_location][1], user: @token.user)
        if @location.new_record?
            render json: {status: "error", distance: -1, error: "validation: " + @location.errors.full_messages.join(", ")}
        else
            if @location.treasure? && !@token.user.treasure?
                CongratulationsMailer.congratulations_email(@token.user).deliver_now
                @token.user.treasure = true
                @token.user.save!
            end
            render json: {status: "ok", distance: @location.radius}
        end
    end

    def analytics
        tkn_info = ActionController::HttpAuthentication::Token.token_and_options(request)
        if tkn_info.nil?
            render json: {status: "error", requests: [], error: "unauthorized"} and return
        else
            @token = Token.find_by_token(tkn_info[0])
            if @token.nil?
                render json: {status: "error", requests: [], error: "unauthorized"} and return
            end
        end
        if params[:start_time].blank? || params[:end_time].blank?
            render json: {status: "error", requests: [], error: "missingparams"} and return
        end
        begin
            st = Time.parse(params[:start_time])
            et = Time.parse(params[:end_time])
            locations = Location.where(created_at: st...et)
            radius = params[:radius]
            if !radius.nil?
                radius = radius.to_f
                rlocations = []
                locations.each do |loc|
                    if loc.radius <= radius
                        rlocations << loc
                    end
                end
                render json: {status: "ok", requests: ActiveModel::ArraySerializer.new(rlocations, each_serializer: RequestSerializer).as_json}
            else
                render json: {status: "ok", requests: ActiveModel::ArraySerializer.new(locations, each_serializer: RequestSerializer).as_json}
            end
        rescue ArgumentError => e
            render json: {status: "error", requests: [], error: "timeparse: " + e.to_s}
        end
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
            render json: {error: "unauthorized"} and return
        else
            @token = Token.find_by_token(tkn_info[0])
            if @token.nil?
                render json: {error: "unauthorized"} and return
            end
        end
    end
end
