require 'test/unit'
require 'shoulda'
require 'mocha'
# mock rails class
require 'pathname'
require 'rails'
require 'fileutils'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

Shoulda.autoload_macros("#{File.dirname(__FILE__)}/..")

class Test::Unit::TestCase
  CONFIG_DIR = Rails.root.join("config")
  SAMPLE_CONFIG_DIR = File.join(CONFIG_DIR, "samples")
  DEFAULT_CONFIG = "database.yml"
  MONGOID_CONFIG = "mongoid.yml"
  LOGGER_CONFIG = "central_logger.yml"

  def log(msg)
    @central_logger.mongoize({"id" => 1}) do
      @central_logger.debug(msg)
    end
  end

  def log_exception(msg)
    @central_logger.mongoize({"id" => 1}) do
      raise msg
    end
  end

  def setup_for_config(file)
    File.delete(File.join(CONFIG_DIR, DEFAULT_CONFIG))
    FileUtils.cp(File.join(SAMPLE_CONFIG_DIR, file),  CONFIG_DIR)
    @central_logger.send(:configure)
  end

  def teardown_for_config(file)
    File.delete(File.join(CONFIG_DIR, file))
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
