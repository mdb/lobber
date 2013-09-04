require 'spec_helper'

describe "Lob::Upload" do
  before :each do
    Fog.mock!
    @uploader = Lob::Uploader.new 'spec'
    @uploader.stub(:aws_access_key).and_return 'fake key'
    @uploader.stub(:aws_secret_key).and_return 'fake key'
    @uploader.stub(:fog_directory).and_return 'fog directory'
  end

  after :each do
    Fog.unmock!
  end

  it "exists as a class within the Lob module" do
    Lob::Uploader.class.should eq Class
  end

  describe "#verify_env_and_upload" do
    before :each do
      @uploader.stub(:verify_env_variables).and_return(true)
      @uploader.stub(:upload).and_return(true)
    end

    it "verifies that necessary environment variables are present" do
      @uploader.should_receive(:verify_env_variables)
      @uploader.verify_env_and_upload
    end

    it "calls #upload" do
      @uploader.should_receive(:upload)
      @uploader.verify_env_and_upload
    end
  end

  describe "#upload" do
    it "calls #create_file_or_directory with each file or directory in the directory" do
      @uploader.stub(:directory_content).and_return 'foo' => 'bar', 'baz' => 'bim'
      @uploader.should_receive(:create_file_or_directory).with('foo', 'bar')
      @uploader.should_receive(:create_file_or_directory).with('baz', 'bim')
      @uploader.upload
    end
  end

  describe "#directory_content" do
    it "returns the content for the directory it's passed" do
      File.stub(:read).and_return 'content'
      @uploader.directory_content.should eq(
        "spec/lib/" => :directory,
        "spec/lib/lob/" => :directory,
        "spec/lib/lob/uploader_spec.rb" => "content",
        "spec/lib/lob_spec.rb" => "content",
        "spec/spec_helper.rb" => "content",
        "spec/support/" => :directory,
        "spec/support/matchers/" => :directory,
        "spec/support/matchers/exit_with_code.rb" => "content"
      )
    end
  end

  # pending
  describe "#bucket" do
    context "its behavior when a @bucket instance variable has been defined" do
      it "" do
      end
    end

    context "its behavior when a @bucket instance variable has not been defined" do
      it "" do
      end
    end
  end

  describe "#create_file_or_directory" do
    context "when it is called with the directory flag" do
      it "calls #create_directory" do
        @uploader.should_receive(:create_directory).with 'foo'
        @uploader.create_file_or_directory 'foo', :directory
      end
    end

    context "when it is called without the directory flag" do
      it "calls #create_directory" do
        @uploader.should_receive(:create_file).with 'foo'
        @uploader.create_file_or_directory 'foo', 'some_content'
      end
    end
  end

  describe "#create_directory" do
    it "creates an s3 directory" do
      @uploader.bucket.files.should_receive(:create).with(key: 'foo', public: true)
      @uploader.create_directory "foo"
    end
  end

  describe "#create_file" do
    it "creates an s3 file" do
      File.stub(:open).and_return 'content'
      @uploader.bucket.files.should_receive(:create).with(key: 'foo', public: true, body: 'content')
      @uploader.create_file "foo"
    end
  end

  describe "#s3" do
    before :each do
      @uploader.stub(:aws_access_key).and_return('aws_access_key')
      @uploader.stub(:aws_secret_key).and_return('aws_secret_key')
    end

    it "it instantiates a new Fog::Storage class with the proper arguments" do
      Fog::Storage.should_receive(:new).with(
        provider: :aws,
        aws_access_key_id: 'aws_access_key',
        aws_secret_access_key: 'aws_secret_key'
      )
      @uploader.s3
    end
  end

  # pending
  describe "#verify_env_variables" do
    context "when one of the required environment variables is absent" do
      before :each do
        ENV.stub(:[]).and_return(nil)
        ENV.stub(:[]).and_return(nil)
        ENV.stub(:[]).and_return(nil)
      end

      xit "exists with an exit code of 1" do
        lambda { @uploader.verify_env_variables }.should exit_with_code(1)
      end

      xit "it reports that the missing env variable is required" do
        Kernel.should_receive(:puts).with 'AWS_ACCESS_KEY required'
        lambda { @uploader.verify_env_variables }.call
      end
    end

    context "when all of the required environment variables are defined" do
      before :each do
        ENV.stub(:[]).with("AWS_SECRET_KEY").and_return 'secret key'
        ENV.stub(:[]).with("AWS_ACCESS_KEY").and_return 'access key'
        ENV.stub(:[]).with("FOG_DIRECTORY").and_return 'fog directory'
      end

      it "does not exit with an exit code of 1" do
        lambda { @uploader.verify_env_variables }.should_not exit_with_code(1)
      end

      it "it reports that the missing env variable is required" do
        Kernel.stub(:exit).and_return true
        @uploader.should_not receive(:puts).with 'AWS_ACCESS_KEY required'
        lambda { @uploader.verify_env_variables }
      end
    end
  end

  describe "#required_env_variables" do
    it "returns an array of the required env variables" do
      @uploader.required_env_variables.should eq ['AWS_ACCESS_KEY', 'AWS_SECRET_KEY', 'FOG_DIRECTORY']
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
    it "returns the value of the FOG_DIRECTORY environment variable" do
      some_uploader = Lob::Uploader.new 'foo'
      ENV.stub(:[])
      ENV.should_receive(:[]).with 'FOG_DIRECTORY'
      some_uploader.fog_directory
    end
  end
end
