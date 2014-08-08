require 'spec_helper'

require 'fileutils'
require 'tmpdir'

describe Lobber::CLI do
  subject { cli }
  let(:cli) { described_class.new }

  let(:tmpdir) { Dir.mktmpdir }
  let(:input_filename) { File.join(tmpdir, "README.md") }
  let(:some_file) { File.read("README.md") }

  before do
    Fog.mock!
    File.open(input_filename, 'w') {|file| file.write some_file }
    allow(cli).to receive :say
  end

  after do
    Fog.unmock!
    FileUtils.rm_rf tmpdir
  end

  describe "#lob" do
    context "it's not passed any arguments" do
      it "returns usage details" do
        expect(cli).to receive(:usage).exactly(1).times
        cli.lob
      end
    end

    context "it's passed a directory that does not exist" do
      it "reports that it was passed an invalid directory and exits with an exit code of 1" do
        allow(Kernel).to receive(:exit).and_return true
        allow(File).to receive(:directory?).and_return false
        expect(cli).to receive(:error).with("foo is not a valid directory")

        begin
          cli.lob('foo')
        rescue SystemExit => e
          expect(e.status).to eq(1)
        end
      end
    end

    context "when it's passed a valid directory" do
      before :each do
        allow(ENV).to receive(:[]).and_return true
        allow(File).to receive(:directory?).and_return true
      end

      it "uploads" do
        expect(Lobber).to receive(:upload).with("foo", nil)
        cli.lob "foo"
      end

      it "reports that the directory has been successfully uploaded" do
        expect(cli).to receive(:say).with("Successfully uploaded foo", "\e[32m")
        cli.lob "foo"
      end
    end
  end

  describe "#usage" do
    subject(:usage) { cli.usage }

    it "displays version info, GitHub info, and help" do
      expect(cli).to receive(:say).with('Lobber 0.0.4')
      expect(cli).to receive(:say).with('https://github.com/mdb/lob')
      expect(cli).to receive(:say).with("\n")
      expect(cli).to receive(:help)

      usage
    end
  end
end
