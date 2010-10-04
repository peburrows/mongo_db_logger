if Rails::VERSION::MAJOR == 3
  module MongoDBLogger
    class Railtie < Rails::Railtie
      initializer "mongo_db_logger.init_logger" do |app|
        Rails.logger = app.config.logger = MongoLogger.new
      end
    end
  end
else
  Rails.configuration.logger = MongoLogger.new
end

