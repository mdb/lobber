require 'thor'

module Lob
  class CLI < Thor
    default_task :lob

    desc "DIRECTORY", "Upload a directory to Amazon S3"
    def lob(directory=nil)
      return usage unless directory
      upload directory
    end

    desc "usage", "Display usage banner", hide: true
    def usage
      puts [
        "Lob #{Lob::VERSION}",
        "https://github.com/mdb/lob"
      ].join("\n")

      puts "\n"

      help
    end

    no_tasks do
      def upload(directory)
        Lob.upload directory
      end
    end
  end
end
