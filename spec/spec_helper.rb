require 'rubygems'
require 'bundler/setup'
require 'simplecov'
require 'rspec'

Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

SimpleCov.start

require 'lob'

RSpec.configure do |config|
 #some (optional) config here
end
