module MongoDBLogging
  def self.included(base)
    base.class_eval { around_filter :enable_mongo_logging }
  end

  def enable_mongo_logging
    return yield unless Rails.logger.respond_to?(:mongoize)
    
    # make sure the controller knows how to filter its parameters
    f_params = respond_to?(:filter_parameters) ? filter_parameters(params) : params
    Rails.logger.mongoize({
      :action         => action_name,
      :controller     => controller_name,
      :path           => request.path,
      :url            => request.url,
      :params         => f_params,
      :ip             => request.remote_ip
    }) { yield }
  end
end
