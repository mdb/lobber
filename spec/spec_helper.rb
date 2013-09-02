require 'rubygems'
require 'bundler/setup'
require 'simplecov'
require 'rspec'
SimpleCov.start

Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}
require 'lob'

RSpec.configure do |config|
 #some (optional) config here
end
