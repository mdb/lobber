require 'fog'
require 'rake'

module Lobber
  class Uploader
    attr_reader :directory, :bucket_name, :dry_run, :verbose

    def initialize(directory, options = {})
      @directory = sanitize(directory)

      @bucket_name = options.fetch('bucket', nil)
      @dry_run = options.fetch('dry_run', false)
      @verbose = options.fetch('verbose', true)
    end

    def upload
      verify_env_variables
      directory_content.each do |file, value|
        create_file_or_directory(file, value)
      end
    end

    def directory_content
      hash = {}

      Rake::FileList["#{directory}/**/*"].each do |path|
        if File.directory?(path)
          hash["#{path}/"] = :directory
        else
          hash[path] = File.read(path)
        end
      end

      hash
    end

    def bucket
      @bucket ||= s3.directories.create(key: fog_directory, public: true)
    end

    def create_file_or_directory(file_or_directory, directory_flag)
      if directory_flag == :directory
        create_directory file_or_directory
      else
        create_file file_or_directory
      end
    end

    def create_directory directory
      return if dry_run
      bucket.files.create(key: directory, public: true)
    end

    def create_file file
      key = Pathname.new(file).relative_path_from(Pathname.new(directory)).to_s
      log file, key
      return if dry_run
      bucket.files.create(key: key, public: true, body: File.open(file))
    end

    def s3
      @s3 ||= Fog::Storage.new(
        provider: :aws,
        aws_access_key_id: aws_access_key,
        aws_secret_access_key: aws_secret_key
      )
    end

    def verify_env_variables
      missing = []

      missing << 'AWS_ACCESS_KEY' unless aws_access_key
      missing << 'AWS_SECRET_KEY' unless aws_secret_key
      missing << 'FOG_DIRECTORY' unless fog_directory

      return true if missing.empty?

      raise "Required environment variables missing: #{missing.inspect}"
    end

    def aws_access_key
      ENV['AWS_ACCESS_KEY']
    end

    def aws_secret_key
      ENV['AWS_SECRET_KEY']
    end

    def fog_directory
      bucket_name || ENV['FOG_DIRECTORY']
    end

    private

    def log(*strings)
      puts strings.join(' -> ') if verbose
    end

    def sanitize(directory_path)
      if directory_path.match(/\/$/)
        directory_path.chop
      else
        directory_path
      end
    end
  end
end
