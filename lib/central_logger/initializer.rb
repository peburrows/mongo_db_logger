if Rails::VERSION::MAJOR == 2
  require 'central_logger/initializer_mixin'

  module CentralLogger
    class Initializer
      extend CentralLogger::InitializerMixin

      # mirrors code in Rails 2 initializer.rb#initialize_logger
      def self.initialize_deprecated_logger(config)
        logger = config.logger = create_logger(config, config.log_path)

        silence_warnings { Object.const_set "RAILS_DEFAULT_LOGGER", logger }
      end
    end
  end
end
