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
end
