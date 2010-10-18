require 'helper'
require 'mongo_logger'

# test the basic stuff
class TestMongoDbLogger < Test::Unit::TestCase
  context "The Railtie's logger instantiation" do
    setup do
      MongoLogger.any_instance.stubs(:internal_initialize).returns(nil)
      @mongo_logger = MongoLogger.new
    end

    context "on configuration" do
      setup do
        @mongo_logger.send(:configure)
      end

      should "use the default host, port, and capsize if not configured" do
        assert_equal 'localhost', @mongo_logger.db_configuration['host']
        assert_equal 27017, @mongo_logger.db_configuration['port']
        assert_equal MongoLogger::DEFAULT_COLLECTION_SIZE, @mongo_logger.db_configuration['capsize']
      end
    end

    context "on connection to the database" do
      setup do
        @mongo_logger.send(:configure)
      end
      should "successfully connect" do
        assert_nothing_raised{@mongo_logger.send(:connect)}
      end
    end
  end

  context "when using a configuration file without the required database name" do
    setup do
      @mongo_logger = MongoLogger.new
      # Reconfigure Rails mock object to use an invalid database.yml
    end

    should "raise an exception" do
    end
  end

  context "After application initialization" do
    should "create a new capped collection with the default size and name" do
    end
  end

  context "When connected to a mongo instance" do
    should "remove colorized logging chars" do
    end

    should "not remove colorized logging chars when colorize_logging is off" do
    end

    should "not log messages at a lower level than configured" do
    end

    should "log exceptions" do
    end
  end
end
