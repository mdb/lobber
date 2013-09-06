require 'spec_helper'

require 'fileutils'
require 'tmpdir'

describe Lob::CLI do
  subject { cli }
  let(:cli) { described_class.new }

  let(:tmpdir) { Dir.mktmpdir }
  let(:input_filename) { File.join(tmpdir, "README.md") }
  let(:some_file) { File.read("README.md") }

  before do
    Fog.mock!
    File.open(input_filename, 'w') {|file| file.write some_file }
  end

  after do
    Fog.unmock!
    FileUtils.rm_rf tmpdir
  end

  describe "#lob" do
    it "returns #usage if it is not passed a directory" do
      cli.should_receive(:usage).exactly(1).times
      cli.lob
    end

    it "uploads with the proper options if it is passed a directory" do
      cli.should_receive(:upload).with("foo", nil)
      cli.lob "foo"
    end
  end

  describe "#usage" do
    subject(:usage) { cli.usage }

    it "displays a banner and help" do
      cli.should_receive(:puts).exactly(2).times
      cli.should_receive(:help)

      usage
    end
  end

  describe "#upload" do
    subject(:upload) { cli.upload(tmpdir) }

    before do
      ENV.stub(:[]).and_return 'foo'
    end

    it "uploads" do
      upload
    end
  end
end
