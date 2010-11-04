source "http://rubygems.org"

gem "rake"
gem "bundler", "~> 1.0.0"
gem "mongo"
gem "bson_ext"

group :development do
  # adds Bundler support for gemspec generation
  gem "jeweler", "~> 1.5.0.pre5"
  gem "shoulda"
  gem "i18n"
  gem "activesupport"
  gem "mocha"
  gem (RUBY_VERSION =~ /^1\.9/ ? "ruby-debug19" : "ruby-debug")
end
