require 'rails'
require 'mongo_logger'
require 'mongo_db_logging'


if Rails::VERSION::MAJOR == 3
  module MongoDBLogger
    class Railtie < Rails::Railtie
      # load earlier than bootstrap.rb initializer loads the default logger.  bootstrap
      # initializer will then skip its own initialization once Rails.logger is defined
      initializer "mongo_db_logger.init_logger", :before => :initialize_logger do
        Rails.logger = config.logger = begin
          app_config = Rails.application.config
          path = app_config.paths.log.to_a.first
          level = ActiveSupport::BufferedLogger.const_get(app_config.log_level.to_s.upcase)
          logger = MongoLogger.new(:path => path, :level => level)
          logger.auto_flushing = false if Rails.env.production?
          logger
        rescue StandardError => e
          logger = ActiveSupport::BufferedLogger.new(STDERR)
          logger.level = ActiveSupport::BufferedLogger::WARN
          logger.warn(
            "MongoLogger Initializer Error: Unable to access log file. Please ensure that #{path} exists and is chmod 0666. " +
            "The log level has been raised to WARN and the output directed to STDERR until the problem is fixed." + "\n" +
            e.message + "\n" + e.backtrace.join("\n")
          )
          logger
        end
      end
    end
  end
end

