require 'spec_helper'

describe Lob do
  it "exists as a module" do
    Lob.class.should eq Module
  end

  describe ".upload" do
    before :each do
      @uploader_double = double(Lob::Uploader)
    end

    context "it is only passed a directory name, and not an S3 bucket name" do
      it "verifies environment variables and uploads the directory and its contents to S3" do
        Lob::Uploader.should_receive(:new).with('foo', nil).and_return(@uploader_double)
        @uploader_double.should_receive(:upload)

        Lob.upload 'foo'
      end
    end

    context "it is passed a directory name and an S3 bucket name" do
      it "verifies environment variables and uploads the directory and its contents to the specified S3 bucket" do
        Lob::Uploader.should_receive(:new).with('foo', 'bar').and_return(@uploader_double)
        @uploader_double.should_receive(:upload)

        Lob.upload 'foo', 'bar'
      end
    end
  end
end
