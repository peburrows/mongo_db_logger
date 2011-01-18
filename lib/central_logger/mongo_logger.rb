require 'erb'
require 'mongo'
require 'active_support'
require 'active_support/core_ext'
require 'central_logger/replica_set_helper'

module CentralLogger
  class MongoLogger < ActiveSupport::BufferedLogger
    include ReplicaSetHelper

    PRODUCTION_COLLECTION_SIZE = 250.megabytes
    DEFAULT_COLLECTION_SIZE = 100.megabytes
    # Looks for configuration files in this order
    CONFIGURATION_FILES = ["central_logger.yml", "mongoid.yml", "database.yml"]

    attr_reader :db_configuration, :mongo_connection, :mongo_collection_name, :mongo_collection

    def initialize(options={})
      path = options[:path] || File.join(Rails.root, "log/#{Rails.env}.log")
      level = options[:level] || DEBUG
      super(path, level)
      internal_initialize
    rescue => e
      # should use a config block for this
      Rails.env.production? ? (raise e) : (puts "Using BufferedLogger due to exception: " + e.message)
    end

    def add_metadata(options={})
      options.each_pair do |key, value|
        unless [:messages, :request_time, :ip, :runtime, :application_name].include?(key.to_sym)
          @mongo_record[key] = value
        else
          raise ArgumentError, ":#{key} is a reserved key for the central logger. Please choose a different key"
        end
      end
    end

    def add(severity, message = nil, progname = nil, &block)
      super
      if @level <= severity && message.present? && @mongo_record.present?
        # remove Rails colorization to get the actual message
        message.gsub!(/(\e(\[([\d;]*[mz]?))?)?/, '').strip! if logging_colorized?
        @mongo_record[:messages][level_to_sym(severity)] << message
      end
    end

    # Drop the capped_collection and recreate it
    def reset_collection
      @mongo_collection.drop
      create_collection
    end

    def mongoize(options={})
      @mongo_record = options.merge({
        :messages => Hash.new { |hash, key| hash[key] = Array.new },
        :request_time => Time.now.getutc,
        :application_name => @application_name
      })

      runtime = Benchmark.measure{ yield }.real
    rescue Exception => e
      add(3, e.message + "\n" + e.backtrace.join("\n"))
      # Reraise the exception for anyone else who cares
      raise e
    ensure
      # In case of exception, make sure runtime is set
      @mongo_record[:runtime] = ((runtime ||= 0) * 1000).ceil
      @insert_block.call
    end

    def authenticated?
      @authenticated
    end

    private
      # facilitate testing
      def internal_initialize
        configure
        connect
        check_for_collection
      end

      def configure
        default_capsize = Rails.env.production? ? PRODUCTION_COLLECTION_SIZE : DEFAULT_COLLECTION_SIZE
        @application_name = Rails.root.basename.to_s
        @mongo_collection_name = "#{Rails.env}_log"
        @authenticated = false
        @db_configuration = {
          'host' => 'localhost',
          'port' => 27017,
          'capsize' => default_capsize}.merge(resolve_config)

        @insert_block = @db_configuration.has_key?('replica_set') && @db_configuration['replica_set'] ?
          lambda { rescue_connection_failure{ insert_log_record(true) } } :
          lambda { insert_log_record }
      end

      def resolve_config
        config = {}
        CONFIGURATION_FILES.each do |filename|
          config_file = Rails.root.join("config", filename)
          if config_file.file?
            config = YAML.load(ERB.new(config_file.read).result)[Rails.env]
            config = config['mongo'] if config.has_key?('mongo')
            break
          end
        end
        config
      end

      def connect
        @mongo_connection ||= Mongo::Connection.new(@db_configuration['host'],
                                                    @db_configuration['port'],
                                                    :auto_reconnect => true).db(@db_configuration['database'])

        if @db_configuration['username'] && @db_configuration['password']
          # the driver stores credentials in case reconnection is required
          @authenticated = @mongo_connection.authenticate(@db_configuration['username'],
                                                          @db_configuration['password'])
        end
      end

      def create_collection
        @mongo_connection.create_collection(@mongo_collection_name,
                                            {:capped => true, :size => @db_configuration['capsize']})
      end

      def check_for_collection
        # setup the capped collection if it doesn't already exist
        unless @mongo_connection.collection_names.include?(@mongo_collection_name)
          create_collection
        end
        @mongo_collection = @mongo_connection[@mongo_collection_name]
      end

      def insert_log_record(safe=false)
        @mongo_collection.insert(@mongo_record, :safe => safe)
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

      def logging_colorized?
        # Cache it since these ActiveRecord attributes are assigned after logger initialization occurs in Rails boot
        @colorized ||= Object.const_defined?(:ActiveRecord) &&
        (Rails::VERSION::MAJOR >= 3 ?
          ActiveRecord::LogSubscriber.colorize_logging :
          ActiveRecord::Base.colorize_logging)
      end
  end # class MongoLogger
end
