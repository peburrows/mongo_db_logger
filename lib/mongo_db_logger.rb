require 'mongo'
module MongoDBLogger
  def self.included(base)
    ActiveSupport::BufferedLogger.send(:include, MongoLoggerModifications)
    base.class_eval { around_filter :use_mongodb_logger }
  end

  def use_mongodb_logger
    return yield if (Rails.env == 'development')
    Rails.logger.mongoize(:action => action_name, :controller => controller_name, :params => params, :ip => request.remote_ip) { yield }
  end
end
