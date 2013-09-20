require 'spec_helper'

describe Lobber do
  it "exists as a module" do
    Lobber.class.should eq Module
  end

  describe ".upload" do
    before :each do
      @uploader_double = double(Lobber::Uploader)
    end

    context "it is only passed a directory name, and not an S3 bucket name" do
      it "verifies environment variables and uploads the directory and its contents to S3" do
        Lobber::Uploader.should_receive(:new).with('foo', nil).and_return(@uploader_double)
        @uploader_double.should_receive(:upload)

        Lobber.upload 'foo'
      end
    end

    context "it is passed a directory name and an S3 bucket name" do
      it "verifies environment variables and uploads the directory and its contents to the specified S3 bucket" do
        Lobber::Uploader.should_receive(:new).with('foo', 'bar').and_return(@uploader_double)
        @uploader_double.should_receive(:upload)

        Lobber.upload 'foo', 'bar'
      end
    end
  end
end
