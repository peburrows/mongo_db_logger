require 'test/unit'
require 'shoulda'
require 'mocha'
require 'active_support/core_ext'
require 'blueprints'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

Shoulda.autoload_macros("#{File.dirname(__FILE__)}/..")

class Test::Unit::TestCase
end
