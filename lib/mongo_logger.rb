require 'erb'
require 'mongo'

class MongoLogger < ActiveSupport::BufferedLogger
  default_capsize = (Rails.env == 'production') ? 250.megabytes : 100.megabytes
  
  db_configuration = {
    'host'    => 'localhost',
    'port'    => 27017,
    'capsize' => default_capsize}.merge( YAML::load(ERB.new(IO.read(File.join(Rails.root, 'config/database.yml'))).result)[Rails.env]['mongo'] )

  @mongo_collection_name      = "#{Rails.env}_log"
  @mongo_connection ||= Mongo::Connection.new(db_configuration['host'], db_configuration['port'], :auto_reconnect => true).db(db_configuration['database'])

  # setup the capped collection if it doesn't already exist
  unless @mongo_connection.collection_names.include?(@mongo_collection_name)
    @mongo_connection.create_collection(@mongo_collection_name, {:capped => true, :size => db_configuration['capsize']})
  end

  class << self
    attr_reader :mongo_collection_name, :mongo_connection
  end

  def initialize(level=DEBUG)
    super(File.join(Rails.root, "log/#{Rails.env}.log"), level)
  end

  def level_to_sym(level)
    case level
      when 0 then :debug
      when 1 then :info
      when 2 then :warn
      when 3 then :error
      when 4 then :fatal
      when 5 then :unknown
    end
  end

  def mongoize(options={})   
    the_controller = options.delete(:_controller)
    @mongo_record = options.merge({
      :messages => Hash.new { |hash, key| hash[key] = Array.new },
      :request_time => Time.now.utc
    })
    runtime = Benchmark.measure do
      yield the_controller
    end
    @mongo_record[:runtime]     = (runtime.real * 1000).ceil
    self.class.mongo_connection[self.class.mongo_collection_name].insert(@mongo_record) rescue nil
  end

  def add_metadata(options={})
    options.each_pair do |key, value|
      unless [:messages, :request_time, :ip, :runtime].include?(key.to_sym)
        info("adding #{key} => #{value}")
        @mongo_record[key] = value
      else
        raise ArgumentError, ":#{key} is a reserved key for the mongo logger. Please choose a different key"
      end
    end
  end

  def add(severity, message = nil, progname = nil, &block)
    unless @level > severity
      if ActiveRecord::Base.colorize_logging
        # remove colorization done by rails and just save the actual message
        @mongo_record[:messages][level_to_sym(severity)] << message.gsub(/(\e(\[([\d;]*[mz]?))?)?/, '').strip rescue nil
      else
        @mongo_record[:messages][level_to_sym(severity)] << message
      end
    end

    super
  end
end # class MongoLogger