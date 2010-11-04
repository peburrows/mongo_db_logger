ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
if Rails::VERSION::MAJOR == 3
  require 'rails/test_help'
else
  require 'test_help'
end

class ActiveSupport::TestCase
  def common_setup
    @con = @central_logger.mongo_connection
    @collection = @con[@central_logger.mongo_collection_name]
  end
end
