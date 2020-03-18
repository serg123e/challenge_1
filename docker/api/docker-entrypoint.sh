#!/bin/bash

set -e
BUNDLE_IGNORE_CONFIG=1 bundle install

ruby -r/app/spec/support/fake_api.rb -e"FakeAPI.set :bind, '0.0.0.0'; FakeAPI.set :port, 9980; FakeAPI.start!"

