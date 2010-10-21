require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rubygems'
require 'bundler'
require 'jeweler'

desc 'Default: run unit tests.'
task :default => :test
task :test => :check_dependencies

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

Jeweler::Tasks.new do |gem|
  gem.name = "mongo_db_logger"
  gem.summary = %Q{Ruby Mongo DB Logger for Rails}
  gem.description = %Q{Centralized logging for rails apps in MongoDB. The idea and most of the code is from http://github.com/peburrows/mongo_db_logger}
  gem.email = "astupka@customink.com"
  gem.homepage = "http://github.com/customink/mongo_db_logger"
  gem.authors = ["Phil Burrows", "Alex Stupka"]
  gem.rubyforge_project = "mongo_db_logger"
end
Jeweler::RubyforgeTasks.new do |rubyforge|
  rubyforge.doc_task = "rdoc"
end
# dependencies defined in Gemfile

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "mongo_db_logger #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
