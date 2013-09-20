require 'lobber/version'
require 'lobber/uploader'
require 'lobber/cli'

module Lobber
  def self.upload(directory, bucket=nil)
    uploader = Lobber::Uploader.new directory, bucket
    uploader.upload
  end
end
