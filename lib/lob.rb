require 'lob/uploader'

module Lob
  def self.upload(directory)
    uploader = Lob::Uploader.new directory
    uploader.verify_env_and_upload
  end
end
