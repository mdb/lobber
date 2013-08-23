require 'rubygems'
require 'bundler/setup'
require 'simplecov'
require 'rspec'
SimpleCov.start

require 'lob'
require 'pry'
binding.pry

RSpec.configure do |config|
 #some (optional) config here
end
