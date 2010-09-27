# For Rails 3, this runs inside the Plugin initializer
require 'mongo_logger'
klass = if Rails::VERSION::MAJOR >= 3
  # runs after primary Bootstrap.rb log initializer
  # TODO: hook this in using a gem/Railtie to capture other boot log messages
  Rails.logger = config.logger = MongoLogger.new
  ActionDispatch::Routing::DeprecatedMapper
else
  ActionController::Routing::RouteSet::Mapper
end
klass.extend MongoDBLogging::RoutingExtensions
