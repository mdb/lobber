[![Build Status](https://travis-ci.org/mdb/lobber.png?branch=master)](https://travis-ci.org/mdb/lobber)
[![Code Climate](https://codeclimate.com/github/mdb/lobber/badges/gpa.svg)](https://codeclimate.com/github/mdb/lobber)

# Lobber

Quickly toss a directory to Amazon S3 from the command line.

## Installation

    gem install lobber

## Usage

    $ lob some_directory
    some_directory/index.html -> index.html
    some_directory/stylesheets/application.css -> stylesheets/application.css

Pass in a bucket name to substitute your $FOG_DIRECTORY env variable:

    $ lob some_directory --bucket some_aws_bucket

Set `--dry-run` to just see what files would be uploaded:

    $ log some_directory --dry-run

Set `--no-verbose` to suppress printing filenames while uploading:

    $ log some_directory --no-verbose


## Required Environment Variables

* AWS_ACCESS_KEY=your_aws_access_key
* AWS_SECRET_KEY=your_aws_secret_key
* FOG_DIRECTORY=some_aws_bucket
