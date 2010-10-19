require 'test_helper'
require 'mongo_logger'

# test the basic stuff
class MongoLoggerTest < Test::Unit::TestCase
  context "A MongoLogger" do
    context "during configuration in instantiation" do
      setup do
        MongoLogger.any_instance.stubs(:internal_initialize).returns(nil)
        @mongo_logger = MongoLogger.new
        @mongo_logger.send(:configure)
      end

      should "set the default host, port, and capsize if not configured" do
        assert_equal 'localhost', @mongo_logger.db_configuration['host']
        assert_equal 27017, @mongo_logger.db_configuration['port']
        assert_equal MongoLogger::DEFAULT_COLLECTION_SIZE, @mongo_logger.db_configuration['capsize']
      end

      should "set the mongo collection name depending on the Rails environment" do
        assert_equal "#{Rails.env}_log", @mongo_logger.mongo_collection_name
      end

      context "upon connecting to an empty database" do
        setup do
          @mongo_logger.send(:connect)
          @con = @mongo_logger.mongo_connection
          @con[@mongo_logger.mongo_collection_name].drop
        end

        should "expose a valid mongo connection" do
          assert_instance_of Mongo::DB, @mongo_logger.mongo_connection
        end

        should "create a capped collection in the database with the configured size" do
          @mongo_logger.send(:check_for_collection)
          assert @con.collection_names.include?(@mongo_logger.mongo_collection_name)
          # new capped collections are X MB + 5888 bytes, but don't be too strict in case that changes
          assert @con.stats["storageSize"] < MongoLogger::DEFAULT_COLLECTION_SIZE + 1.megabyte
        end
      end
    end

    context "upon log insertion" do
      setup do
      @mongo_logger = MongoLogger.new
      @con = @mongo_logger.mongo_connection
        @mongo_logger.mongoize({"id" => 1}) do
          @mongo_logger.info("Log record")
        end
      end

      should "insert a log record into the capped collection" do
        assert_equal 1, @con[@mongo_logger.mongo_collection_name].count
      end

      should "allow recreation of the capped collection" do
        @mongo_logger.reset_collection
        assert_equal 0, @con[@mongo_logger.mongo_collection_name].count
      end
    end

    context "When connected to a mongo instance" do
      should "remove colorized logging chars" do
      end

      should "add application metadata to the log record" do
      end

      should "not remove colorized logging chars when colorize_logging is off" do
      end

      should "not log messages at a lower level than configured" do
      end

      should "log exceptions" do
        # Needs testing in controller
      end
    end
  end
end
