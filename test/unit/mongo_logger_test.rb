require 'test_helper'
require 'mongo_logger'

# test the basic stuff
class MongoLoggerTest < Test::Unit::TestCase
  extend LogMacros

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
          common_setup
          @collection.drop
        end

        should "expose a valid mongo connection" do
          assert_instance_of Mongo::DB, @mongo_logger.mongo_connection
        end

        should "create a capped collection in the database with the configured size" do
          @mongo_logger.send(:check_for_collection)
          assert @con.collection_names.include?(@mongo_logger.mongo_collection_name)
          # new capped collections are X MB + 5888 bytes, but don't be too strict in case that changes
          assert @collection.stats["storageSize"] < MongoLogger::DEFAULT_COLLECTION_SIZE + 1.megabyte
        end
      end
    end

    context "after instantiation" do
      setup do
        @mongo_logger = MongoLogger.new
        common_setup
      end

      context "upon insertion of a log record when active record is not used" do
        # mock ActiveRecord has not been included
        setup do
          log("Test")
        end

        should_contain_one_log_record

        should "allow recreation of the capped collection to remove all records" do
          @mongo_logger.reset_collection
          assert_equal 0, @collection.count
        end
      end

      context "upon insertion of a colorized log record when ActiveRecord is used" do
        setup do
          @log_message = "TESTING"
          require_bogus_active_record
          @mongo_logger.reset_collection
          log("\e[31m #{@log_message} \e[0m")
        end

        should "detect logging is colorized" do
          assert @mongo_logger.send(:logging_colorized?)
        end

        should_contain_one_log_record

        should "strip out colorization from log messages" do
          assert_equal 1, @collection.find({"messages.debug" => @log_message}).count
        end
      end

      should "add application metadata to the log record" do
        options = {"application" => self.class.name}
        log_metadata(options)
        assert_equal 1, @collection.find({"application" => self.class.name}).count
      end
    end

    context "logging at INFO level" do
      setup do
        @mongo_logger = MongoLogger.new(MongoLogger::INFO)
        @mongo_logger.reset_collection
        common_setup
        log("INFO")
      end

      should_contain_one_log_record

      should "not log DEBUG messages" do
        assert_equal 0, @collection.find_one({}, :fields => ["messages"])["messages"].count
      end
    end
  end
end
