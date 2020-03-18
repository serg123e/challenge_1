#!/bin/bash

set -e
BUNDLE_IGNORE_CONFIG=1 bundle install

ruby -e 'sleep 100'

