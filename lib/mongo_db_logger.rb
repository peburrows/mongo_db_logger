  require 'mongo_logger'
  require 'mongo_db_logging'

  module MongoDBLogger
    if Rails::VERSION::MAJOR == 3
      class Railtie < Rails::Railtie
        # load earlier than bootstrap.rb initializer loads the default logger.  bootstrap
        # initializer will then skip its own initialization once Rails.logger is defined
        initializer "mongo_db_logger.init_logger", :before => :initialize_logger do
          app_config = Rails.application.config
          Rails.logger = config.logger = MongoDBLogger.create_logger(app_config,
                                                                     app_config.paths.log.to_a.first)
        end
      end
    end

    # initialization common to Rails 2.3.8 and 3.0
    def create_logger(config, path)
      level = ActiveSupport::BufferedLogger.const_get(config.log_level.to_s.upcase)
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

    # mirrors code in Rails 2 initializer.rb#initialize_logger
    def initialize_deprecated_logger(config)
      logger = config.logger = create_logger(config, config.log_path)

      silence_warnings { Object.const_set "RAILS_DEFAULT_LOGGER", logger }
    end

    module_function :create_logger, :initialize_deprecated_logger
  end

