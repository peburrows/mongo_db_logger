# A sample Gemfile
source "http://rubygems.org"

gem "rake"
gem "bundler", "~> 1.0.0"
gem "mongo"
gem "bson_ext"

group :production do
  gem "rails", "~> 3.0.0"
end

group :development do
  gem "jeweler"
  gem "shoulda"
  gem "i18n"
  gem "activesupport"
  gem "mocha"
  gem (RUBY_VERSION =~ /^1\.9/ ? "ruby-debug19" : "ruby-debug")
end
