require 'spec_helper'

describe Lob do
  it "exists as a module" do
    Lob.class.should eq Module
  end

  describe "#upload" do
    it "verifies environment variables and uploads the directory and its contents to S3" do
      Lob::Uploader.should_receive(:new).with 'foo'
      Lob.upload 'foo'
    end
  end
end
