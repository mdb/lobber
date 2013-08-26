require 'spec_helper'

describe Lob do
  it "exists as a module" do
    Lob.class.should eq Module
  end

  describe ".upload" do
    it "verifies environment variables and uploads the directory and its contents to S3" do
      uploader_stub = stub(Lob::Uploader)
      Lob::Uploader.should_receive(:new).with('foo').and_return(uploader_stub)
      uploader_stub.should_receive(:verify_env_and_upload)

      Lob.upload 'foo'
    end
  end
end
