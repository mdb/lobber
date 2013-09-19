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
    cli.stub :say
  end

  after do
    Fog.unmock!
    FileUtils.rm_rf tmpdir
  end

  describe "#lob" do
    context "it's not passed any arguments" do
      it "returns usage details" do
        cli.should_receive(:usage).exactly(1).times
        cli.lob
      end
    end

    context "it's passed a directory that does not exist" do
      it "reports that it was passed an invalid directory and exits with an exit code of 1" do
        Kernel.stub(:exit).and_return true
        File.stub(:directory?).and_return false
        cli.should_receive(:error).with("foo is not a valid directory")
        lambda { cli.lob 'foo' }.should exit_with_code(1)
      end
    end

    context "when it's passed a valid directory" do
      before :each do
        ENV.stub(:[]).and_return true
        File.stub(:directory?).and_return true
      end

      it "uploads" do
        Lob.should_receive(:upload).with("foo", nil)
        cli.lob "foo"
      end

      it "reports that the directory has been successfully uploaded" do
        cli.should_receive(:say).with("Successfully uploaded foo", "\e[32m")
        cli.lob "foo"
      end
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
end
