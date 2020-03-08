#!/bin/sh

gem i -v 6.0.2.1 rails
cd $APP_ROOT/..
rails new app --api -d postgresql --skip-test
