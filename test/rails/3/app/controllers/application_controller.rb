class ApplicationController < ActionController::Base
  include CentralLogger::Filter
  protect_from_forgery
end
