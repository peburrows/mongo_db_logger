MongoDbLogger
=============

Log to MongoDB from a Rails app


Usage:
======

1) add the following line to your ApplicationController:

<code>include MongoDBLogging</code>

2) configure specific environments to use the MongoLogger (in config/#{environment}.rb):

<code>config.logger = MongoLogger.new</code>

3) add mongo settings for each environment in which you want to use MongoDB for logging:

<pre><code>
development:
  adapter: mysql
  database: my_app_development
  user: root
  mongo:
    database: my_app
    capsize: &lt;%= 10.megabytes %&gt;
    host: localhost
    port: 27017
</code></pre>

With that in place, a new MongoDB document (record) will be created for each request and,
by default will record the following information: Runtime, IP Address, Request Time, Controller,
Action, Params and All messages sent to the logger. The structure of the Mongo document looks something like this:

<pre><code>
{
  'controller'    : controller_name,
  'action'        : action_name,
  'ip'            : ip_address,
  'runtime'       : runtime,
  'request_time'  : time_of_request,
  'params'        : { }
  'messages'      : {
                      'info'  : [ ],
                      'debug' : [ ],
                      'error' : [ ],
                      'warn'  : [ ],
                      'fatal' : [ ]
                    }
}
</code></pre>

Beyond that, if you want to add extra information to the base of the document
(let’s say something like user_guid on every request that it’s available),
you can just call the Rails.logger.add_metadata method on your logger like so
(for example from a before_filter):

<pre><code>
# make sure we're using the MongoLogger in this environment
if Rails.logger.respond_to?(:add_metadata)
  Rails.logger.add_metadata(:user_guid =&gt; @user_guid)
end
</code></pre>

4) And optionally, and PLEASE be sure to protect this behind a login, you can add a basic
logging view by adding the following to your routes:

<pre><code>
map.add_mongo_logger_resources!
</code></pre>

With that you can then visit "/mongo" to view log entries (latest first).  You can add
parameters like "page=3" to page through to older entries, or "count=30" to change the
number of log entries per page.

And now, for a couple quick examples on getting ahold of this log data…
First, here’s how to get a handle on the MongoDB from within a Rails console:

<pre><code>
>> db = MongoLogger.mongo_connection
=> #&lt;Mongo::DB:0x102f19ac0 @slave_ok=nil, @name="my_app" ... &gt;

>> collection = db[MongoLogger.mongo_collection_name]
=> #&lt;Mongo::Collection:0x1031b3ee8 @name="development_log" ... &gt;
</code></pre>

Once you’ve got the collection, you can find all requests for a specific user (with guid):

<pre><code>
>> cursor = collection.find(:user_guid => '12355')
=> #&lt;Mongo::Cursor:0x1031a3e30 ... &gt;
>> cursor.count
=> 5
</code></pre>

Find all requests that took more that one second to complete:

<pre><code>
>> collection.find({:runtime => {'$gt' => 1000}}).count
=> 3
</code></pre>

Find all requests that passed a parameter with a certain value:

<pre><code>
>> collection.find({'params.currency' => 'USD'}).count
=> 22
</code></pre>

Copyright (c) 2009 Phil Burrows, released under the MIT license
