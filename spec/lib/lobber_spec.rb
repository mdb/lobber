require 'spec_helper'

describe Lobber do
  it "exists as a module" do
    expect(Lobber.class).to eq Module
  end

  describe ".upload" do
    before :each do
      @uploader_double = double(Lobber::Uploader)
    end

    context "it is only passed a directory name, and not an S3 bucket name" do
      it "verifies environment variables and uploads the directory and its contents to S3" do
        expect(Lobber::Uploader).to receive(:new).with('foo', nil).and_return(@uploader_double)
        expect(@uploader_double).to receive(:upload)

        Lobber.upload 'foo'
      end
    end

    context "it is passed a directory name and an S3 bucket name" do
      it "verifies environment variables and uploads the directory and its contents to the specified S3 bucket" do
        expect(Lobber::Uploader).to receive(:new).with('foo', 'bar').and_return(@uploader_double)
        expect(@uploader_double).to receive(:upload)

        Lobber.upload 'foo', 'bar'
      end
    end
  end
end
