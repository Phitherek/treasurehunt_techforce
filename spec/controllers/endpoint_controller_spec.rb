require 'rails_helper'

RSpec.describe EndpointController, type: :controller do
    describe 'web' do
        it "should return plain text message defined in locale" do
           get :web
           expect(response.content_type).to eq "text/plain"
           expect(response.body).to eq(I18n.t(:up_and_running))
        end
    end
    describe "register" do
        it "should register a user with success response when provided valid e-mail, password and password confirmation" do
            post :register, {email: "test@test.xyz", password: "test", password_confirmation: "test"}
            expect(response.content_type).to eq "application/json"
            expect(response.body).to eq "{\"success\":\"success\"}"
        end
        it "should fail with appropriate response on missing or empty params" do
            post :register
            expect(response.content_type).to eq "application/json"
            expect(response.body).to eq "{\"error\":\"missingparams\"}"
            post :register, {email: "", password: "", password_confirmation: ""}
            expect(response.content_type).to eq "application/json"
            expect(response.body).to eq "{\"error\":\"missingparams\"}"
            post :register, {email: "test@test.xyz", password: "", password_confirmation: ""}
            expect(response.content_type).to eq "application/json"
            expect(response.body).to eq "{\"error\":\"missingparams\"}"
        end
        it "should fail with appropriate response on invalid email format" do
            post :register, {email: "test@testxyz", password: "test", password_confirmation: "test"}
            expect(response.content_type).to eq "application/json"
            expect(response.body).to eq "{\"error\":\"validation\",\"messages\":[\"Email is invalid\"]}"
        end
        it "should fail with appropriate response on wrong password confirmation" do
            post :register, {email: "test@test.xyz", password: "test", password_confirmation: "testxyz"}
            expect(response.content_type).to eq "application/json"
            expect(response.body).to eq "{\"error\":\"validation\",\"messages\":[\"Password confirmation doesn't match Password\"]}"
        end
        it "should fail with appropriate response on invalid email format and wrong password confirmation" do
            post :register, {email: "test@testxyz", password: "test", password_confirmation: "testxyz"}
            expect(response.content_type).to eq "application/json"
            expect(response.body).to eq "{\"error\":\"validation\",\"messages\":[\"Email is invalid\",\"Password confirmation doesn't match Password\"]}"
        end
    end
    describe "login" do
        it "should fail with appropriate response on missing or empty params" do
            post :login
            expect(response.content_type).to eq "application/json"
            expect(response.body).to eq "{\"error\":\"missingparams\"}"
            post :login, {email: "", password: ""}
            expect(response.content_type).to eq "application/json"
            expect(response.body).to eq "{\"error\":\"missingparams\"}"
            post :login, {email: "test@test.xyz", password: ""}
            expect(response.content_type).to eq "application/json"
            expect(response.body).to eq "{\"error\":\"missingparams\"}"
        end
        it "should fail with appropriate response on not existing e-mail" do
            post :login, {email: "test2@test.xyz", password: "test"}
            expect(response.content_type).to eq "application/json"
            expect(response.body).to eq "{\"error\":\"unauthorized\"}"
        end
        it "should fail with appropriate response on wrong password" do
            user = create(:user)
            post :login, {email: user.email, password: "test"}
            expect(response.content_type).to eq "application/json"
            expect(response.body).to eq "{\"error\":\"unauthorized\"}"
        end
        it "should create and return user token on right credentials" do
            user = create(:user)
            post :login, {email: user.email, password: user.password}
            expect(response.content_type).to eq "application/json"
            expect(response.body).to eq "{\"token\":\"#{user.tokens.last.token}\"}"
        end
    end
    describe "logout" do
        it "should fail with appropriate response on missing token" do
            post :logout
            expect(response.content_type).to eq "application/json"
            expect(response.body).to eq "{\"error\":\"unauthorized\"}"
        end
        it "should fail with appropriate response on not existing token" do
            t = build(:token)
            u = t.user
            @request.headers["HTTP_AUTHORIZATION"] =  ActionController::HttpAuthentication::Token.encode_credentials(t.token)
            post :logout
            expect(response.content_type).to eq "application/json"
            expect(response.body).to eq "{\"error\":\"unauthorized\"}"
        end
        it "should logout and destroy token with appropriate response on existing token" do
            t = create(:token)
            u = t.user
            @request.headers["HTTP_AUTHORIZATION"] =  ActionController::HttpAuthentication::Token.encode_credentials(t.token)
            post :logout
            expect(response.content_type).to eq "application/json"
            expect(response.body).to eq "{\"success\":\"success\"}"
            expect{t.reload}.to raise_error(ActiveRecord::RecordNotFound)
        end
    end
    describe "endpoint" do
        it "should fail with appropriate response on missing token" do
            get :endpoint
            expect(response.content_type).to eq "application/json"
            expect(response.body).to eq "{\"status\":\"error\",\"distance\":-1,\"error\":\"unauthorized\"}"
        end
        it "should fail with appropriate response on not existing token" do
            t = build(:token)
            u = t.user
            @request.headers["HTTP_AUTHORIZATION"] =  ActionController::HttpAuthentication::Token.encode_credentials(t.token)
            get :endpoint
            expect(response.content_type).to eq "application/json"
            expect(response.body).to eq "{\"status\":\"error\",\"distance\":-1,\"error\":\"unauthorized\"}"
        end
        describe "with correct token" do
            before(:each) do
                @token = create(:token)
                @request.headers["HTTP_AUTHORIZATION"] =  ActionController::HttpAuthentication::Token.encode_credentials(@token.token)
            end
            it "should fail with appropriate response on missing or empty params" do
                get :endpoint
                expect(response.content_type).to eq "application/json"
                expect(response.body).to eq "{\"status\":\"error\",\"distance\":-1,\"error\":\"missingparams\"}"
                get :endpoint, {current_location: ["", ""], email: ""}
                expect(response.content_type).to eq "application/json"
                expect(response.body).to eq "{\"status\":\"error\",\"distance\":-1,\"error\":\"missingparams\"}"
            end
            it "should fail with appropriate response on email not matching token credentials" do
                loc = build(:location)
                get :endpoint, {current_location: [loc.latitude, loc.longitude], email: loc.user.email}
                expect(response.content_type).to eq "application/json"
                expect(response.body).to eq "{\"status\":\"error\",\"distance\":-1,\"error\":\"unauthorized\"}"
            end
            it "should fail with appropriate response on incorrect coordinates" do
                get :endpoint, {current_location: [200, -200], email: @token.user.email}
                expect(response.content_type).to eq "application/json"
                expect(response.body).to eq "{\"status\":\"error\",\"distance\":-1,\"error\":\"validation: Latitude must be less than or equal to 90, Longitude must be greater than or equal to -180\"}"
            end
            it "should appropriately respond on correct request" do
                loc = build(:location)
                loc.user = @token.user
                get :endpoint, {current_location: [loc.latitude, loc.longitude], email: loc.user.email}
                expect(response.content_type).to eq "application/json"
                expect(response.body).to eq "{\"status\":\"ok\",\"distance\":#{loc.radius}}"
            end
            it "should appropriately respond, send email and set treasure on correct request with near location" do
                loc = build(:near_location)
                loc.user = @token.user
                get :endpoint, {current_location: [loc.latitude, loc.longitude], email: loc.user.email}
                expect(response.content_type).to eq "application/json"
                expect(response.body).to eq "{\"status\":\"ok\",\"distance\":#{loc.radius}}"
                expect(ActionMailer::Base.deliveries.count).to be > 0
                @token.user.reload
                expect(@token.user.treasure?).to be true
            end
            it "should not send second email" do
                loc = build(:near_location)
                loc.user = @token.user
                get :endpoint, {current_location: [loc.latitude, loc.longitude], email: loc.user.email}
                expect(response.content_type).to eq "application/json"
                expect(response.body).to eq "{\"status\":\"ok\",\"distance\":#{loc.radius}}"
                expect(ActionMailer::Base.deliveries.count).to be > 0
                @token.user.reload
                expect(@token.user.treasure?).to be true
                cnt = ActionMailer::Base.deliveries.count
                get :endpoint, {current_location: [loc.latitude, loc.longitude], email: loc.user.email}
                expect(response.content_type).to eq "application/json"
                expect(response.body).to eq "{\"status\":\"ok\",\"distance\":#{loc.radius}}"
                expect(ActionMailer::Base.deliveries.count).to eq(cnt)
            end
            it "should fail with appropriate response on too many requests from an email" do
                20.times do
                    loc = build(:location)
                    loc.user = @token.user
                    get :endpoint, {current_location: [loc.latitude, loc.longitude], email: loc.user.email}
                    expect(response.content_type).to eq "application/json"
                    expect(response.body).to eq "{\"status\":\"ok\",\"distance\":#{loc.radius}}"
                end
                loc = build(:location)
                loc.user = @token.user
                get :endpoint, {current_location: [loc.latitude, loc.longitude], email: loc.user.email}
                expect(response.content_type).to eq "application/json"
                expect(response.body).to eq "{\"status\":\"error\",\"distance\":-1,\"error\":\"requestquota\"}"
            end
        end
    end
    describe "analytics" do
        it "should fail with appropriate response on missing token" do
            get :analytics
            expect(response.content_type).to eq "application/json"
            expect(response.body).to eq "{\"status\":\"error\",\"requests\":[],\"error\":\"unauthorized\"}"
        end
        it "should fail with appropriate response on not existing token" do
            t = build(:token)
            u = t.user
            @request.headers["HTTP_AUTHORIZATION"] =  ActionController::HttpAuthentication::Token.encode_credentials(t.token)
            get :analytics
            expect(response.content_type).to eq "application/json"
            expect(response.body).to eq "{\"status\":\"error\",\"requests\":[],\"error\":\"unauthorized\"}"
        end
        describe "with correct token" do
            before(:each) do
                @token = create(:token)
                @request.headers["HTTP_AUTHORIZATION"] =  ActionController::HttpAuthentication::Token.encode_credentials(@token.token)
            end
            it "should fail with appropriate response on missing or empty params" do
                get :analytics
                expect(response.content_type).to eq "application/json"
                expect(response.body).to eq "{\"status\":\"error\",\"requests\":[],\"error\":\"missingparams\"}"
                get :analytics, {start_time: "", end_time: ""}
                expect(response.content_type).to eq "application/json"
                expect(response.body).to eq "{\"status\":\"error\",\"requests\":[],\"error\":\"missingparams\"}"
            end
            it "should fail with appropriate response on wrong time format" do
                get :analytics, {start_time: "-1", end_time: "-1"}
                expect(response.content_type).to eq "application/json"
                expect(response.body).to eq "{\"status\":\"error\",\"requests\":[],\"error\":\"timeparse: no time information in \\\"-1\\\"\"}"
            end
            it "should return appropriate response on correct query" do
                get :analytics, {start_time: (Time.now-10.minutes).strftime("%F %T.%6N %z"), end_time: Time.now.strftime("%F %T.%6N %z")}
                expect(response.content_type).to eq "application/json"
                expect(response.body).to eq "{\"status\":\"ok\",\"requests\":[]}"
            end
            it "should return correct JSON" do
                loc1 = create(:location)
                loc2 = create(:location)
                get :analytics, {start_time: (Time.now-10.minutes).strftime("%F %T.%6N %z"), end_time: Time.now.strftime("%F %T.%6N %z")}
                expect(response.content_type).to eq "application/json"
                expect(response.body).to eq "{\"status\":\"ok\",\"requests\":[{\"email\":\"#{loc1.user.email}\",\"current_location\":[#{loc1.latitude},#{loc1.longitude}]},{\"email\":\"#{loc2.user.email}\",\"current_location\":[#{loc2.latitude},#{loc2.longitude}]}]}"
            end
            it "should return correct JSON with radius" do
                loc1 = create(:near_location)
                loc2 = create(:distant_location)
                get :analytics, {start_time: (Time.now-10.minutes).strftime("%F %T.%6N %z"), end_time: Time.now.strftime("%F %T.%6N %z"), radius: 5}
                expect(response.content_type).to eq "application/json"
                expect(response.body).to eq "{\"status\":\"ok\",\"requests\":[{\"email\":\"#{loc1.user.email}\",\"current_location\":[#{loc1.latitude},#{loc1.longitude}]}]}"
            end
        end
    end
end
