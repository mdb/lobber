[![Build Status](https://travis-ci.org/mdb/lob.png?branch=master)](https://travis-ci.org/mdb/lob)

# Lob

Quickly toss a directory to Amazon S3 from the command line.

## Installation

    git clone https://github.com/mdb/lob
    cd lob
    rake install

## Usage

    lob some_directory

## Required Environment Variables

* AWS_ACCESS_KEY=your_aws_access_key
* AWS_SECRET_KEY=your_aws_secret_key
* FOG_DIRECTORY=some_aws_bucket
