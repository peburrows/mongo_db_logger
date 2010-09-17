require "action_pack/version"
klass = if ActionPack::VERSION::MAJOR >= 3
  ActionDispatch::Routing::DeprecatedMapper
else
  ActionController::Routing::RouteSet::Mapper
end
klass.extend MongoDBLogging::RoutingExtensions