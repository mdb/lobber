require 'thor'

module Lob
  class CLI < Thor
    default_task :lob

    desc "DIRECTORY", "Upload a directory to Amazon S3"
    option :bucket
    def lob(directory=nil)
      return usage unless directory
      return report_invalid_directory(directory) unless File.directory?(directory)
      upload(directory, options[:bucket])
    end

    desc "usage", "Display usage banner", hide: true
    def usage
      say "Lob #{Lob::VERSION}"
      say "https://github.com/mdb/lob"
      say "\n"

      help
    end

    no_tasks do
      def upload(directory, bucket=nil)
        Lob.upload directory, bucket
        report_success directory
      end
    end

    no_tasks do
      def report_success(directory)
        say "Successfully uploaded #{directory}", "\033[32m"
      end
    end

    no_tasks do
      def report_invalid_directory(directory)
        error "#{directory} is not a valid directory"
      end
    end
  end
end
