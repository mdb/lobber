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
    it "returns #usage if it is not passed any arguments" do
      cli.should_receive(:usage).exactly(1).times
      cli.lob
    end

    it "reports that it was passed an invalid directory if it's passed a directory that does not exist" do
      File.stub(:directory?).and_return false
      cli.should_receive(:error).with("foo is not a valid directory")
      cli.lob 'foo'
    end

    it "uploads with the proper options if it is passed a directory" do
      File.stub(:directory?).and_return true
      cli.should_receive(:upload).with("foo", nil)
      cli.lob "foo"
    end
  end

  describe "#usage" do
    subject(:usage) { cli.usage }

    it "displays version info, GitHub info, and help" do
      cli.should_receive(:say).with('Lob 0.0.1')
      cli.should_receive(:say).with('https://github.com/mdb/lob')
      cli.should_receive(:say).with("\n")
      cli.should_receive(:help)

      usage
    end
  end

  describe "#upload" do
    subject(:upload) { cli.upload(tmpdir) }

    before do
      ENV.stub(:[]).and_return 'foo'
    end

    it "uploads and reports that it's successfully done so with green output" do
      cli.stub(:say)
      cli.should_receive(:say).with("Successfully uploaded #{tmpdir}", "\e[32m")
      upload
    end
  end
end
