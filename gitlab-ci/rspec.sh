#!/bin/bash -xe

set -e

cd app

bundle exec rspec --profile

exit 0
