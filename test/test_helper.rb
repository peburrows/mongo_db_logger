require 'test/unit'
require 'shoulda'
require 'mocha'
# mock rails class
require 'pathname'
require 'rails'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

Shoulda.autoload_macros("#{File.dirname(__FILE__)}/..")

class Test::Unit::TestCase
  def log(msg)
    @central_logger.mongoize({"id" => 1}) do
      @central_logger.debug(msg)
    end
  end

  def log_metadata(options)
    @central_logger.mongoize({"id" => 1}) do
      @central_logger.add_metadata(options)
    end
  end

  def require_bogus_active_record
    require 'active_record'
  end

  def common_setup
    @con = @central_logger.mongo_connection
    @collection = @con[@central_logger.mongo_collection_name]
  end
end
