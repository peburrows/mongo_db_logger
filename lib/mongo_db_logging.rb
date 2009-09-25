module MongoDBLogging
  def self.included(base)
    base.class_eval { around_filter :enable_mongo_logging }
  end

  def enable_mongo_logging
    return yield unless Rails.logger.respond_to?(:mongoize)
    Rails.logger.mongoize(:action => action_name, :controller => controller_name, :params => params, :ip => request.remote_ip) { yield }
  end
end
