require 'rails_helper'

RSpec.describe EndpointController, type: :controller do
    describe 'web' do
        it "should return plain text message defined in locale" do
           get :web
           expect(response.body).to eq(I18n.t(:up_and_running))
        end
    end
end
