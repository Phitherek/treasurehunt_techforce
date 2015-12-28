class EndpointController < ApplicationController
    def web
        render plain: t(:up_and_running)
    end
end
