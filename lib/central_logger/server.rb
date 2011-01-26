require 'sinatra/base'
require 'erb'
require 'mongo'
require 'yaml'

module CentralLogger
  class Server < Sinatra::Base
    dir = File.dirname(File.expand_path(__FILE__))

    set :views,   "#{dir}/server/views"
    set :public,  "#{dir}/server/public"
    set :static,  true

    helpers do
      include Rack::Utils
      alias_method :h, :escape_html

      def url(*path_parts)
        [ path_prefix, path_parts ].join("/").squeeze('/')
      end
      alias_method :u, :url

      def path_prefix
        request.env['SCRIPT_NAME']
      end
    end

    def show(page, layout=true)
      erb page.to_sym, {:layout => layout}
    end

    def collection
      self.class._settings[:collection]
    end

    def db
      self.class._settings[:db]
    end

    before do
      self.class._settings[:db]         ||= Mongo::Connection.new(self.class.host, self.class.port, :auto_reconnect => true).db(self.class.database)
      self.class._settings[:collection] ||= self.class._settings[:db][self.class.collection]
    end

    # ----------------- #
    # ---- routes! ---- #
    # ----------------- #
    get "/" do
      redirect url(:home)
    end

    %w( home ).each do |page|
      get "/#{page}" do
        if !params[:page] || params[:page] == ''
          @records = collection.find({}, :limit => 10)
        else
          @records = collection.find({}, :limit => 10, :skip => (params[:page].to_i - 1) * 10)
        end
        @records = @records.to_a
        redirect url(:home) if @records.length == 0
        show(page)
      end
    end

    get "/show/:id" do
      puts "here are the params (#{params[:id]}): \n\n#{params.inspect}"
      # @record = @collection.find_one('_id' => params[:id])
      @record = @collection.find_one(BSON::ObjectId(params[:id]))
      redirect url(:home) unless @record
      show(:show)
    end

    # allow the collection to be setup

    @host, @port = 'localhost', 27017
    @_settings = {}
    class << self
      attr_accessor :collection, :host, :port, :database, :_settings
    end

    def self.load_config(path)
      c = YAML.load(File.read(File.expand_path(path)))
      self.collection = c['collection']
      self.database   = c['database']
      self.host       = c['host'] if c['host']
      self.port       = c['port'] if c['port']
    end

  end
end