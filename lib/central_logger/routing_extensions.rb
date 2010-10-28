module CentralLogger
  module RoutingExtensions
    def add_central_logger_resources!
      resources :central_logger, :controller => "CentralLogger/Log", :only => [:show, :index, :destroy]
    end
  end
end
