module MongoLoggerTestHelper
  def log(msg)
    @mongo_logger.mongoize({"id" => 1}) do
      @mongo_logger.debug(msg)
    end
  end

  def log_metadata(options)
    @mongo_logger.mongoize({"id" => 1}) do
      @mongo_logger.add_metadata(options)
    end
  end

  def require_bogus_active_record
    require 'active_record'
  end

  def common_setup
    @con = @mongo_logger.mongo_connection
    @collection = @con[@mongo_logger.mongo_collection_name]
  end
end
