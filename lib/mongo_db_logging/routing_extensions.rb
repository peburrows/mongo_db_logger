module MongoDBLogging
  module RoutingExtensions
    def add_mongo_logger_resources!
      resources :mongo, :controller => "MongoDBLogging/Mongo", :only => [:show, :index, :destroy]
    end
  end
end