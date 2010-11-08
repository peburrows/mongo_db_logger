require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rubygems'
require 'bundler'
require 'jeweler'

desc 'Default: run unit tests.'
task :default => "test:unit"
task :test => "test:functionals"

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

def rake_functionals(opts=nil)
    if ENV['RUBYOPT']
      # remove bundler/setup require that prematurely checks for gems and crashes
      ENV['RUBYOPT'] = ENV['RUBYOPT'].gsub(%r{-r\s*bundler/setup}, '')
    end
    # runs all the tests for each ruby version in each rails dir
    system("bash test/test.sh #{opts}")
end

namespace :test do
  desc "Run all tests against all permutations of ruby and rails"
  task :functionals do
    rake_functionals
  end

  namespace :functionals do
    desc "Clean out gemsets before running functional tests."
    task :clean do
      rake_functionals('--clean')
    end
  end

  desc "Run unit tests"
  Rake::TestTask.new(:unit) do |test|
    test.libs << 'lib' << 'test'
    test.pattern = 'test/unit/*_test.rb'
    test.verbose = true
  end
end

Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "central_logger #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
