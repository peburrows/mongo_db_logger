require 'mongo_logger'
Rails.logger = config.logger = MongoLogger.new
