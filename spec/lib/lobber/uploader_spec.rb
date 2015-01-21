require 'spec_helper'

describe Lobber::Uploader do
  subject(:uploader) { Lobber::Uploader.new(directory_name, options) }

  let(:directory_name) { 'spec' }
  let(:options) { {} }

  before :each do
    Fog.mock!
    allow(uploader).to receive(:aws_access_key).and_return 'fake key'
    allow(uploader).to receive(:aws_secret_key).and_return 'fake key'
    allow(uploader).to receive(:verbose).and_return false
    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[]).with('FOG_DIRECTORY').and_return directory_name
  end

  after :each do
    Fog.unmock!
  end

  it "exists as a class within the Lob module" do
    expect(Lobber::Uploader.class).to eq Class
  end

  describe "#upload" do
    before :each do
      allow(uploader).to receive(:verify_env_variables).and_return(true)
    end

    it "verifies necessary environment variables" do
      expect(uploader).to receive :verify_env_variables
      uploader.upload
    end

    it "calls #create_file_or_directory with each file or directory in the directory" do
      allow(uploader).to receive(:directory_content).and_return 'foo' => 'bar', 'baz' => 'bim'
      expect(uploader).to receive(:create_file_or_directory).with('foo', 'bar')
      expect(uploader).to receive(:create_file_or_directory).with('baz', 'bim')
      uploader.upload
    end
  end

  describe "#directory_content" do
    it "returns the content for the directory it's passed" do
      allow(File).to receive(:read).and_return 'content'
      expect(uploader.directory_content).to eq(
        "spec/lib/" => :directory,
        "spec/lib/lobber/" => :directory,
        "spec/lib/lobber/uploader_spec.rb" => "content",
        "spec/lib/lobber/cli_spec.rb" => "content",
        "spec/lib/lobber_spec.rb" => "content",
        "spec/spec_helper.rb" => "content",
        "spec/support/" => :directory,
        "spec/support/matchers/" => :directory,
        "spec/support/matchers/exit_with_code.rb" => "content"
      )
    end
  end

  describe "#bucket" do
    it "creates a bucket of the same name" do
      expect(uploader.bucket.class).to eq Fog::Storage::AWS::Directory
      expect(uploader.bucket.key).to eq 'spec'
    end
  end

  describe "#create_file_or_directory" do
    context "when it is called with the directory flag" do
      it "calls #create_directory" do
        expect(uploader).to receive(:create_directory).with 'foo'
        uploader.create_file_or_directory 'foo', :directory
      end
    end

    context "when it is called without the directory flag" do
      it "calls #create_directory" do
        expect(uploader).to receive(:create_file).with 'foo'
        uploader.create_file_or_directory 'foo', 'some_content'
      end
    end
  end

  describe "#create_directory" do
    it "creates an s3 directory" do
      expect(uploader.bucket.files).to receive(:create).with(key: 'foo', public: true)
      uploader.create_directory "foo"
    end
  end

  describe "#create_file" do
    before do
      allow(File).to receive(:open).and_return 'content'
    end

    let(:filename) { File.join(directory_name, 'foo.bar') }

    it "creates an s3 file" do
      expect(uploader.bucket.files)
        .to receive(:create)
        .with(key: 'foo.bar', public: true, body: 'content')
      uploader.create_file filename
    end

    it "logs each file to the screen" do
      expect(uploader).to receive(:log).with(filename, 'foo.bar')
      uploader.create_file filename
    end

    context "when the local and remote file are identical" do
      before do
        allow(uploader).to receive(:already_identical?).and_return(true)
      end

      it "does not upload the file again" do
        expect(uploader.bucket.files).to_not receive(:create)
        uploader.create_file filename
      end
    end

    context "with --dry-run" do
      let(:options) { { 'dry_run' => true } }

      it "does not create directories" do
        expect(uploader.bucket.files).to_not receive(:create)
        uploader.create_directory directory_name
      end

      it "does not upload files" do
        expect(uploader.bucket.files).to_not receive(:create)
        uploader.create_file filename
      end
    end

    context "with a directory outside of the working path" do
      let(:directory_name) { '/home/' }
      let(:filename) { '/home/foo/bar.baz' }

      it "strips the directory name from the upload key" do
        expect(uploader.bucket.files)
          .to receive(:create)
          .with(key: 'foo/bar.baz', public: true, body: 'content')
        uploader.create_file filename
      end
    end
  end

  describe "#s3" do
    before :each do
      allow(uploader).to receive(:aws_access_key).and_return('aws_access_key')
      allow(uploader).to receive(:aws_secret_key).and_return('aws_secret_key')
    end

    it "it instantiates a new Fog::Storage class with the proper arguments" do
      expect(Fog::Storage).to receive(:new).with(
        provider: :aws,
        aws_access_key_id: 'aws_access_key',
        aws_secret_access_key: 'aws_secret_key',
        path_style: false
      )
      uploader.s3
    end

    context "with a fog directory that includes a period" do
      let(:directory_name) { "foo.bar" }

      it "sets path style to true to silence warnings" do
        expect(Fog::Storage).to receive(:new) do |options|
          expect(options[:path_style]).to eq(true)
        end
        uploader.s3
      end
    end
  end

  describe "#verify_env_variables" do
    context "when one of the required environment variables is absent" do
      it "raises an error reporting that the missing environment variable is required" do
        allow(uploader).to receive(:aws_access_key).and_return nil
        expect { uploader.verify_env_variables }.to raise_error(RuntimeError, 'Required environment variables missing: ["AWS_ACCESS_KEY"]')
      end
    end

    context "when all of the required environment variables are defined" do
      before :each do
        allow(uploader).to receive(:aws_access_key).and_return true
        allow(uploader).to receive(:aws_secret_key).and_return true
        allow(uploader).to receive(:fog_directory).and_return true
      end

      it "it does not raise an error" do
        expect { uploader.verify_env_variables }.not_to raise_error
      end

      it "returns true" do
        expect(uploader.verify_env_variables).to eq true
      end
    end
  end

  describe "#aws_access_key" do
    it "returns the value of the AWS_ACCESS_KEY environment variable" do
      some_uploader = Lobber::Uploader.new 'foo'
      allow(ENV).to receive(:[])
      expect(ENV).to receive(:[]).with 'AWS_ACCESS_KEY'
      some_uploader.aws_access_key
    end
  end

  describe "#aws_secret_key" do
    it "returns the value of the AWS_ACCESS_KEY environment variable" do
      some_uploader = Lobber::Uploader.new 'foo'
      allow(ENV).to receive(:[])
      expect(ENV).to receive(:[]).with 'AWS_SECRET_KEY'
      some_uploader.aws_secret_key
    end
  end

  describe "#fog_directory" do
    context "the uploader is not instantiated with a bucket name parameter" do
      it "returns the value of the FOG_DIRECTORY environment variable" do
        expect(uploader.fog_directory).to eq(directory_name)
      end
    end

    context "the uploader is instantiated with a bucket name parameter" do
      let(:options) { { 'bucket' => 'bar' } }

      it "returns the value of the bucket name it was passed on instantiation" do
        expect(uploader.fog_directory).to eq('bar')
      end
    end
  end
end
