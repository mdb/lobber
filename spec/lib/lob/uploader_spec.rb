require 'spec_helper'

describe Lob::Uploader do
  let(:directory_name) { 'spec' }
  let(:uploader) { Lob::Uploader.new(directory_name) }

  before :each do
    Fog.mock!
    uploader.stub(:aws_access_key).and_return 'fake key'
    uploader.stub(:aws_secret_key).and_return 'fake key'
    uploader.stub(:fog_directory).and_return directory_name
  end

  after :each do
    Fog.unmock!
  end

  it "exists as a class within the Lob module" do
    Lob::Uploader.class.should eq Class
  end

  describe "#upload" do
    before :each do
      uploader.stub(:verify_env_variables).and_return(true)
    end

    it "verifies necessary environment variables" do
      uploader.should_receive :verify_env_variables
      uploader.upload
    end

    it "calls #create_file_or_directory with each file or directory in the directory" do
      uploader.stub(:directory_content).and_return 'foo' => 'bar', 'baz' => 'bim'
      uploader.should_receive(:create_file_or_directory).with('foo', 'bar')
      uploader.should_receive(:create_file_or_directory).with('baz', 'bim')
      uploader.upload
    end
  end

  describe "#directory_content" do
    it "returns the content for the directory it's passed" do
      File.stub(:read).and_return 'content'
      uploader.directory_content.should eq(
        "spec/lib/" => :directory,
        "spec/lib/lob/" => :directory,
        "spec/lib/lob/uploader_spec.rb" => "content",
        "spec/lib/lob/cli_spec.rb" => "content",
        "spec/lib/lob_spec.rb" => "content",
        "spec/spec_helper.rb" => "content",
        "spec/support/" => :directory,
        "spec/support/matchers/" => :directory,
        "spec/support/matchers/exit_with_code.rb" => "content"
      )
    end
  end

  describe "#bucket" do
    it "creates a bucket of the same name" do
      uploader.bucket.class.should eq Fog::Storage::AWS::Directory
      uploader.bucket.key.should eq 'spec'
    end
  end

  describe "#create_file_or_directory" do
    context "when it is called with the directory flag" do
      it "calls #create_directory" do
        uploader.should_receive(:create_directory).with 'foo'
        uploader.create_file_or_directory 'foo', :directory
      end
    end

    context "when it is called without the directory flag" do
      it "calls #create_directory" do
        uploader.should_receive(:create_file).with 'foo'
        uploader.create_file_or_directory 'foo', 'some_content'
      end
    end
  end

  describe "#create_directory" do
    it "creates an s3 directory" do
      uploader.bucket.files.should_receive(:create).with(key: 'foo', public: true)
      uploader.create_directory "foo"
    end
  end

  describe "#create_file" do
    it "creates an s3 file" do
      File.stub(:open).and_return 'content'
      uploader.bucket.files.should_receive(:create).with(key: 'foo', public: true, body: 'content')
      uploader.create_file "foo"
    end
  end

  describe "#s3" do
    before :each do
      uploader.stub(:aws_access_key).and_return('aws_access_key')
      uploader.stub(:aws_secret_key).and_return('aws_secret_key')
    end

    it "it instantiates a new Fog::Storage class with the proper arguments" do
      Fog::Storage.should_receive(:new).with(
        provider: :aws,
        aws_access_key_id: 'aws_access_key',
        aws_secret_access_key: 'aws_secret_key'
      )
      uploader.s3
    end
  end

  describe "#verify_env_variables" do
    context "when one of the required environment variables is absent" do
      it "raises an error reporting that the missing environment variable is required" do
        uploader.stub(:aws_access_key).and_return nil
        expect { uploader.verify_env_variables }.to raise_error(RuntimeError, 'Required environment variables missing: ["AWS_ACCESS_KEY"]')
      end
    end

    context "when all of the required environment variables are defined" do
      before :each do
        uploader.stub(:aws_access_key).and_return true
        uploader.stub(:aws_secret_key).and_return true
        uploader.stub(:fog_directory).and_return true
      end

      it "it does not raise an error" do
        expect { uploader.verify_env_variables }.not_to raise_error
      end

      it "returns true" do
        uploader.verify_env_variables.should eq true
      end
    end
  end

  describe "#aws_access_key" do
    it "returns the value of the AWS_ACCESS_KEY environment variable" do
      some_uploader = Lob::Uploader.new 'foo'
      ENV.stub(:[])
      ENV.should_receive(:[]).with 'AWS_ACCESS_KEY'
      some_uploader.aws_access_key
    end
  end

  describe "#aws_secret_key" do
    it "returns the value of the AWS_ACCESS_KEY environment variable" do
      some_uploader = Lob::Uploader.new 'foo'
      ENV.stub(:[])
      ENV.should_receive(:[]).with 'AWS_SECRET_KEY'
      some_uploader.aws_secret_key
    end
  end

  describe "#fog_directory" do
    context "the uploader is not instantiated with a bucket name parameter" do
      it "returns the value of the FOG_DIRECTORY environment variable" do
        some_uploader = Lob::Uploader.new 'foo'
        ENV.stub(:[])
        ENV.should_receive(:[]).with 'FOG_DIRECTORY'
        some_uploader.fog_directory
      end
    end

    context "the uploader is instantiated with a bucket name parameter" do
      it "returns the value of the bucket name it was passed on instantiation" do
        some_uploader = Lob::Uploader.new 'foo', 'bar'
        some_uploader.fog_directory.should eq 'bar'
      end
    end
  end
end
