#!/bin/bash -xe

set -xe

gem install bundler:2.1.4

cd app
bundle check --path=${BUNDLE_CACHE} || bundle install --path=${BUNDLE_CACHE} --jobs=2 --retry=3

bundle exec rake db:create
bundle exec rake db:migrate:reset
