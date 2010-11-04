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
  gem.name = "central_logger"
  gem.summary = %Q{Central Logger for Rails}
  gem.description = %Q{Centralized logging for rails apps using MongoDB. The idea and the core code is from http://github.com/peburrows/central_logger}
  gem.email = "astupka@customink.com"
  gem.homepage = "http://github.com/customink/central_logger"
  gem.authors = ["Phil Burrows", "Alex Stupka"]
  gem.files.exclude 'test/rails/**/*'
  gem.test_files.exclude 'test/rails/**/*'
end
# dependencies defined in Gemfile

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/unit/*_test.rb'
  test.verbose = true
end

Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "central_logger #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
