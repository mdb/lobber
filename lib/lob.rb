require 'lob/version'
require 'lob/uploader'
require 'lob/cli'

module Lob
  def self.upload(directory, bucket=nil)
    uploader = Lob::Uploader.new directory, bucket
    uploader.verify_env_and_upload
  end
end
