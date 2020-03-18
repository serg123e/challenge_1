#!/bin/bash

set -e
BUNDLE_IGNORE_CONFIG=1 bundle install

ruby /app/spec/support/fake_api.rb 

